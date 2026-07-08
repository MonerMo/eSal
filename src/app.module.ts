import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { ReceiptsModule } from './receipts/receipts.module';
import { DevicesModule } from './devices/devices.module';
import { PassesModule } from './passes/passes.module';

@Module({
  imports: [PrismaModule, AuthModule, ConfigModule.forRoot({ isGlobal: true }), ReceiptsModule, DevicesModule, PassesModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
