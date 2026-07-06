-- AlterTable
ALTER TABLE "Device" ADD COLUMN     "pairingId" TEXT,
ALTER COLUMN "name" SET DEFAULT 'New Device';

-- Backfill existing rows with a random pairingId before enforcing NOT NULL/UNIQUE
UPDATE "Device" SET "pairingId" = gen_random_uuid()::text WHERE "pairingId" IS NULL;

ALTER TABLE "Device" ALTER COLUMN "pairingId" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Device_pairingId_key" ON "Device"("pairingId");
