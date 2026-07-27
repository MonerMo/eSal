import { IsNotEmpty, IsString } from 'class-validator';

export class ConfirmLogoUploadDto {
  @IsString()
  @IsNotEmpty()
  key!: string;
}
