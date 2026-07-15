import {
  ConflictException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PairDeviceQrDto } from './DTO/pair-device-qr.dto';
import { PairDeviceNfcDto } from './DTO/pair-device-nfc.dto';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class DevicesService {
  constructor(private prismaRepo: PrismaService) {}

  private async createPairedDevice(pairingId: string, storeId: string) {
    const existing = await this.prismaRepo.device.findUnique({
      where: { pairingId },
    });

    if (existing) {
      throw new ConflictException('This device has already been paired');
    }
    return this.prismaRepo.device.create({ data: { pairingId, storeId } });
  }

  async pairViaQr(pairDeviceQrDto: PairDeviceQrDto) {
    const shopOwner = await this.prismaRepo.user.findUnique({
      where: { walletToken: pairDeviceQrDto.walletToken },
    });
    if (!shopOwner || shopOwner.accountType !== 'SHOP' || !shopOwner.storeId) {
      throw new ForbiddenException(
        'Only Shop Accounts with a store can pair devices',
      );
    }
    return this.createPairedDevice(
      pairDeviceQrDto.pairingId,
      shopOwner.storeId,
    );
  }

  async pairViaNfc(pairDeviceNfcDto: PairDeviceNfcDto, userId: string) {
    const shopOwner = await this.prismaRepo.user.findUnique({
      where: { id: userId },
    });
    if (!shopOwner || shopOwner.accountType !== 'SHOP' || !shopOwner.storeId) {
      throw new ForbiddenException(
        'Only shop accounts with a store can pair devices',
      );
    }
    return this.createPairedDevice(
      pairDeviceNfcDto.pairingId,
      shopOwner.storeId,
    );
  }

  async getPairingStatus(pairingId: string) {
    const device = await this.prismaRepo.device.findUnique({
      where: { pairingId },
    });
    if (!device) {
      return { paired: false };
    }
    if (device.apiKeyRetrieved) {
      return { paired: true };
    }

    await this.prismaRepo.device.update({
      where: { pairingId },
      data: { apiKeyRetrieved: true },
    });
    return { paired: true, apiKey: device.apiKey };
  }
}
