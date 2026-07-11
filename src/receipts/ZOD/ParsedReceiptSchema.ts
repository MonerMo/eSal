import { z } from 'zod';

export const ParsedReceiptSchema = z.object({
  items: z.array(
    z.object({
      name: z.string(),
      quantity: z.number(),
      unitPrice: z.number(),
      totalPrice: z.number(),
      warrantyEndDate: z.string().nullable(),
      category: z.enum([
        'Food & Dining',
        'Coffee & Beverages',
        'Groceries',
        'Fashion & Apparel',
        'Electronics',
        'Books & Stationery',
        'Transport',
        'Health & Beauty',
        'Entertainment',
        'Other',
      ]),
    }),
  ),
  subtotal: z.number().nullable(),
  tax: z.number().nullable(),
  serviceCharge: z.number().nullable(),
  discount: z.number().nullable(),
  total: z.number().nullable(),
});
