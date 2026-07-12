import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { InsightsService } from './insights.service';
import { GetInsightsQueryDto } from './DTO/get.insights.query.dto';

@Controller('insights')
export class InsightsController {
  constructor(private insightsService: InsightsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get()
  getInsights(@Req() req, @Query() query: GetInsightsQueryDto) {
    return this.insightsService.getInsights(req.user.userId, query.range);
  }
}
