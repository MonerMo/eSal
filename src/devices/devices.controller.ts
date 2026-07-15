import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { DevicesService } from './devices.service';
import { PairDeviceQrDto } from './DTO/pair-device-qr.dto';
import { PairDeviceNfcDto } from './DTO/pair-device-nfc.dto';
import { PairingStatusDto } from './DTO/pair-status.dto';

import { AuthGuard } from '@nestjs/passport';

@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Post('pair/qr')
  pairViaQr(@Body() pairDeviceQrDto: PairDeviceQrDto) {
    return this.devicesService.pairViaQr(pairDeviceQrDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('pair/nfc')
  pairViaNfc(@Body() pairDeviceNfcDto: PairDeviceNfcDto, @Req() req) {
    return this.devicesService.pairViaNfc(pairDeviceNfcDto, req.user.userId);
  }

  @Get('pair/status')
  getPairingStatus(@Query() pairingStatusDto: PairingStatusDto) {
    return this.devicesService.getPairingStatus(pairingStatusDto.pairingId);
  }
}
