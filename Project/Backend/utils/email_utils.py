import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from config import Config
import logging

logger = logging.getLogger(__name__)

def send_verification_code(email, code):
    try:
        msg = MIMEMultipart("alternative")
        msg["From"] = f"DeFakeIt App <{Config.SMTP_EMAIL}>"
        msg["To"] = email
        msg["Subject"] = "Password Reset Verification Code"

        # Plain text version (fallback for non-HTML clients)
        plain_body = f"""
Hello,

You requested a password reset for your DeFakeIt account.
Your verification code is: {code}

This code is valid for 10 minutes. Enter it in the app to reset your password.

If you didn't request this, please ignore this email.

Best😍,
DeFakeIt Team
        """

        # HTML version (formatted for Gmail)
        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <h2 style="color: #2c3e50;">Password Reset for DeFakeIt</h2>
                <p>Hello,</p>
                <p>You requested a password reset for your DeFakeIt account.</p>
                <p>Your verification code is: <strong style="font-size: 1.2em; color: #e74c3c;">{code}</strong></p>
                <p>This code is valid for 10 minutes. Enter it in the app to reset your password.</p>
                <p>If you didn't request this, please ignore this email.</p>
                <p>Best😍,<br>The DeFakeIt Team</p>
                <hr style="border-top: 1px solid #eee;">
                <p style="font-size: 0.9em; color: #777;">
                    DeFakeIt App | Protecting Your Audio Integrity
                </p>
            </body>
        </html>
        """

        # Attach both versions
        msg.attach(MIMEText(plain_body, "plain"))
        msg.attach(MIMEText(html_body, "html"))

        # Send email
        server = smtplib.SMTP(Config.SMTP_SERVER, Config.SMTP_PORT)
        server.starttls()
        server.login(Config.SMTP_EMAIL, Config.SMTP_PASSWORD)
        server.sendmail(Config.SMTP_EMAIL, email, msg.as_string())
        server.quit()
        logger.info(f"Verification code sent to {email}")
        return True
    except Exception as e:
        logger.error(f"Failed to send email to {email}: {e}")
        return False