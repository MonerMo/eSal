import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { ReceiptsDto } from './DTO/receipt.dto';
import { DeviceAuthGuard } from './Guards/deviceAuthGuard';
import { ReceiptsService } from './receipts.service';

@Controller('receipts')
export class ReceiptsController {
  constructor(private receiptsService: ReceiptsService) {}

  @UseGuards(DeviceAuthGuard)
  @Post()
  receiptsPosting(@Body() receiptsDto: ReceiptsDto, @Req() req) {
    return this.receiptsService.receiptsPosting(receiptsDto, req.device.id);
  }

  //we inserted UseGuards(DeviceAuthGuard) on the route
  //not the controller because later on we will need
  //to add show all receipts for a user , that will need
  //user authentication
}
