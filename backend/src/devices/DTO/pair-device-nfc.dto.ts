import { IsNotEmpty, IsString } from 'class-validator';

export class PairDeviceNfcDto {
  @IsString()
  @IsNotEmpty()
  pairingId!: string;
}
