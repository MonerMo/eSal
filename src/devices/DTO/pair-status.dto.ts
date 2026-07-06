import { IsNotEmpty, IsString } from 'class-validator';

export class PairingStatusDto {
  @IsString()
  @IsNotEmpty()
  pairingId!: string;
}
