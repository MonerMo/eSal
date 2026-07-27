import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

@Injectable()
export class MailService {
  private readonly client: Resend;
  private readonly fromAddress: string;

  constructor(private config: ConfigService) {
    const apiKey = this.config.get<string>('RESEND_API_KEY');
    const fromAddress = this.config.get<string>('RESEND_FROM_EMAIL');

    if (!apiKey || !fromAddress) {
      throw new Error('Resend environment variables are not fully set');
    }

    this.fromAddress = fromAddress;
    this.client = new Resend(apiKey);
  }

  async sendVerificationEmail(to: string, code: string): Promise<void> {
    const { error } = await this.client.emails.send({
      from: this.fromAddress,
      to,
      subject: 'Verify your eSal account',
      html: this.buildVerificationEmailHtml(code),
    });

    if (error) {
      throw new Error(`Failed to send verification email: ${error.message}`);
    }
  }

  private buildVerificationEmailHtml(code: string): string {
    const headerUrl =
      'https://cdn.esal-image-cdn.win/Email%20Media/Email%20Header.jpg';
    const footerUrl =
      'https://cdn.esal-image-cdn.win/Email%20Media/Email%20Footer.png';

    return `
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:32px 16px;">
  <tr>
    <td align="center">
      <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;">
        <tr>
          <td style="padding:0 0 24px;">
            <img src="${headerUrl}" width="600" height="150" alt="eSal" style="display:block;width:100%;max-width:600px;height:auto;border-radius:16px;">
          </td>
        </tr>
        <tr>
          <td style="padding:0 12px 28px;">
            <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;color:#5b5f58;font-size:11px;letter-spacing:1.5px;text-transform:uppercase;">Verification Code</p>
            <p style="margin:0 0 20px;font-family:Arial,Helvetica,sans-serif;color:#1c1f1b;font-size:15px;line-height:1.6;">
              Use the code below to verify your account. It expires in 10 minutes.
            </p>
            <table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 20px;">
              <tr>
                <td style="border:2px solid #214720;border-radius:8px;padding:14px 28px;">
                  <span style="font-family:Arial,Helvetica,sans-serif;font-size:30px;font-weight:bold;letter-spacing:8px;color:#214720;">${code}</span>
                </td>
              </tr>
            </table>
            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;color:#5b5f58;font-size:13px;line-height:1.5;">
              Didn't request this? You can safely ignore this email.
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:0;">
            <img src="${footerUrl}" width="600" height="100" alt="eSal" style="display:block;width:100%;max-width:600px;height:auto;border-radius:16px;">
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>`;
  }
}
