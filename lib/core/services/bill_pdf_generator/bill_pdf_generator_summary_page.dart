import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/clients/domain/models/bill.dart';
import '../number_to_words.dart';
import 'bill_pdf_generator_widgets.dart';

const summaryColumnWidths = <int, pw.FlexColumnWidth>{
  0: pw.FlexColumnWidth(1.5),
  1: pw.FlexColumnWidth(1),
  2: pw.FlexColumnWidth(1),
  3: pw.FlexColumnWidth(1),
  4: pw.FlexColumnWidth(1),
};

class BillPdfSummaryBuilder {
  BillPdfSummaryBuilder({
    required this.ttfBold,
    required this.ttf,
    required this.boldStyle,
    required this.bodyStyle,
    required this.dateFmt,
  });

  final pw.Font ttfBold;
  final pw.Font ttf;
  final pw.TextStyle boldStyle;
  final pw.TextStyle bodyStyle;
  final DateFormat dateFmt;

  pw.Widget buildSummaryPage({
    required Bill bill,
    required List<Map<String, dynamic>> dateSummaries,
    required double grandTaTotal,
    required double grandDaTotal,
    required double grandMobileTotal,
    required double grandTotal,
  }) {
    final summaryRows = <pw.TableRow>[];
    summaryRows.add(
      pw.TableRow(
        children: [
          cell(
            'Date',
            isHeader: true,
            boldStyle: boldStyle,
            bodyStyle: bodyStyle,
          ),
          cell(
            'T/A',
            isHeader: true,
            boldStyle: boldStyle,
            bodyStyle: bodyStyle,
          ),
          cell(
            'D/A',
            isHeader: true,
            boldStyle: boldStyle,
            bodyStyle: bodyStyle,
          ),
          cell(
            'Mobile',
            isHeader: true,
            boldStyle: boldStyle,
            bodyStyle: bodyStyle,
          ),
          cell(
            'Total',
            isHeader: true,
            boldStyle: boldStyle,
            bodyStyle: bodyStyle,
          ),
        ],
      ),
    );
    for (final s in dateSummaries) {
      summaryRows.add(
        pw.TableRow(
          children: [
            cell(
              dateFmt.format(s['date'] as DateTime),
              boldStyle: boldStyle,
              bodyStyle: bodyStyle,
            ),
            cell(
              (s['ta'] as double).toString(),
              alignment: pw.Alignment.centerRight,
              boldStyle: boldStyle,
              bodyStyle: bodyStyle,
            ),
            cell(
              (s['da'] as double).toString(),
              alignment: pw.Alignment.centerRight,
              boldStyle: boldStyle,
              bodyStyle: bodyStyle,
            ),
            cell(
              (s['mobile'] as double).toString(),
              alignment: pw.Alignment.centerRight,
              boldStyle: boldStyle,
              bodyStyle: bodyStyle,
            ),
            cell(
              (s['total'] as double).toString(),
              alignment: pw.Alignment.centerRight,
              boldStyle: boldStyle,
              bodyStyle: bodyStyle,
            ),
          ],
        ),
      );
    }
    summaryRows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: pw.Alignment.center,
            child: pw.Text('Grand Total', style: boldStyle),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(grandTaTotal.toString(), style: boldStyle),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(grandDaTotal.toString(), style: boldStyle),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(grandMobileTotal.toString(), style: boldStyle),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(grandTotal.toString(), style: boldStyle),
          ),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        buildHeader(ttfBold, ttf),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildInfoRow('Name', bill.counselorName, boldStyle),
            buildInfoRow('Designation', bill.designation, boldStyle),
            buildInfoRow('Unit/ Department', bill.department, boldStyle),
            buildInfoRow('Purpose', bill.purpose, boldStyle),
            buildInfoRow(
              'Period',
              '${dateFmt.format(bill.fromDate)} - ${dateFmt.format(bill.toDate)}',
              boldStyle,
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text('Summary of All Bills', style: boldStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: summaryColumnWidths,
          children: summaryRows,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          grandMobileTotal > 0
              ? 'Grand Total: (T/A + D/A + Mobile) (${grandTaTotal.toInt()} + ${grandDaTotal.toInt()} + ${grandMobileTotal.toInt()} = ${grandTotal.toInt()})'
              : 'Grand Total: (T/A + D/A) (${grandTaTotal.toInt()} + ${grandDaTotal.toInt()} = ${grandTotal.toInt()})',
          'Taka (in word): (${numberToWords(grandTotal.toInt())} Taka Only)',
          'Applicant Signature',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Certified for Payment of TK.= ${grandTotal.toInt()}',
          '',
          'Finance Officer',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Passed for Payment of TK.= ${grandTotal.toInt()}',
          '',
          'Project Manager',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Received Tk.= ${grandTotal.toInt()}',
          '',
          'Recipient',
          boldStyle,
        ),
      ],
    );
  }
}
