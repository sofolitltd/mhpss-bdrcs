import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/clients/domain/models/bill.dart';
import '../number_to_words.dart';
import 'bill_pdf_generator_widgets.dart';

class BillPdfTopSheetBuilder {
  BillPdfTopSheetBuilder({
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

  pw.Widget buildTopSheet({
    required Bill bill,
    required List<double> pageTotals,
    required double grandTotal,
    pw.Widget? logo,
  }) {
    pw.Widget tallCell(
      String text, {
      bool isHeader = false,
      pw.Alignment alignment = pw.Alignment.centerLeft,
    }) => pw.Container(
      constraints: const pw.BoxConstraints(minHeight: 22),
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: isHeader ? pw.Alignment.center : alignment,
      child: pw.Text(text, style: isHeader ? boldStyle : bodyStyle),
    );

    final rows = <pw.TableRow>[];
    rows.add(
      pw.TableRow(
        children: [
          tallCell('SL', isHeader: true),
          tallCell('Page No.', isHeader: true),
          tallCell('Amount', isHeader: true),
          tallCell('Remarks', isHeader: true),
        ],
      ),
    );

    for (var i = 0; i < pageTotals.length; i++) {
      rows.add(
        pw.TableRow(
          children: [
            tallCell('${i + 1}', alignment: pw.Alignment.center),
            tallCell('${i + 1}', alignment: pw.Alignment.center),
            tallCell(
              pageTotals[i].toInt().toString(),
              alignment: pw.Alignment.center,
            ),
            tallCell(''),
          ],
        ),
      );
    }

    for (var i = pageTotals.length; i < 20; i++) {
      rows.add(
        pw.TableRow(
          children: [
            tallCell('', alignment: pw.Alignment.center),
            tallCell('', alignment: pw.Alignment.center),
            tallCell(''),
            tallCell(''),
          ],
        ),
      );
    }

    rows.add(
      pw.TableRow(
        children: [
          tallCell(''),
          tallCell('Total', isHeader: true, alignment: pw.Alignment.center),
          tallCell(
            grandTotal.toInt().toString(),
            isHeader: true,
            alignment: pw.Alignment.center,
          ),
          tallCell(''),
        ],
      ),
    );

    final periodStr =
        '${DateFormat('d MMMM yyyy').format(bill.fromDate)} to ${DateFormat('d MMMM yyyy').format(bill.toDate)}';
    final eventStr = 'TA/DA of ${bill.designation} for the ${bill.purpose}';
    final inWords = '${numberToWords(grandTotal.toInt())} Taka Only.';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        buildHeader(ttfBold, ttf, showSubtitle: false, logo: logo, bottomSpacing: 0),
        pw.Center(
          child: pw.Text(
            'Top Sheet',
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 12,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildInfoRow('Name', bill.counselorName, boldStyle),
            buildInfoRow('Designation', bill.designation, boldStyle),
            buildInfoRow('Event', eventStr, boldStyle),
            buildInfoRow('Period', periodStr, boldStyle),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: const <int, pw.FlexColumnWidth>{
            0: pw.FlexColumnWidth(0.8),
            1: pw.FlexColumnWidth(1.5),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(3),
          },
          children: rows,
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'In Word: $inWords',
                style: bodyStyle,
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(child: pw.SizedBox()),
            pw.Container(
              width: 160,
              child: pw.Column(
                children: [
                  pw.Container(height: 0.5, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Center(child: pw.Text('Signature', style: boldStyle)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
