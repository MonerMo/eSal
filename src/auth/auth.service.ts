import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { SignupDto } from './DTO/signup.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { Prisma } from 'generated/prisma/client';
import { LoginDto } from './DTO/login.dto';
import { JwtService } from '@nestjs/jwt';
@Injectable()
export class AuthService {
  constructor(
    private prismaRepo: PrismaService,
    private jwtService: JwtService,
  ) {}
  async signup(signupRequest: SignupDto) {
    //first check if there is account exists with
    //the same email
    //after that if exists return email already exists
    //if not , now hash the password
    //check account type if SHOP , we will have nested write
    //if user normal write
    const hashedPassword = await bcrypt.hash(signupRequest.password, 10);

    try {
      //write the data here to database and check for error
      const user = await this.prismaRepo.user.create({
        data: {
          email: signupRequest.email,
          password: hashedPassword,
          name: signupRequest.name,
          phone: signupRequest.phone,
          accountType: signupRequest.accountType,
          ...(signupRequest.accountType === 'SHOP' && {
            store: { create: { name: signupRequest.storeName! } },
          }),
        },
        omit: { password: true },
      });
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
    //now create a token and return it
    const token = this.jwtService.sign({ sub: user.id, role: user.role });
    return { accessToken: token };
  }
}
