class BillRecord {
  int? id;
  String month;
  double units;
  double totalCharges;
  double rebatePercent;
  double finalCost;

  BillRecord({
    this.id,
    required this.month,
    required this.units,
    required this.totalCharges,
    required this.rebatePercent,
    required this.finalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'units': units,
      'totalCharges': totalCharges,
      'rebatePercent': rebatePercent,
      'finalCost': finalCost,
    };
  }

  factory BillRecord.fromMap(Map<String, dynamic> map) {
    return BillRecord(
      id: map['id'],
      month: map['month'],
      units: map['units'],
      totalCharges: map['totalCharges'],
      rebatePercent: map['rebatePercent'],
      finalCost: map['finalCost'],
    );
  }
}