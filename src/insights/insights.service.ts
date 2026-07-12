import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class InsightsService {
  constructor(private prismaRepo: PrismaService) {}

  private getRangeBounds(range?: string) {
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

  async getInsights(userId: string, range?: string) {
    const createdAt = this.getRangeBounds(range);

    const [totalSpending, categoryTotals, categories] = await Promise.all([
      this.prismaRepo.receipt.aggregate({
        where: { userId, createdAt },
        _sum: { total: true },
      }),
      this.prismaRepo.lineItem.groupBy({
        by: ['categoryId'],
        where: { receipt: { userId, createdAt } },
        _sum: { totalPrice: true },
        orderBy: { _sum: { totalPrice: 'desc' } },
      }),
      this.prismaRepo.category.findMany(),
    ]);

    const categoryNameById = new Map(categories.map((c) => [c.id, c.name]));

    return {
      range: range ?? 'thisMonth',
      totalSpending: totalSpending._sum.total ?? 0,
      categories: categoryTotals.map((c) => ({
        category: c.categoryId
          ? categoryNameById.get(c.categoryId)
          : 'Uncategorized',
        total: c._sum.totalPrice ?? 0,
      })),
    };
  }
}
