import { IsNotEmpty, IsString } from 'class-validator';

export class ReceiptsDto {
  @IsString()
  @IsNotEmpty()
  rawData!: string;
}
