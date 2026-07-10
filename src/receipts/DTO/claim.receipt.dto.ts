import { IsNotEmpty, IsString } from 'class-validator';

export class ClaimReceiptDto {
  @IsString()
  @IsNotEmpty()
  walletToken!: string;
}
