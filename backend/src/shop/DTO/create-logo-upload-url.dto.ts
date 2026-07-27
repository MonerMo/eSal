import { IsIn } from 'class-validator';

export class CreateLogoUploadUrlDto {
  @IsIn(['image/jpeg', 'image/png', 'image/webp'])
  contentType!: string;
}
