String numberToWords(int number) {
  if (number == 0) return 'Zero';

  final below20 = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen',
  ];

  final tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety',
  ];

  String convertBelow1000(int n) {
    if (n == 0) return '';
    final parts = <String>[];
    final hundreds = n ~/ 100;
    if (hundreds > 0) {
      parts.add('${below20[hundreds]} Hundred');
    }
    final remainder = n % 100;
    if (remainder > 0) {
      if (remainder < 20) {
        parts.add(below20[remainder]);
      } else {
        parts.add('${tens[remainder ~/ 10]} ${below20[remainder % 10]}'.trim());
      }
    }
    return parts.join(' ');
  }

  final result = <String>[];
  final crore = number ~/ 10000000;
  if (crore > 0) {
    result.add('${convertBelow1000(crore)} Crore');
  }
  final lakh = (number % 10000000) ~/ 100000;
  if (lakh > 0) {
    result.add('${convertBelow1000(lakh)} Lakh');
  }
  final thousand = (number % 100000) ~/ 1000;
  if (thousand > 0) {
    result.add('${convertBelow1000(thousand)} Thousand');
  }
  final hundred = (number % 1000) ~/ 100;
  if (hundred > 0 && number % 1000 >= 100) {
    result.add('${below20[hundred]} Hundred');
  }
  final lastTwo = number % 100;
  if (lastTwo > 0) {
    if (lastTwo < 20) {
      result.add(below20[lastTwo]);
    } else {
      result.add('${tens[lastTwo ~/ 10]} ${below20[lastTwo % 10]}'.trim());
    }
  }

  return result.join(' ').trim();
}
