import { ConfigService } from '@nestjs/config';
import { readFileSync } from 'fs';
import { join } from 'path';
import {
  OnModuleInit,
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { PKPass } from 'passkit-generator';

@Injectable()
export class PassesService implements OnModuleInit {
  constructor(
    private readonly configService: ConfigService,
    private readonly prismaRepo: PrismaService,
  ) {}
  private readonly modelPath = join(
    process.cwd(),
    'src',
    'passes',
    'models',
    'esal.pass',
  );

  private signerCert!: Buffer;
  private signerKey!: Buffer;
  private wwdr!: Buffer;

  private loadCert(fileName: string, base64EnvVarName: string): Buffer {
    const base64Value = this.configService.get<string>(base64EnvVarName);
    if (base64Value) {
      return Buffer.from(base64Value, 'base64');
    }
    const certsDir =
      this.configService.get<string>('PASS_CERTS_DIR') ?? './certs';
    return readFileSync(join(certsDir, fileName));
  }

  onModuleInit() {
    this.signerCert = this.loadCert(
      'signerCert.pem',
      'PASS_SIGNER_CERT_BASE64',
    );

    this.signerKey = this.loadCert('signerKey.pem', 'PASS_SIGNER_KEY_BASE64');
    this.wwdr = this.loadCert('wwdr.pem', 'PASS_WWDR_BASE64');
  }

  async generatePass(userId: string) {
    //first check that the user exists and if it have
    //a user include it in the query result.
    const user = await this.prismaRepo.user.findUnique({
      where: { id: userId },
      include: { store: true },
    });

    if (!user || user.walletToken === null) {
      throw new NotFoundException("User Doesn't Have Wallet Token");
    }

    const description =
      user.accountType === 'SHOP'
        ? 'eSal Shop Owner Card'
        : 'eSal Customer Card';
    //check here if the user is shop owner and he is linked to shop
    if (user.accountType === 'SHOP' && !user.store) {
      throw new ConflictException('Shop Owner Not Linked To A Store');
    }

    const name = user.name;
    const label = user.accountType === 'SHOP' ? 'STORE' : 'Customer Membership';
    const value = user.accountType === 'SHOP' ? user.store!.name : name;

    const pass = await PKPass.from(
      {
        model: this.modelPath,
        certificates: {
          wwdr: this.wwdr,
          signerCert: this.signerCert,
          signerKey: this.signerKey,
          signerKeyPassphrase: this.configService.get<string>(
            'PASS_SIGNER_PASSPHRASE',
          ),
        },
      },
      {
        serialNumber: user.id,
        description,
      },
    );
    pass.primaryFields.pop();
    pass.primaryFields.push({ key: 'memberName', label, value });

    if (user.accountType === 'SHOP') {
      pass.secondaryFields.push({
        key: 'ownerName',
        label: 'Store Owner',
        value: name,
      });
    }
    pass.setBarcodes({
      format: 'PKBarcodeFormatQR',
      message: user.walletToken,
      messageEncoding: 'iso-8859-1',
    });
    return pass.getAsBuffer();
  }
}
