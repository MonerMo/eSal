import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ShopService } from './shop.service';
import { ShopOnlyGuard } from './Guards/shopOnlyGuard';
import { GetShopReceiptsQueryDto } from './DTO/get-shop-receipts-query.dto';
import { GetShopInsightsQueryDto } from './DTO/get-shop-insights-query.dto';
import { CreateLogoUploadUrlDto } from './DTO/create-logo-upload-url.dto';
import { ConfirmLogoUploadDto } from './DTO/confirm-logo-upload.dto';

@Controller('shop')
@UseGuards(AuthGuard('jwt'), ShopOnlyGuard)
export class ShopController {
  constructor(private shopService: ShopService) {}

  @Get('receipts')
  getReceipts(@Req() req, @Query() query: GetShopReceiptsQueryDto) {
    return this.shopService.getShopReceipts(
      req.user.storeId,
      {
        category: query.category,
        range: query.range,
        invoiceNo: query.invoiceNo,
      },
      query.page,
      query.pageSize,
    );
  }

  @Get('receipts/:id')
  getReceiptById(@Req() req, @Param('id') id: string) {
    return this.shopService.getShopReceiptById(req.user.storeId, id);
  }

  @Get('dashboard')
  getDashboard(@Req() req) {
    return this.shopService.getShopDashboard(req.user.storeId);
  }

  @Get('insights')
  getInsights(@Req() req, @Query() query: GetShopInsightsQueryDto) {
    return this.shopService.getShopInsights(req.user.storeId, query.range);
  }

  @Get('analysis')
  getAnalysis(@Req() req) {
    return this.shopService.getShopAnalysis(req.user.storeId);
  }

  @Get('devices')
  getDevices(@Req() req) {
    return this.shopService.getShopDevices(req.user.storeId);
  }

  @Post('store/logo/upload-url')
  createLogoUploadUrl(@Req() req, @Body() dto: CreateLogoUploadUrlDto) {
    return this.shopService.createLogoUploadUrl(
      req.user.storeId,
      dto.contentType,
    );
  }

  @Post('store/logo/confirm')
  confirmLogoUpload(@Req() req, @Body() dto: ConfirmLogoUploadDto) {
    return this.shopService.confirmLogoUpload(req.user.storeId, dto.key);
  }
}
