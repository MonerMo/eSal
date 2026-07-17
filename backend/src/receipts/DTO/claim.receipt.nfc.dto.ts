import { IsNotEmpty, IsString } from 'class-validator';

export class ClaimReceiptNfcDto {
  @IsString()
  @IsNotEmpty()
  pairingId!: string;
}
