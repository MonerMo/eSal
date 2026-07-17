import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prismaRepo: PrismaService) {}

  private async getSuitableOffers(userId: string) {
    const topCategory = await this.prismaRepo.lineItem.groupBy({
      by: ['categoryId'],
      where: { receipt: { userId } },
      _sum: { totalPrice: true },
      orderBy: { _sum: { totalPrice: 'desc' } },
      take: 1,
    });

    if (topCategory.length === 0 || !topCategory[0].categoryId) {
      return [];
    }

    const coupon = await this.prismaRepo.coupon.findFirst({
      where: { categoryId: topCategory[0].categoryId },
      select: { title: true, description: true, imageUrl: true },
    });

    return coupon ? [coupon] : [];
  }

  async getDashboard(userId: string) {
    const user = await this.prismaRepo.user.findUnique({
      where: { id: userId },
      select: { name: true },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const firstName = user.name.split(' ')[0];

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    const [
      spendingThisMonth,
      nearestWarrantyItem,
      recentReceipts,
      smartOffers,
    ] = await Promise.all([
      this.prismaRepo.receipt.aggregate({
        where: {
          userId,
          createdAt: { gte: startOfMonth, lt: startOfNextMonth },
        },
        _sum: { total: true },
      }),
      this.prismaRepo.lineItem.findFirst({
        where: {
          warrantyEndDate: { gte: now },
          receipt: { userId },
        },
        orderBy: { warrantyEndDate: 'asc' },
        select: {
          id: true,
          name: true,
          warrantyEndDate: true,
          receipt: {
            select: {
              id: true,
              device: {
                select: {
                  store: { select: { name: true, logoUrl: true } },
                },
              },
            },
          },
        },
      }),
      this.prismaRepo.receipt.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 3,
        select: {
          id: true,
          subtotal: true,
          tax: true,
          serviceCharge: true,
          discount: true,
          total: true,
          paymentMethod: true,
          invoiceNo: true,
          transactionDate: true,
          status: true,
          createdAt: true,
          device: {
            select: {
              store: { select: { name: true, logoUrl: true, taxId: true } },
            },
          },
          lineItems: {
            select: {
              id: true,
              name: true,
              quantity: true,
              unitPrice: true,
              totalPrice: true,
              warrantyEndDate: true,
              category: { select: { name: true } },
            },
          },
        },
      }),
      this.getSuitableOffers(userId),
    ]);

    return {
      firstName,
      totalSpendingThisMonth: spendingThisMonth._sum.total ?? 0,
      nearestWarranty: nearestWarrantyItem
        ? {
            lineItemId: nearestWarrantyItem.id,
            itemName: nearestWarrantyItem.name,
            warrantyEndDate: nearestWarrantyItem.warrantyEndDate,
            receiptId: nearestWarrantyItem.receipt.id,
            storeName: nearestWarrantyItem.receipt.device.store.name,
            storeLogoUrl: nearestWarrantyItem.receipt.device.store.logoUrl,
          }
        : null,
      recentReceipts,
      smartOffers,
    };
  }
}
