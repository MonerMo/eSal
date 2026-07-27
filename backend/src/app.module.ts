import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { ReceiptsModule } from './receipts/receipts.module';
import { DevicesModule } from './devices/devices.module';
import { PassesModule } from './passes/passes.module';
import { UsersModule } from './users/users.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { InsightsModule } from './insights/insights.module';
import { ShopModule } from './shop/shop.module';
import { StorageModule } from './storage/storage.module';
import { MailModule } from './mail/mail.module';
@Module({
  imports: [
    PrismaModule,
    StorageModule,
    MailModule,
    AuthModule,
    ConfigModule.forRoot({ isGlobal: true }),
    ReceiptsModule,
    DevicesModule,
    PassesModule,
    UsersModule,
    DashboardModule,
    InsightsModule,
    ShopModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
