import 'dart:io';

import 'package:bachat_gat/features/groups/models/models_index.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfApi {
  // Method to generate centered text
  static Future<void> generateCenteredText(String text) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 48)),
        ),
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Method to save generated PDF document
  static Future<File> saveDocument(
      {required String name, required pw.Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getDownloadsDirectory();
    final file = File('${dir!.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Method to generate table with member transaction details
  static Future<void> generateTable(List<MemberTransactionDetails> memberData,
      String memberName, String groupName) async {
    final fontData = await rootBundle.load('assets/fonts/marathi.ttf');

    // Create the Font object
    final font = pw.Font.ttf(fontData.buffer.asByteData());

    // Create the ThemeData with the loaded font
    var myTheme = pw.ThemeData.withFont(base: font);
    final pdf = pw.Document(
      theme: myTheme,
    );
    final headers = [
      'Month',
      'Paid Shares',
      'Loan Taken',
      'Paid Interest',
      'Paid Loan',
      'Remaining Loan',
      'Late Fee',
      'Others'
    ];

    final data = memberData
        .map((member) => [
              member.trxPeriod ?? '',
              member.paidShares?.toString() ?? '',
              member.loanTaken?.toString() ?? '',
              member.paidInterest?.toString() ?? '',
              member.paidLoan?.toString() ?? '',
              member.remainingLoan?.toString() ?? '',
              member.paidLateFee?.toString() ?? '',
              member.paidOtherAmount?.toString() ?? '',
            ])
        .toList();

    pdf.addPage(pw.Page(build: (context) {
      return pw.Column(
        children: [
          pw.Text(groupName,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 20),
          pw.Column(
            children: [
              pw.Text("Member Name: $memberName",
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.normal,
                    fontStyle: pw.FontStyle.normal,
                  ))
            ],
          ),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
          ),
        ],
      );
    }));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
