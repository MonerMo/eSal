import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ReceiptsDto } from './DTO/receipt.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { zodTextFormat } from 'openai/helpers/zod.mjs';
import { ParsedReceiptSchema } from './ZOD/ParsedReceiptSchema';

@Injectable()
export class ReceiptsService {
  private openai: OpenAI;

  constructor(
    private prismaRepo: PrismaService,
    private config: ConfigService,
  ) {
    const apiKey = this.config.get<string>('OPENAI_API_KEY');
    if (!apiKey) {
      throw new Error('OPENAI_API_KEY is not set');
    }
    this.openai = new OpenAI({ apiKey });
  }

  private async parseWithAi(rawData: string, receiptId: string) {
    const aiReturnedResponse = await this.openai.responses.parse({
      model: 'gpt-5.4-nano',
      input: [
        {
          role: 'system',
          content:
            'You are a receipt parsing assistant that will take raw bytes comming from raspberry pi that catches raw bytes out of POS system and you will return it parsed to a format structure',
        },
        { role: 'user', content: rawData },
      ],
      text: { format: zodTextFormat(ParsedReceiptSchema, 'receipt') },
    });
    const parsed = aiReturnedResponse.output_parsed;
    if (!parsed) {
      return; // model couldn't produce valid structured output — leave receipt as raw-only
    }

    await this.prismaRepo.receipt.update({
      where: { id: receiptId },
      data: {
        aiOutput: parsed,
        subtotal: parsed.subtotal,
        tax: parsed.tax,
        serviceCharge: parsed.serviceCharge,
        discount: parsed.discount,
        total: parsed.total,
        lineItems: {
          create: parsed.items.map((item) => ({
            name: item.name,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
            warrantyEndDate: item.warrantyEndDate
              ? new Date(item.warrantyEndDate)
              : null,
          })),
        },
      },
    });
  }

  async receiptsPosting(receiptsDto: ReceiptsDto, deviceId: string) {
    //remove null bytes from the rawData before saving
    //to the db , because the db fires error when it encounters null bytes in the string.
    const sanitizedRawData = receiptsDto.rawData.replace(/\0/g, '');

    //save the receipt first.
    const receipt = await this.prismaRepo.receipt.create({
      data: { rawData: sanitizedRawData, deviceId },
    });
    this.parseWithAi(sanitizedRawData, receipt.id).catch((err) => {
      //must catch - an unhandled rejection can crash the whole process
      console.error('AI parsing failed for receipt', receipt.id, err);
    });
    return receipt;
  }

  async claimReceiptViaQr(receiptId: string, walletToken: string) {
    const user = await this.prismaRepo.user.findUnique({
      where: { walletToken },
    });
    if (!user) {
      throw new NotFoundException('No user found for this wallet token');
    }

    if (user.accountType !== 'CUSTOMER') {
      throw new ForbiddenException('only customer accounts can claim receipts');
    }
    const receipt = await this.prismaRepo.receipt.findUnique({
      where: { id: receiptId },
    });

    if (!receipt) {
      throw new NotFoundException('Receipt not found');
    }

    if (receipt.status === 'ASSIGNED') {
      throw new ConflictException('Receipt has already been claimed');
    }

    return this.prismaRepo.receipt.update({
      where: { id: receiptId },
      data: { userId: user.id, status: 'ASSIGNED' },
    });
  }
}
