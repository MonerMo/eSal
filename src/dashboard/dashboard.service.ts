import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prismaRepo: PrismaService) {}

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

    const [spendingThisMonth, nearestWarrantyItem, recentReceipts] =
      await Promise.all([
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
      // mocked for the hackathon demo — no real recommendation engine behind this yet
      smartOffers: [
        {
          title: 'Extended Warranty Available',
          description:
            'Protect your recent electronics purchase with an extended warranty plan.',
          imageUrl: null,
        },
        {
          title: '10% Cashback at Partner Stores',
          description:
            'Earn cashback when you shop at participating Smart Receipt partner stores.',
          imageUrl: null,
        },
      ],
    };
  }
}
