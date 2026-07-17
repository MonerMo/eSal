import { IsIn, IsOptional } from 'class-validator';

export class GetInsightsQueryDto {
  @IsOptional()
  @IsIn(['thisMonth', 'lastMonth', '3months'])
  range?: string;
}
