import '../../../domain/models/bill.dart';
import 'ta_models.dart';

Bill buildBill({
  required String id,
  required String clientId,
  required String counselorId,
  required String counselorName,
  required String designation,
  required DateTime fromDate,
  required DateTime toDate,
  required List<TaGroupData> taGroups,
  required List<DaRow> daRows,
  required int totalTA,
  required int totalDA,
  required int grandTotal,
  required DateTime createdAt,
}) {
  return Bill(
    id: id,
    clientId: clientId,
    counselorId: counselorId,
    organizationId: '',
    counselorName: counselorName,
    designation: designation,
    department: 'Health',
    purpose: 'Home visit to provide psychosocial support',
    fromDate: fromDate,
    toDate: toDate,
    taGroups: taGroups
        .map(
          (g) => TaDateGroup(
            date: g.date,
            legs: g.legs
                .map(
                  (l) => TaLeg(
                    from: l.from,
                    to: l.to,
                    mode: l.mode,
                    fare: l.fare,
                    remarks: l.remarks,
                  ),
                )
                .toList(),
            includeMobile: g.includeMobile,
          ),
        )
        .toList(),
    daRows: daRows,
    totalTA: totalTA,
    totalDA: totalDA,
    grandTotal: grandTotal,
    createdAt: createdAt,
  );
}
