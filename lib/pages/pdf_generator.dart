import 'dart:io';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

Future<void> generateCertificatePdf({
  required String certificateNumber,
  required String referenceNumber,
  required String name,
  required String idNumber,
  required String courseDate,
  required String academyName,
  required String academyEntity,
  required String recognizedBy,
  required String courseName,
  required String location,
  required String instructorName,
  required String instructorCertificateNumber,
}) async {
  final pdf = pw.Document();

  // Load the main logo
  final ByteData logoBytes = await rootBundle.load('lib/assets/logo.jpeg');
  final pw.MemoryImage logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

  // Load the KKM logo
  final ByteData kkmLogoBytes = await rootBundle.load('lib/assets/Logo_Rasmi_KKM.png');
  final pw.MemoryImage kkmLogo = pw.MemoryImage(kkmLogoBytes.buffer.asUint8List());

  // Load the MBPJ logo
  final ByteData mbpjLogoBytes = await rootBundle.load('lib/assets/mbpj.png');
  final pw.MemoryImage mbpjLogo = pw.MemoryImage(mbpjLogoBytes.buffer.asUint8List());

  // Load the custom font
  final fontData = await rootBundle.load('lib/assets/fonts/FontsFree-Net-SF-Pro-Rounded-Bold.ttf');
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Certificate Logo
                pw.Container(
                  width: 100,
                  height: 100,
                  child: pw.Image(logo, fit: pw.BoxFit.cover),
                ),
                pw.SizedBox(height: 20),

                // Certificate Header
                pw.Text(
                  'Sijil Kehadiran',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),

                // Certificate Details
                pw.Text(
                  'This is to certify that:',
                  style: pw.TextStyle(fontSize: 16, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  name,
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'has successfully completed the course:',
                  style: pw.TextStyle(fontSize: 16, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Issued by: $academyName',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text('On the date: $courseDate', style: pw.TextStyle(font: ttf), textAlign: pw.TextAlign.center),
                pw.Text('Location: $location', style: pw.TextStyle(font: ttf), textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 20),

                // Signatures and Footer
                pw.Text(
                  'Instructor: $instructorName',
                  style: pw.TextStyle(fontSize: 14, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Instructor Certificate Number: $instructorCertificateNumber',
                  style: pw.TextStyle(fontSize: 14, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.Text(
                  'License Number: $certificateNumber | Phone Number: $referenceNumber',
                  style: pw.TextStyle(fontSize: 10, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Recognized By: $recognizedBy',
                  style: pw.TextStyle(fontSize: 10, font: ttf),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 60),

                // Bottom-right aligned logos with adjustable sizes
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    // KKM Logo
                    pw.Container(
                      width: 90, // Resize as needed
                      height: 90,
                      child: pw.Image(kkmLogo, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 30),
                    // MBPJ Logo
                    pw.Container(
                      width: 55, // Resize as needed
                      height: 55,
                      child: pw.Image(mbpjLogo, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  // Save the PDF to a temporary directory
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/certificate.pdf');
  await file.writeAsBytes(await pdf.save());

  // Open options to print or share the file
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
