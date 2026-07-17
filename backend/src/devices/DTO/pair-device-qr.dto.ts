import { IsNotEmpty, IsString } from 'class-validator';

export class PairDeviceQrDto {
  @IsString()
  @IsNotEmpty()
  pairingId!: string;

  @IsString()
  @IsNotEmpty()
  walletToken!: string;
}
