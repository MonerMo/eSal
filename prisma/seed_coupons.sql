INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, 'Buy One Get One Free Coffee', 'Enjoy a free drink on your next visit to a partner cafe.', NULL, id, now()
FROM "Category" WHERE name = 'Coffee & Beverages';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '15% Off Your Next Meal', 'Save on your next order at participating restaurants.', NULL, id, now()
FROM "Category" WHERE name = 'Food & Dining';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '10% Off Grocery Essentials', 'A discount on your next grocery run.', NULL, id, now()
FROM "Category" WHERE name = 'Groceries';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '20% Off Clothing This Week', 'Refresh your wardrobe with a limited-time discount.', NULL, id, now()
FROM "Category" WHERE name = 'Fashion & Apparel';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '5% Cashback on Electronics', 'Get cashback on your next electronics purchase.', NULL, id, now()
FROM "Category" WHERE name = 'Electronics';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, 'Free Notebook with Purchase', 'A free notebook with any stationery purchase over a set amount.', NULL, id, now()
FROM "Category" WHERE name = 'Books & Stationery';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '10% Off Your Next Ride', 'A discount on your next trip with a partner transport service.', NULL, id, now()
FROM "Category" WHERE name = 'Transport';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '15% Off Beauty Products', 'Treat yourself with a discount on health and beauty items.', NULL, id, now()
FROM "Category" WHERE name = 'Health & Beauty';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '2-for-1 Movie Tickets', 'Bring a friend for free on your next movie outing.', NULL, id, now()
FROM "Category" WHERE name = 'Entertainment';

INSERT INTO "Coupon" (id, title, description, "imageUrl", "categoryId", "createdAt")
SELECT gen_random_uuid()::text, '10% Off Your Next Purchase', 'A surprise discount, valid store-wide.', NULL, id, now()
FROM "Category" WHERE name = 'Other';
