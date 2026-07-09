import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildHeader(pw.Font ttfBold, pw.Font ttf, {bool showSubtitle = true, pw.Widget? logo, double bottomSpacing = 16}) {
  return pw.Container(
    width: double.infinity,
    alignment: pw.Alignment.center,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) ...[
          logo,
          pw.SizedBox(height: 8),
        ],
        pw.Text(
          'BANGLADESH RED CRESCENT SOCIETY',
          style: pw.TextStyle(font: ttfBold, fontSize: 14),
        ),
        pw.Text(
          'National Headquarters, Dhaka',
          style: pw.TextStyle(font: ttf, fontSize: 11),
        ),
        pw.Text(
          '684-686, Red Crescent Sarak, Bara Moghbazar, Dhaka-1217',
          style: pw.TextStyle(font: ttfBold, fontSize: 10),
        ),
        if (showSubtitle) ...[
          pw.Text(
            'Traveling & Daily Allowance',
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 12,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ],
        pw.SizedBox(height: bottomSpacing),
      ],
    ),
  );
}

pw.Widget buildInfoRow(String label, String value, pw.TextStyle boldStyle) {
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

pw.Widget cell(
  String text, {
  bool isHeader = false,
  pw.Alignment alignment = pw.Alignment.centerLeft,
  required pw.TextStyle boldStyle,
  required pw.TextStyle bodyStyle,
}) {
  return pw.Container(
    constraints: const pw.BoxConstraints(minHeight: 20),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    alignment: isHeader ? pw.Alignment.center : alignment,
    child: pw.Text(text, style: isHeader ? boldStyle : bodyStyle),
  );
}

pw.Widget footerRow(
  String leftTop,
  String leftBottom,
  String rightSign,
  pw.TextStyle boldStyle,
) {
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
            if (leftBottom.isNotEmpty) pw.Text(leftBottom, style: boldStyle),
          ],
        ),
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
