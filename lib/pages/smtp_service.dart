import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SmtpService {
  final String smtpServer = "smtp.gmail.com"; // Change this if using another provider
  final int smtpPort = 587; // Use 465 for SSL
  final String senderEmail = "ashrilaizad02@gmail.com"; // Your email
  final String senderPassword = "smjv jrgp nwum lvyf"; // Use an App Password for security

  Future<bool> sendOTP(String recipientEmail, String otp) async {
    final smtpServer = SmtpServer(
      this.smtpServer,
      port: smtpPort,
      username: senderEmail,
      password: senderPassword,
      ignoreBadCertificate: false,
    );

    final message = Message()
      ..from = Address(senderEmail, "Sharazie Security")
      ..recipients.add(recipientEmail)
      ..subject = "Your OTP Code"
      ..text = "Your OTP for authentication is: $otp. It will expire in 5 minutes.";

    try {
      await send(message, smtpServer);
      print("OTP sent successfully to $recipientEmail");
      return true;
    } catch (e) {
      print("Failed to send OTP: $e");
      return false;
    }
  }
}
