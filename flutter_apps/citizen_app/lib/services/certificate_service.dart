import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class CertificateService {
  Future<Map<String, dynamic>> generateCertificate({
    required String helperName,
    required String city,
    required double lat,
    required double lng,
    required String emergencyId,
  }) async {
    final pdf = pw.Document();
    
    // Generate Certificate ID
    String randomDigits = const Uuid().v4().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 4);
    String certId = 'SHY-${city.toUpperCase().replaceAll(' ', '')}-$randomDigits';
    String dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    String verificationUrl = 'https://sahay.app/verify/$certId';
    
    // QR Code
    final qrPainter = QrPainter(
      data: verificationUrl,
      version: QrVersions.auto,
      gapless: true,
      color: const ui.Color(0xFF000000),
      emptyColor: const ui.Color(0xFFFFFFFF),
    );
    final ui.Image qrUiImage = await qrPainter.toImage(200);
    final ByteData? qrByteData = await qrUiImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List qrPngBytes = qrByteData!.buffer.asUint8List();
    final qrImage = pw.MemoryImage(qrPngBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#8C52FF'), width: 4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 20),
                pw.Text(
                  'GOOD SAMARITAN PROTECTION CERTIFICATE',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#8C52FF')),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Under Section 134A, Motor Vehicles (Amendment) Act, 2019',
                  style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Certificate ID: $certId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $dateStr'),
                  ]
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColor.fromHex('#8C52FF')),
                pw.SizedBox(height: 30),
                pw.Text(
                  'This certifies that the above-named individual provided voluntary emergency assistance.',
                  style: const pw.TextStyle(fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  helperName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Incident Details:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text('Emergency ID: $emergencyId'),
                      pw.Text('Location (GPS): $lat, $lng'),
                      pw.Text('City: $city'),
                    ]
                  )
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Image(qrImage, width: 80, height: 80),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Official Signature', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                        pw.SizedBox(height: 5),
                        pw.Container(width: 120, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text('Sahay Authority', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ]
                    )
                  ]
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Protected under the Good Samaritan Law. No civil or criminal liability shall attach.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$certId.pdf');
    await file.writeAsBytes(pdfBytes);

    // Save metadata to Firestore
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('certificates')
          .doc(certId)
          .set({
        'certId': certId,
        'helperName': helperName,
        'date': FieldValue.serverTimestamp(),
        'city': city,
        'lat': lat,
        'lng': lng,
        'emergencyId': emergencyId,
        'pdfPath': file.path,
      });
    }

    return {
      'certId': certId,
      'pdfPath': file.path,
      'pdfBytes': pdfBytes,
    };
  }

  Future<void> shareCertificate(String pdfPath) async {
    await Share.shareXFiles([XFile(pdfPath)], text: 'My Good Samaritan Protection Certificate from Sahay');
  }

  Future<void> previewCertificate(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
