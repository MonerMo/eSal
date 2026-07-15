import { Controller, Get, Header } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('healthz')
  getHealth() {
    return { status: 'ok' };
  }


  @Get('.well-known/apple-app-site-association')
  @Header('Content-Type', 'application/json')
  getAppleAppSiteAssociation() {
    return {
      applinks: {
        apps: [],
        details: [
          {
            appID: 'Z44K6B6BA2.com.Raghad.eSal',
            paths: ['/nfc*'],
          },
        ],
      },
    };
  }
}
}
