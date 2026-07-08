import { Module } from '@nestjs/common';
import { PassesService } from './passes.service';
import { PassesController } from './passes.controller';

@Module({
  providers: [PassesService],
  controllers: [PassesController]
})
export class PassesModule {}
