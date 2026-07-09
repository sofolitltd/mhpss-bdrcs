import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/clients/domain/models/bill.dart';
import 'bill_pdf_generator/bill_pdf_generator_pages.dart';
import 'bill_pdf_generator/bill_pdf_generator_top_sheet.dart';
import 'bill_pdf_generator/bill_pdf_generator_widgets.dart';

export 'bill_pdf_generator/bill_pdf_generator_pages.dart';
export 'bill_pdf_generator/bill_pdf_generator_widgets.dart';

class _PageData {
  final List<(DateTime, List<TaLeg>)> taEntries;
  final Set<DateTime> dateKeys;
  int totalLegs;
  bool includeMobile;
  double taSubTotal = 0;
  double daTotal = 0;
  double mobileTotal = 0;

  _PageData({
    required this.taEntries,
    required this.dateKeys,
    required this.totalLegs,
    this.includeMobile = false,
  });

  DateTime get fromDate => dateKeys.reduce(
    (a, b) => a.isBefore(b) ? a : b,
  );
  DateTime get toDate => dateKeys.reduce(
    (a, b) => a.isAfter(b) ? a : b,
  );
}

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
    final topSheetBuilder = BillPdfTopSheetBuilder(
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

    pw.Widget? logo;
    try {
      final logoData = await rootBundle.load('assets/bdrcs.webp');
      logo = pw.Image(pw.MemoryImage(logoData.buffer.asUint8List()), width: 60);
    } catch (_) {}

    // ─── Pack dates into pages (max 15 TA data rows per page) ────
    final pages = <_PageData>[];
    _PageData? currentPage;

    for (final group in bill.taGroups) {
      final legCount = group.legs.length;

      if (currentPage == null) {
        currentPage = _PageData(
          taEntries: [(group.date, group.legs)],
          dateKeys: {group.date},
          totalLegs: legCount,
          includeMobile: group.includeMobile,
        );
      } else if (currentPage.totalLegs + legCount > 15) {
        pages.add(currentPage);
        currentPage = _PageData(
          taEntries: [(group.date, group.legs)],
          dateKeys: {group.date},
          totalLegs: legCount,
          includeMobile: group.includeMobile,
        );
      } else {
        currentPage.taEntries.add((group.date, group.legs));
        currentPage.dateKeys.add(group.date);
        currentPage.totalLegs += legCount;
        if (group.includeMobile) {
          currentPage.includeMobile = true;
        }
      }
    }
    if (currentPage != null) {
      pages.add(currentPage);
    }

    // ─── Compute per-page totals ─────────────────────────────────
    final pageTotals = <double>[];
    double grandTaTotal = 0;
    double grandDaTotal = 0;
    double grandMobileTotal = 0;

    for (final page in pages) {
      double taSubTotal = 0;
      for (final (_, legs) in page.taEntries) {
        for (final leg in legs) {
          taSubTotal += leg.fare;
        }
      }

      double daDateTotal = 0;
      for (final row in bill.daRows) {
        daDateTotal += row.rate * page.dateKeys.length;
      }

      final mobileDateTotal = page.includeMobile ? 300.0 : 0.0;

      page.taSubTotal = taSubTotal;
      page.daTotal = daDateTotal;
      page.mobileTotal = mobileDateTotal;

      grandTaTotal += taSubTotal;
      grandDaTotal += daDateTotal;
      grandMobileTotal += mobileDateTotal;
      pageTotals.add(taSubTotal + daDateTotal + mobileDateTotal);
    }

    final grandTotal = grandTaTotal + grandDaTotal + grandMobileTotal;

    // Add top sheet as first page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => topSheetBuilder.buildTopSheet(
          bill: bill,
          pageTotals: pageTotals,
          grandTotal: grandTotal,
          logo: logo,
        ),
      ),
    );

    // Second pass: build TA/DA pages from packed page data
    final totalTaDaPages = pages.length;
    for (var pageIdx = 0; pageIdx < totalTaDaPages; pageIdx++) {
      final page = pages[pageIdx];
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

      for (final (date, legs) in page.taEntries) {
        for (var i = 0; i < legs.length; i++) {
          final leg = legs[i];
          taRows.add(
            pw.TableRow(
              children: [
                cellLocal(
                  i == 0 ? dateFmt.format(date) : '',
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
      }

      final emptyRowsCount = 15 - (taRows.length - 1);
      if (emptyRowsCount > 0) {
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

      final daDays = page.dateKeys.length;
      for (final row in bill.daRows) {
        final perDay = row.rate;
        final total = perDay * daDays;
        daRows.add(
          pw.TableRow(
            children: [
              cellLocal(dateFmt.format(page.fromDate), alignment: pw.Alignment.center),
              cellLocal(dateFmt.format(page.toDate), alignment: pw.Alignment.center),
              cellLocal(daDays.toString(), alignment: pw.Alignment.center),
              cellLocal(perDay.toString(), alignment: pw.Alignment.centerRight),
              cellLocal(total.toString(), alignment: pw.Alignment.centerRight),
              cellLocal(row.label, alignment: pw.Alignment.center),
            ],
          ),
        );
      }

      daRows.add(
        pw.TableRow(
          children: [
            cellLocal(
              page.includeMobile ? DateFormat('MMMM').format(bill.fromDate) : '',
              alignment: pw.Alignment.center,
            ),
            cellLocal(
              page.includeMobile ? DateFormat('MMMM').format(bill.toDate) : '',
              alignment: pw.Alignment.center,
            ),
            cellLocal('', alignment: pw.Alignment.center),
            cellLocal('', alignment: pw.Alignment.centerRight),
            cellLocal(
              page.includeMobile ? '300' : '',
              alignment: pw.Alignment.centerRight,
            ),
            cellLocal('Mobile Allowance', alignment: pw.Alignment.center),
          ],
        ),
      );

      final dateTotal = page.taSubTotal + page.daTotal + page.mobileTotal;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => builder.buildTaDaPage(
            bill: bill,
            taSubTotal: page.taSubTotal,
            daDateTotal: page.daTotal,
            mobileDateTotal: page.mobileTotal,
            dateTotal: dateTotal,
            taRows: taRows,
            daRows: daRows,
            includeMobile: page.includeMobile,
            pageNumber: pageIdx + 1,
            totalPages: totalTaDaPages,
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
    final dateFmt = DateFormat('MMMM yyyy');
    final name =
        fileName ?? '${dateFmt.format(bill.fromDate)} - ${bill.counselorName}';
    await Printing.layoutPdf(onLayout: (_) => pdf, name: name);
  }
}
