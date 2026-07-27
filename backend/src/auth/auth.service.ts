import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { SignupDto } from './DTO/signup.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { Prisma } from 'generated/prisma/client';
import { LoginDto } from './DTO/login.dto';
import { JwtService } from '@nestjs/jwt';
import { MailService } from 'src/mail/mail.service';
import { randomInt, randomUUID } from 'node:crypto';
import { VerifyEmailDto } from './DTO/verify-email.dto';
import { ResendCodeDto } from './DTO/resend-code.dto';
const VERIFICATION_CODE_TTL_MS = 10 * 60 * 1000;
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  constructor(
    private prismaRepo: PrismaService,
    private jwtService: JwtService,
    private mailService: MailService,
  ) {}
  async signup(signupRequest: SignupDto) {
    //first check if there is account exists with
    //the same email
    //after that if exists return email already exists
    //if not , now hash the password
    //check account type if SHOP , we will have nested write
    //if user normal write
    const hashedPassword = await bcrypt.hash(signupRequest.password, 10);
    const verificationCode = randomInt(100000, 1000000).toString();
    const verificationCodeExpiresAt = new Date(
      Date.now() + VERIFICATION_CODE_TTL_MS,
    );

    try {
      //write the data here to database and check for error
      const user = await this.prismaRepo.user.create({
        data: {
          email: signupRequest.email,
          password: hashedPassword,
          name: signupRequest.name,
          phone: signupRequest.phone,
          accountType: signupRequest.accountType,
          verificationCode,
          verificationCodeExpiresAt,
          ...(signupRequest.accountType === 'SHOP' && {
            store: { create: { name: signupRequest.storeName! } },
          }),
        },
        omit: {
          password: true,
          verificationCode: true,
          verificationCodeExpiresAt: true,
        },
      });
      try {
        await this.mailService.sendVerificationEmail(
          user.email,
          verificationCode,
        );
      } catch (err) {
        this.logger.error(
          `Failed to send verification email to  ${user.email}`,
          err,
        );
      }
      return user;
    } catch (err) {
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
        throw new ConflictException(
          'An Account with this email already exits.',
        );
      } else {
        throw new Error('Account Creation Failed');
      }
    }
  }

  async login(loginRequest: LoginDto) {
    //check if the user exists with the given email

    const user = await this.prismaRepo.user.findUnique({
      where: { email: loginRequest.email },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid Credentials');
    }
    const bool = await bcrypt.compare(loginRequest.password, user.password);
    if (!bool) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    if (user.deletedAt) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    if (!user.emailVerified) {
      throw new ForbiddenException(
        'Please Verify Your Email Before Logging In',
      );
    }
    //now create a token and return it
    const token = this.jwtService.sign({
      sub: user.id,
      role: user.role,
      accountType: user.accountType,
      storeId: user.storeId,
    });
    return { accessToken: token };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const user = await this.prismaRepo.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new BadRequestException('Invalid Or Expired Verification Code');
    }

    if (user.emailVerified) {
      return { message: 'Email Already Verified' };
    }

    if (
      !user.verificationCodeExpiresAt ||
      user.verificationCodeExpiresAt < new Date()
    ) {
      throw new BadRequestException(
        'Verification Code has Expired , please request a new one',
      );
    }

    if (user.verificationCode !== dto.code) {
      throw new BadRequestException('Invalid Verification Code');
    }
    await this.prismaRepo.user.update({
      where: { id: user.id },
      data: {
        emailVerified: true,
        verificationCode: null,
        verificationCodeExpiresAt: null,
      },
    });

    return { message: 'Email verified successfully' };
  }

  async resendVerificationCode(dto: ResendCodeDto) {
    const user = await this.prismaRepo.user.findUnique({
      where: { email: dto.email },
    });

    if (!user || user.emailVerified) {
      return {
        message:
          'If an account with this email exists and is not yet verified, a new code has been sent.',
      };
    }

    const verificationCode = randomInt(100000, 1000000).toString();
    const verificationCodeExpiresAt = new Date(
      Date.now() + VERIFICATION_CODE_TTL_MS,
    );

    await this.prismaRepo.user.update({
      where: { id: user.id },
      data: { verificationCode, verificationCodeExpiresAt },
    });

    try {
      await this.mailService.sendVerificationEmail(
        user.email,
        verificationCode,
      );
    } catch (err) {
      this.logger.error(
        `Failed to send verification email to ${user.email}`,
        err,
      );
    }

    return {
      message:
        'If an account with this email exists and is not yet verified, a new code has been sent.',
    };
  }

  async deleteAccount(userId: string): Promise<void> {
    await this.prismaRepo.$transaction(async (tx) => {
      const user = await tx.user.findUniqueOrThrow({ where: { id: userId } });

      if (user.deletedAt) {
        return;
      }

      await tx.user.update({
        where: { id: userId },
        data: {
          email: `deleted-${randomUUID()}@deleted.esal.internal`,
          name: 'Deleted User',
          phone: '',
          password: randomUUID(),
          deletedAt: new Date(),
        },
      });

      // This user's own customer-side receipts, wherever the issuing shop has also been deleted.
      await tx.receipt.deleteMany({
        where: {
          userId,
          device: { store: { user: { deletedAt: { not: null } } } },
        },
      });

      if (user.accountType === 'SHOP' && user.storeId) {
        // Revoke every paired device by rotating its apiKey — the physical
        // device still holds the old key, so this kills it immediately
        // without needing to touch the Device row's other fields.
        const devices = await tx.device.findMany({
          where: { storeId: user.storeId },
        });
        for (const device of devices) {
          await tx.device.update({
            where: { id: device.id },
            data: { apiKey: randomUUID() },
          });
        }

        // Receipts from this store that were never claimed, or whose
        // customer has also since deleted their account.
        await tx.receipt.deleteMany({
          where: {
            device: { storeId: user.storeId },
            OR: [{ userId: null }, { user: { deletedAt: { not: null } } }],
          },
        });
      }
    });
  }
}
