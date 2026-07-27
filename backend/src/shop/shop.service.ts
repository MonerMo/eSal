import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { Prisma } from '../../generated/prisma/client';
import { randomUUID } from 'node:crypto';
import { StorageService } from '../storage/storage.service';

@Injectable()
export class ShopService {
  constructor(
    private prismaRepo: PrismaService,
    private storageService: StorageService,
  ) {}

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

  async getShopAnalysis(storeId: string) {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

    const [thisMonthAgg, lastMonthAgg, receiptsForPatterns] = await Promise.all(
      [
        this.prismaRepo.receipt.aggregate({
          where: { device: { storeId }, createdAt: { gte: startOfMonth } },
          _sum: { total: true },
        }),
        this.prismaRepo.receipt.aggregate({
          where: {
            device: { storeId },
            createdAt: { gte: startOfLastMonth, lt: startOfMonth },
          },
          _sum: { total: true },
        }),
        this.prismaRepo.receipt.findMany({
          where: { device: { storeId } },
          select: { lineItems: { select: { name: true } } },
        }),
      ],
    );

    const thisMonthTotal = Number(thisMonthAgg._sum.total ?? 0);
    const lastMonthTotal = Number(lastMonthAgg._sum.total ?? 0);

    let advice: string;
    if (lastMonthTotal > 0) {
      const changePct = Math.round(
        ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100,
      );
      advice =
        changePct >= 0
          ? `Revenue is up ${changePct}% compared to last month.`
          : `Revenue is down ${Math.abs(changePct)}% compared to last month - consider a promotion to bring customers back.`;
    } else {
      advice = `You've made $${thisMonthTotal.toFixed(2)} in revenue this month so far.`;
    }

    const pairCounts = new Map<string, number>();
    for (const receipt of receiptsForPatterns) {
      const names = [...new Set(receipt.lineItems.map((li) => li.name))];
      for (let i = 0; i < names.length; i++) {
        for (let j = i + 1; j < names.length; j++) {
          const key = [names[i], names[j]].sort().join(' :: ');
          pairCounts.set(key, (pairCounts.get(key) ?? 0) + 1);
        }
      }
    }

    let pattern = 'Not enough data yet to detect buying patterns.';
    let topPair: [string, number] | null = null;
    for (const [key, count] of pairCounts) {
      if (count >= 2 && (!topPair || count > topPair[1])) {
        topPair = [key, count];
      }
    }
    if (topPair) {
      const [a, b] = topPair[0].split(' :: ');
      pattern = `Customers who buy ${a} often also buy ${b} - they've appeared together in ${topPair[1]} receipts.`;
    }

    return { advice, pattern };
  }

  async getShopDevices(storeId: string) {
    return this.prismaRepo.device.findMany({
      where: { storeId },
      select: {
        id: true,
        name: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createLogoUploadUrl(storeId: string, contentType: string) {
    const extension = contentType.split('/')[1];
    const key = `stores/${storeId}/logo-${randomUUID()}.${extension}`;

    const uploadUrl = await this.storageService.createUploadUrl(
      key,
      contentType,
    );
    return { uploadUrl, key };
  }

  async confirmLogoUpload(storeId: string, key: string) {
    if (!key.startsWith(`stores/${storeId}`)) {
      throw new ForbiddenException('This upload does not belong to your store');
    }

    const size = await this.storageService.getObjectSize(key);
    if (size === null) {
      throw new BadRequestException(
        'Upload Not Found - make sure the upload finished before confirming',
      );
    }

    if (size === 0) {
      throw new BadRequestException('Uploaded file is empty');
    }

    const logoUrl = this.storageService.getPublicUrl(key);
    await this.prismaRepo.store.update({
      where: { id: storeId },
      data: { logoUrl },
    });
    return { logoUrl };
  }
}
