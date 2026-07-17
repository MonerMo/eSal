-- AlterTable
ALTER TABLE "LineItem" ADD COLUMN     "warrantyEndDate" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "Receipt" ADD COLUMN     "discount" DECIMAL(65,30),
ADD COLUMN     "serviceCharge" DECIMAL(65,30),
ADD COLUMN     "subtotal" DECIMAL(65,30),
ADD COLUMN     "tax" DECIMAL(65,30);
