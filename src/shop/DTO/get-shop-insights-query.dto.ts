import { IsIn, IsOptional } from 'class-validator';

export class GetShopInsightsQueryDto {
  @IsOptional()
  @IsIn(['thisMonth', 'lastMonth', '3months'])
  range?: string;
}
