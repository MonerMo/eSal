import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsString,
  MinLength,
  ValidateIf,
} from 'class-validator';
import { AccountType } from 'generated/prisma/enums';

export class SignupDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsNotEmpty()
  phone!: string;

  @IsEnum(AccountType)
  accountType!: AccountType;

  @ValidateIf((dto: SignupDto) => dto.accountType === AccountType.SHOP)
  @IsString()
  @IsNotEmpty()
  storeName?: string;
}
