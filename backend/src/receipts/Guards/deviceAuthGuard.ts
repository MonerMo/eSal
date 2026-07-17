import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class DeviceAuthGuard implements CanActivate {
  constructor(private prismaRepo: PrismaService) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const apiKey = request.headers['x-api-key'];

    if (!apiKey) {
      //this means no apiKey sent , no authenticated device
      throw new UnauthorizedException(
        'Missing API Key , Not Authenticated Device',
      );
    }

    //now check if the apiKey sent is real and connected to a device in the DB.
    const device = await this.prismaRepo.device.findUnique({
      where: { apiKey },
    });

    if (!device) {
      //this means the api key sent was for a fake device not real
      throw new UnauthorizedException('Invalid Device');
    }
    request.device = device;
    return true;
  }
}
