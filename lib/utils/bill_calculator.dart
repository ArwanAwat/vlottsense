class BillCalculator {
  /// Calculates total electricity charge based on TNB block tariff
  static double calculateTotalCharges(double units) {
    double total = 0.0;

    if (units <= 0) return 0.0;

    // Block 1: First 200 kWh @ 21.8 sen/kWh
    if (units <= 200) {
      total = units * 0.218;
    }
    // Block 2: Next 100 kWh (201–300) @ 33.4 sen/kWh
    else if (units <= 300) {
      total = 200 * 0.218;
      total += (units - 200) * 0.334;
    }
    // Block 3: Next 300 kWh (301–600) @ 51.6 sen/kWh
    else if (units <= 600) {
      total = 200 * 0.218;
      total += 100 * 0.334;
      total += (units - 300) * 0.516;
    }
    // Block 4: Next 400 kWh (601–1000) @ 54.6 sen/kWh
    else {
      total = 200 * 0.218;
      total += 100 * 0.334;
      total += 300 * 0.516;
      total += (units - 600) * 0.546;
    }

    return double.parse(total.toStringAsFixed(3));
  }

  /// Calculates final cost after applying rebate
  static double calculateFinalCost(double totalCharges, double rebatePercent) {
    final rebate = totalCharges * (rebatePercent / 100);
    final finalCost = totalCharges - rebate;
    return double.parse(finalCost.toStringAsFixed(2));
  }
}