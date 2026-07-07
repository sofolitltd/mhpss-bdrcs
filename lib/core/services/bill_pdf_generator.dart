import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/domain/models/bill.dart';
import 'bill_pdf_generator/bill_pdf_generator_pages.dart';
import 'bill_pdf_generator/bill_pdf_generator_summary_page.dart';
import 'bill_pdf_generator/bill_pdf_generator_widgets.dart';

export 'bill_pdf_generator/bill_pdf_generator_pages.dart';
export 'bill_pdf_generator/bill_pdf_generator_summary_page.dart';
export 'bill_pdf_generator/bill_pdf_generator_widgets.dart';

class BillPdfGenerator {
  static Future<Uint8List> generate(
    Bill bill, {
    bool showSummary = true,
  }) async {
    final pdf = pw.Document();
    final ttf = pw.Font.times();
    final ttfBold = pw.Font.timesBold();
    final boldStyle = pw.TextStyle(font: ttfBold, fontSize: 10);
    final bodyStyle = pw.TextStyle(font: ttf, fontSize: 10);
    final dateFmt = DateFormat('dd/MM/yyyy');
    final builder = BillPdfPageBuilder(
      ttfBold: ttfBold,
      ttf: ttf,
      boldStyle: boldStyle,
      bodyStyle: bodyStyle,
      dateFmt: dateFmt,
    );
    final summaryBuilder = BillPdfSummaryBuilder(
      ttfBold: ttfBold,
      ttf: ttf,
      boldStyle: boldStyle,
      bodyStyle: bodyStyle,
      dateFmt: dateFmt,
    );

    pw.Widget cellLocal(
      String text, {
      bool isHeader = false,
      pw.Alignment alignment = pw.Alignment.centerLeft,
    }) => cell(
      text,
      isHeader: isHeader,
      alignment: alignment,
      boldStyle: boldStyle,
      bodyStyle: bodyStyle,
    );

    double grandTaTotal = 0.0;
    double grandDaTotal = 0.0;
    double grandMobileTotal = 0.0;
    final dateSummaries = <Map<String, dynamic>>[];

    for (final group in bill.taGroups) {
      double taSubTotal = 0.0;

      final taRows = <pw.TableRow>[];
      taRows.add(
        pw.TableRow(
          children: [
            cellLocal('Date', isHeader: true),
            cellLocal('From', isHeader: true),
            cellLocal('To', isHeader: true),
            cellLocal('Mode of Transport', isHeader: true),
            cellLocal('Fare', isHeader: true),
            cellLocal('Remarks', isHeader: true),
          ],
        ),
      );

      for (var i = 0; i < group.legs.length; i++) {
        final leg = group.legs[i];
        taSubTotal += leg.fare;
        taRows.add(
          pw.TableRow(
            children: [
              cellLocal(
                i == 0 ? dateFmt.format(group.date) : '',
                alignment: pw.Alignment.center,
              ),
              cellLocal(leg.from, alignment: pw.Alignment.center),
              cellLocal(leg.to, alignment: pw.Alignment.center),
              cellLocal(leg.mode, alignment: pw.Alignment.center),
              cellLocal(
                leg.fare.toString(),
                alignment: pw.Alignment.centerRight,
              ),
              cellLocal(leg.remarks, alignment: pw.Alignment.center),
            ],
          ),
        );
      }

      int emptyRowsCount = 9 - (taRows.length - 1);
      for (int i = 0; i < emptyRowsCount; i++) {
        taRows.add(
          pw.TableRow(
            children: [
              cellLocal(''),
              cellLocal(''),
              cellLocal(''),
              cellLocal(''),
              cellLocal(''),
              cellLocal(''),
            ],
          ),
        );
      }

      final daRows = <pw.TableRow>[];
      daRows.add(
        pw.TableRow(
          children: [
            cellLocal('From', isHeader: true),
            cellLocal('To', isHeader: true),
            cellLocal('Total days', isHeader: true),
            cellLocal('Allowance per day', isHeader: true),
            cellLocal('Total', isHeader: true),
            cellLocal('Remarks', isHeader: true),
          ],
        ),
      );

      double daDateTotal = 0.0;
      double mobileDateTotal = 0.0;
      for (final row in bill.daRows) {
        final perDay = row.rate;
        daDateTotal += perDay;
        daRows.add(
          pw.TableRow(
            children: [
              cellLocal(
                dateFmt.format(group.date),
                alignment: pw.Alignment.center,
              ),
              cellLocal(
                dateFmt.format(group.date),
                alignment: pw.Alignment.center,
              ),
              cellLocal('1', alignment: pw.Alignment.center),
              cellLocal(perDay.toString(), alignment: pw.Alignment.centerRight),
              cellLocal(perDay.toString(), alignment: pw.Alignment.centerRight),
              cellLocal(row.label, alignment: pw.Alignment.center),
            ],
          ),
        );
      }

      if (group.includeMobile) {
        mobileDateTotal += 300;
        daRows.add(
          pw.TableRow(
            children: [
              cellLocal('', alignment: pw.Alignment.center),
              cellLocal('', alignment: pw.Alignment.center),
              cellLocal('', alignment: pw.Alignment.center),
              cellLocal('300', alignment: pw.Alignment.centerRight),
              cellLocal('300', alignment: pw.Alignment.centerRight),
              cellLocal('Mobile Allowance', alignment: pw.Alignment.center),
            ],
          ),
        );
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
          build: (_) => builder.buildTaDaPage(
            bill: bill,
            taSubTotal: taSubTotal,
            daDateTotal: daDateTotal,
            mobileDateTotal: mobileDateTotal,
            dateTotal: dateTotal,
            taRows: taRows,
            daRows: daRows,
            includeMobile: group.includeMobile,
          ),
        ),
      );
    }

    final grandTotal = grandTaTotal + grandDaTotal + grandMobileTotal;

    if (showSummary) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => summaryBuilder.buildSummaryPage(
            bill: bill,
            dateSummaries: dateSummaries,
            grandTaTotal: grandTaTotal,
            grandDaTotal: grandDaTotal,
            grandMobileTotal: grandMobileTotal,
            grandTotal: grandTotal,
          ),
        ),
      );
    }

    return pdf.save();
  }

  static Future<void> preview(
    Bill bill, {
    bool showSummary = true,
    String? fileName,
  }) async {
    final pdf = await generate(bill, showSummary: showSummary);
    final dateFmt = DateFormat('MMMM');
    final name =
        fileName ?? '${dateFmt.format(bill.fromDate)} - ${bill.counselorName}';
    await Printing.layoutPdf(onLayout: (_) => pdf, name: name);
  }
}
