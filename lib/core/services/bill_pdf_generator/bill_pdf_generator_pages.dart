import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/clients/domain/models/bill.dart';
import '../number_to_words.dart';
import 'bill_pdf_generator_widgets.dart';

const taColumnWidths = <int, pw.FlexColumnWidth>{
  0: pw.FlexColumnWidth(1.2),
  1: pw.FlexColumnWidth(1.5),
  2: pw.FlexColumnWidth(1.5),
  3: pw.FlexColumnWidth(1.8),
  4: pw.FlexColumnWidth(1.0),
  5: pw.FlexColumnWidth(1.5),
};

const daColumnWidths = <int, pw.FlexColumnWidth>{
  0: pw.FlexColumnWidth(1.2),
  1: pw.FlexColumnWidth(1.2),
  2: pw.FlexColumnWidth(1.0),
  3: pw.FlexColumnWidth(1.5),
  4: pw.FlexColumnWidth(1.0),
  5: pw.FlexColumnWidth(1.5),
};

class BillPdfPageBuilder {
  BillPdfPageBuilder({
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

  pw.Widget buildTaDaPage({
    required Bill bill,
    required double taSubTotal,
    required double daDateTotal,
    required double mobileDateTotal,
    required double dateTotal,
    required List<pw.TableRow> taRows,
    required List<pw.TableRow> daRows,
    required bool includeMobile,
  }) {
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
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text('T/A', style: boldStyle),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: taColumnWidths,
          children: taRows,
        ),
        pw.Table(
          columnWidths: taColumnWidths,
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(width: 0.5),
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Sub-Total', style: boldStyle),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(taSubTotal.toString(), style: bodyStyle),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text('D/A', style: boldStyle),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: daColumnWidths,
          children: daRows,
        ),
        pw.Table(
          columnWidths: daColumnWidths,
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.only(top: 4, left: 4),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                  child: pw.Text('Basic Pay TK.', style: bodyStyle),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(width: 0.5),
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Sub-Total', style: boldStyle),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(daDateTotal.toString(), style: bodyStyle),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                    ),
                  ),
                  constraints: const pw.BoxConstraints(minHeight: 18),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        footerRow(
          includeMobile
              ? 'Grand Total: (T/A + D/A + Mobile) ($taSubTotal + $daDateTotal + $mobileDateTotal = $dateTotal)'
              : 'Grand Total: (T/A + D/A) ($taSubTotal + $daDateTotal = $dateTotal)',
          'Taka (in word): (${numberToWords(dateTotal.toInt())} Taka Only)',
          'Applicant Signature',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Certified for Payment of TK.= ${dateTotal.toInt()}',
          '',
          'Finance Officer',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Passed for Payment of TK.= ${dateTotal.toInt()}',
          '',
          'Project Manager',
          boldStyle,
        ),
        pw.SizedBox(height: 24),
        footerRow(
          'Received Tk.= ${dateTotal.toInt()}',
          '',
          'Recipient',
          boldStyle,
        ),
      ],
    );
  }
}
