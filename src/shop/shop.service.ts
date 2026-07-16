import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { Prisma } from '../../generated/prisma/client';

@Injectable()
export class ShopService {
  constructor(private prismaRepo: PrismaService) {}

  async getShopReceipts(
    storeId: string,
    filters: { category?: string; range?: string; invoiceNo?: string },
    page = 1,
    pageSize = 20,
  ) {
    const where: Prisma.ReceiptWhereInput = { device: { storeId } };

    if (filters.category && filters.category !== 'All') {
      where.lineItems = { some: { category: { name: filters.category } } };
    }

    if (filters.range === 'thisWeek') {
      const startOfWeek = new Date();
      startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
      startOfWeek.setHours(0, 0, 0, 0);
      where.createdAt = { gte: startOfWeek };
    } else if (filters.range === 'lastMonth') {
      const now = new Date();
      where.createdAt = {
        gte: new Date(now.getFullYear(), now.getMonth() - 1, 1),
        lt: new Date(now.getFullYear(), now.getMonth(), 1),
      };
    }

    if (filters.invoiceNo) {
      where.invoiceNo = { contains: filters.invoiceNo, mode: 'insensitive' };
    }

    const [receipts, total] = await Promise.all([
      this.prismaRepo.receipt.findMany({
        where,
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
          device: { select: { name: true } },
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
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prismaRepo.receipt.count({ where }),
    ]);

    return {
      data: receipts,
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    };
  }

  async getShopReceiptById(storeId: string, receiptId: string) {
    const receipt = await this.prismaRepo.receipt.findUnique({
      where: { id: receiptId },
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
        device: { select: { storeId: true, name: true } },
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
    });

    if (!receipt) {
      throw new NotFoundException('Receipt not found');
    }

    if (receipt.device.storeId !== storeId) {
      throw new ForbiddenException(
        'This receipt does not belong to your store',
      );
    }

    return {
      id: receipt.id,
      subtotal: receipt.subtotal,
      tax: receipt.tax,
      serviceCharge: receipt.serviceCharge,
      discount: receipt.discount,
      total: receipt.total,
      paymentMethod: receipt.paymentMethod,
      invoiceNo: receipt.invoiceNo,
      transactionDate: receipt.transactionDate,
      status: receipt.status,
      createdAt: receipt.createdAt,
      device: { name: receipt.device.name },
      lineItems: receipt.lineItems,
    };
  }

  async getShopDashboard(storeId: string) {
    const store = await this.prismaRepo.store.findUnique({
      where: { id: storeId },
      select: { name: true },
    });

    if (!store) {
      throw new NotFoundException('Store not found');
    }

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    const [revenueThisMonth, receiptCountThisMonth, recentReceipts] =
      await Promise.all([
        this.prismaRepo.receipt.aggregate({
          where: {
            device: { storeId },
            createdAt: { gte: startOfMonth, lt: startOfNextMonth },
          },
          _sum: { total: true },
        }),
        this.prismaRepo.receipt.count({
          where: {
            device: { storeId },
            createdAt: { gte: startOfMonth, lt: startOfNextMonth },
          },
        }),
        this.prismaRepo.receipt.findMany({
          where: { device: { storeId } },
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
            device: { select: { name: true } },
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
      storeName: store.name,
      totalRevenueThisMonth: revenueThisMonth._sum.total ?? 0,
      receiptCountThisMonth,
      recentReceipts,
    };
  }

  private getInsightsRangeBounds(range?: string) {
    const now = new Date();

    if (range === 'lastMonth') {
      return {
        gte: new Date(now.getFullYear(), now.getMonth() - 1, 1),
        lt: new Date(now.getFullYear(), now.getMonth(), 1),
      };
    }

    if (range === '3months') {
      return {
        gte: new Date(now.getFullYear(), now.getMonth() - 2, 1),
        lt: new Date(now.getFullYear(), now.getMonth() + 1, 1),
      };
    }

    // default: thisMonth
    return {
      gte: new Date(now.getFullYear(), now.getMonth(), 1),
      lt: new Date(now.getFullYear(), now.getMonth() + 1, 1),
    };
  }

  async getShopInsights(storeId: string, range?: string) {
    const createdAt = this.getInsightsRangeBounds(range);

    const [totalRevenue, categoryTotals, categories] = await Promise.all([
      this.prismaRepo.receipt.aggregate({
        where: { device: { storeId }, createdAt },
        _sum: { total: true },
      }),
      this.prismaRepo.lineItem.groupBy({
        by: ['categoryId'],
        where: { receipt: { device: { storeId }, createdAt } },
        _sum: { totalPrice: true },
        orderBy: { _sum: { totalPrice: 'desc' } },
      }),
      this.prismaRepo.category.findMany(),
    ]);

    const categoryNameById = new Map(categories.map((c) => [c.id, c.name]));

    return {
      range: range ?? 'thisMonth',
      totalRevenue: totalRevenue._sum.total ?? 0,
      categories: categoryTotals.map((c) => ({
        category: c.categoryId
          ? categoryNameById.get(c.categoryId)
          : 'Uncategorized',
        total: c._sum.totalPrice ?? 0,
      })),
    };
  }
}
