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
import { ReceiptsDto } from './DTO/receipt.dto';
import { DeviceAuthGuard } from './Guards/deviceAuthGuard';
import { ReceiptsService } from './receipts.service';
import { ClaimReceiptDto } from './DTO/claim.receipt.dto';
import { AuthGuard } from '@nestjs/passport';
import { GetReceiptsQueryDto } from './DTO/get.receipt.query.dto';

@Controller('receipts')
export class ReceiptsController {
  constructor(private receiptsService: ReceiptsService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get()
  getReceipts(@Req() req, @Query() query: GetReceiptsQueryDto) {
    return this.receiptsService.getReceipts(
      req.user.userId,
      {
        category: query.category,
        range: query.range,
        search: query.search,
      },
      query.page,
      query.pageSize,
    );
  }

  @UseGuards(DeviceAuthGuard)
  @Post()
  receiptsPosting(@Body() receiptsDto: ReceiptsDto, @Req() req) {
    return this.receiptsService.receiptsPosting(receiptsDto, req.device.id);
  }

  //we inserted UseGuards(DeviceAuthGuard) on the route
  //not the controller because later on we will need
  //to add show all receipts for a user , that will need
  //user authentication

  @UseGuards(DeviceAuthGuard)
  @Post(':id/claim/qr')
  claimReceiptViaQr(@Param('id') id: string, @Body() dto: ClaimReceiptDto) {
    return this.receiptsService.claimReceiptViaQr(id, dto.walletToken);
  }
}
