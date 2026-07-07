import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/domain/models/bill.dart';
import 'number_to_words.dart';

class BillPdfGenerator {
  static Future<Uint8List> generate(Bill bill, {bool showSummary = true}) async {
    final pdf = pw.Document();
    final dateFmt = DateFormat('dd/MM/yyyy');

    final ttf = pw.Font.times();
    final ttfBold = pw.Font.timesBold();

    final boldStyle = pw.TextStyle(font: ttfBold, fontSize: 10);
    final bodyStyle = pw.TextStyle(font: ttf, fontSize: 10);

    pw.Widget buildHeader() {
      return pw.Container(
        width: double.infinity,
        alignment: pw.Alignment.center,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('BANGLADESH RED CRESCENT SOCIETY',
                style: pw.TextStyle(font: ttfBold, fontSize: 14)),
            pw.Text('National Headquarters, Dhaka',
                style: pw.TextStyle(font: ttf, fontSize: 11)),
            pw.Text('684-686, Red Crescent Sarak, Bara Moghbazar, Dhaka-1217',
                style: pw.TextStyle(font: ttfBold, fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.Text('Traveling & Daily Allowance',
                style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 12,
                    decoration: pw.TextDecoration.underline)),
            pw.SizedBox(height: 16),
          ],
        ),
      );
    }

    pw.Widget buildInfoRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$label: ', style: boldStyle),
            pw.Text(value, style: boldStyle),
          ],
        ),
      );
    }

    pw.Widget cell(String text,
        {bool isHeader = false,
        pw.Alignment alignment = pw.Alignment.centerLeft}) {
      return pw.Container(
        constraints: const pw.BoxConstraints(minHeight: 18),
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        alignment: isHeader ? pw.Alignment.center : alignment,
        child: pw.Text(text, style: isHeader ? boldStyle : bodyStyle),
      );
    }

    final taColumnWidths = {
      0: const pw.FlexColumnWidth(1.2),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1.8),
      4: const pw.FlexColumnWidth(1.0),
      5: const pw.FlexColumnWidth(1.5),
    };

    final daColumnWidths = {
      0: const pw.FlexColumnWidth(1.2),
      1: const pw.FlexColumnWidth(1.2),
      2: const pw.FlexColumnWidth(1.0),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(1.0),
      5: const pw.FlexColumnWidth(1.5),
    };

    pw.Widget footerRow(
        String leftTop, String leftBottom, String rightSign) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (leftTop.isNotEmpty) pw.Text(leftTop, style: boldStyle),
                  if (leftTop.isNotEmpty && leftBottom.isNotEmpty)
                    pw.SizedBox(height: 2),
                  if (leftBottom.isNotEmpty)
                    pw.Text(leftBottom, style: boldStyle),
                ]),
          ),
          pw.Container(
            width: 160,
            child: pw.Column(
              children: [
                pw.Container(height: 0.5, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Center(child: pw.Text(rightSign, style: boldStyle)),
              ],
            ),
          ),
        ],
      );
    }

    double grandTaTotal = 0.0;
    double grandDaTotal = 0.0;
    double grandMobileTotal = 0.0;
    final dateSummaries = <Map<String, dynamic>>[];

    for (final group in bill.taGroups) {
      double taSubTotal = 0.0;

      final taRows = <pw.TableRow>[];
      taRows.add(pw.TableRow(
        children: [
          cell('Date', isHeader: true),
          cell('From', isHeader: true),
          cell('To', isHeader: true),
          cell('Mode of Transport', isHeader: true),
          cell('Fare', isHeader: true),
          cell('Remarks', isHeader: true),
        ],
      ));

      for (var i = 0; i < group.legs.length; i++) {
        final leg = group.legs[i];
        taSubTotal += leg.fare;
        taRows.add(pw.TableRow(
          children: [
            cell(i == 0 ? dateFmt.format(group.date) : '', alignment: pw.Alignment.center),
            cell(leg.from, alignment: pw.Alignment.center),
            cell(leg.to, alignment: pw.Alignment.center),
            cell(leg.mode, alignment: pw.Alignment.center),
            cell(leg.fare.toString(), alignment: pw.Alignment.centerRight),
            cell(leg.remarks, alignment: pw.Alignment.center),
          ],
        ));
      }

      int emptyRowsCount = 9 - (taRows.length - 1);
      for (int i = 0; i < emptyRowsCount; i++) {
        taRows.add(pw.TableRow(
          children: [
            cell(''),
            cell(''),
            cell(''),
            cell(''),
            cell(''),
            cell(''),
          ],
        ));
      }

      final daRows = <pw.TableRow>[];
      daRows.add(pw.TableRow(
        children: [
          cell('From', isHeader: true),
          cell('To', isHeader: true),
          cell('Total days', isHeader: true),
          cell('Allowance per day', isHeader: true),
          cell('Total', isHeader: true),
          cell('Remarks', isHeader: true),
        ],
      ));

      double daDateTotal = 0.0;
      double mobileDateTotal = 0.0;
      for (final row in bill.daRows) {
        final perDay = row.rate;
        daDateTotal += perDay;
        daRows.add(pw.TableRow(
          children: [
            cell(dateFmt.format(group.date), alignment: pw.Alignment.center),
            cell(dateFmt.format(group.date), alignment: pw.Alignment.center),
            cell('1', alignment: pw.Alignment.center),
            cell(perDay.toString(), alignment: pw.Alignment.centerRight),
            cell(perDay.toString(), alignment: pw.Alignment.centerRight),
            cell(row.label, alignment: pw.Alignment.center),
          ],
        ));
      }

      if (group.includeMobile) {
        mobileDateTotal += 300;
        daRows.add(pw.TableRow(
          children: [
            cell('', alignment: pw.Alignment.center),
            cell('', alignment: pw.Alignment.center),
            cell('', alignment: pw.Alignment.center),
            cell('300', alignment: pw.Alignment.centerRight),
            cell('300', alignment: pw.Alignment.centerRight),
            cell('Mobile Allowance', alignment: pw.Alignment.center),
          ],
        ));
      }

      grandTaTotal += taSubTotal;
      grandDaTotal += daDateTotal;
      grandMobileTotal += mobileDateTotal;

      final dateTotal = taSubTotal + daDateTotal + mobileDateTotal;
      dateSummaries.add({
        'date': group.date,
        'ta': taSubTotal,
        'da': daDateTotal,
        'mobile': mobileDateTotal,
        'total': dateTotal,
      });

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildInfoRow('Name', bill.counselorName),
                  buildInfoRow('Designation', bill.designation),
                  buildInfoRow('Unit/ Department', bill.department),
                  buildInfoRow('Purpose', bill.purpose),
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
                          border: pw.Border(
                            bottom: pw.BorderSide(width: 0.5),
                          ),
                        ),
                        constraints: const pw.BoxConstraints(minHeight: 18),
                      ),
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(width: 0.5),
                          ),
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
                            horizontal: 4, vertical: 2),
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
                            horizontal: 4, vertical: 2),
                        alignment: pw.Alignment.centerRight,
                        child:
                            pw.Text(taSubTotal.toString(), style: bodyStyle),
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
                          constraints:
                              const pw.BoxConstraints(minHeight: 18)),
                      pw.Container(
                          constraints:
                              const pw.BoxConstraints(minHeight: 18)),
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
                            horizontal: 4, vertical: 2),
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
                            horizontal: 4, vertical: 2),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(daDateTotal.toString(),
                            style: bodyStyle),
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
                  group.includeMobile
                      ? 'Grand Total: (T/A + D/A + Mobile) ($taSubTotal + $daDateTotal + $mobileDateTotal = $dateTotal)'
                      : 'Grand Total: (T/A + D/A) ($taSubTotal + $daDateTotal = $dateTotal)',
                  'Taka (in word): (${numberToWords(dateTotal.toInt())} Taka Only)',
                  'Applicant Signature'),
              pw.SizedBox(height: 24),
              footerRow('Certified for Payment of TK.= ${dateTotal.toInt()}', '', 'Finance Officer'),
              pw.SizedBox(height: 24),
              footerRow('Passed for Payment of TK.= ${dateTotal.toInt()}', '', 'Project Manager'),
              pw.SizedBox(height: 24),
              footerRow('Received Tk.= ${dateTotal.toInt()}', '', 'Recipient'),
            ],
          ),
        ),
      );
    }

    final grandTotal = grandTaTotal + grandDaTotal + grandMobileTotal;

    // Summary table
    final summaryColumnWidths = {
      0: const pw.FlexColumnWidth(1.5),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1),
    };
    final summaryRows = <pw.TableRow>[];
    summaryRows.add(pw.TableRow(
      children: [
        cell('Date', isHeader: true),
        cell('T/A', isHeader: true),
        cell('D/A', isHeader: true),
        cell('Mobile', isHeader: true),
        cell('Total', isHeader: true),
      ],
    ));
    for (final s in dateSummaries) {
      summaryRows.add(pw.TableRow(
        children: [
          cell(dateFmt.format(s['date'] as DateTime),
              alignment: pw.Alignment.center),
          cell((s['ta'] as double).toString(),
              alignment: pw.Alignment.centerRight),
          cell((s['da'] as double).toString(),
              alignment: pw.Alignment.centerRight),
          cell((s['mobile'] as double).toString(),
              alignment: pw.Alignment.centerRight),
          cell((s['total'] as double).toString(),
              alignment: pw.Alignment.centerRight),
        ],
      ));
    }
    summaryRows.add(pw.TableRow(
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
    ));

    if (showSummary) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildHeader(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  buildInfoRow('Name', bill.counselorName),
                  buildInfoRow('Designation', bill.designation),
                  buildInfoRow('Unit/ Department', bill.department),
                  buildInfoRow('Purpose', bill.purpose),
                  buildInfoRow('Period',
                      '${dateFmt.format(bill.fromDate)} - ${dateFmt.format(bill.toDate)}'),
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
                  'Applicant Signature'),
              pw.SizedBox(height: 24),
              footerRow('Certified for Payment of TK.= ${grandTotal.toInt()}', '', 'Finance Officer'),
              pw.SizedBox(height: 24),
              footerRow(
                  'Passed for Payment of TK.= ${grandTotal.toInt()}', '', 'Project Manager'),
              pw.SizedBox(height: 24),
              footerRow('Received Tk.= ${grandTotal.toInt()}', '', 'Recipient'),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  static Future<void> preview(Bill bill, {bool showSummary = true, String? fileName}) async {
    final pdf = await generate(bill, showSummary: showSummary);
    final dateFmt = DateFormat('MMMM');
    final name = fileName ?? '${dateFmt.format(bill.fromDate)} - ${bill.counselorName}';
    await Printing.layoutPdf(
      onLayout: (_) => pdf,
      name: name,
    );
  }
}