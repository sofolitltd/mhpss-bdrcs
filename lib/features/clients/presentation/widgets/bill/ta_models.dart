class TaGroupData {
  DateTime date;
  List<TaLegData> legs;
  bool includeMobile;

  TaGroupData(this.date, [List<TaLegData>? legs, this.includeMobile = false])
    : legs = legs ?? [];

  int get subTotal => legs.fold(0, (sum, l) => sum + l.fare);
}

class TaLegData {
  String from;
  String to;
  String mode;
  int fare;
  String remarks;

  TaLegData([
    this.from = '',
    this.to = '',
    this.mode = '',
    this.fare = 0,
    this.remarks = '',
  ]);
}
