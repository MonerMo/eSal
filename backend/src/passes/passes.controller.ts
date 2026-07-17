import {
  Controller,
  Get,
  Req,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import { PassesService } from './passes.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('passes')
export class PassesController {
  constructor(private readonly passesService: PassesService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('wallet')
  async getWalletPass(@Req() req): Promise<StreamableFile> {
    const buffer = await this.passesService.generatePass(req.user.userId);
    return new StreamableFile(buffer, {
      type: 'application/vnd.apple.pkpass',
      disposition: 'attachment; filename="esal.pkpass"',
    });
  }
}
