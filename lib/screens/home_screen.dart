import 'package:flutter/material.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';
import '../utils/bill_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();

  String? _selectedMonth;
  double _rebatePercent = 0.0;
  double? _totalCharges;
  double? _finalCost;
  bool _resultVisible = false;

  final List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMonth == null) {
      _showSnackBar('⚠️ Please select a month.', isError: true);
      return;
    }

    final units = double.tryParse(_unitsController.text.trim());
    if (units == null || units < 1 || units > 1000) {
      _showSnackBar('⚠️ Units must be between 1 and 1000 kWh.', isError: true);
      return;
    }

    final total = BillCalculator.calculateTotalCharges(units);
    final finalCost = BillCalculator.calculateFinalCost(total, _rebatePercent);

    setState(() {
      _totalCharges = total;
      _finalCost = finalCost;
      _resultVisible = true;
    });
  }

  Future<void> _saveRecord() async {
    if (_totalCharges == null || _finalCost == null || _selectedMonth == null) {
      _showSnackBar('⚠️ Please calculate first before saving.', isError: true);
      return;
    }

    final units = double.tryParse(_unitsController.text.trim());
    if (units == null) return;

    final record = BillRecord(
      month: _selectedMonth!,
      units: units,
      totalCharges: _totalCharges!,
      rebatePercent: _rebatePercent,
      finalCost: _finalCost!,
    );

    await DatabaseHelper.instance.insertBill(record);
    _showSnackBar('✅ Record saved successfully!');
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _selectedMonth = null;
      _unitsController.clear();
      _rebatePercent = 0.0;
      _totalCharges = null;
      _finalCost = null;
      _resultVisible = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF6A1B9A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('⚡ Electricity Bill Estimator'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset Form',
          onPressed: _resetForm,
        ),
      ],
    ),
    backgroundColor: const Color(0xFFF3E5F5),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 16),      
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_resultVisible) _buildResultCard(),
            if (_resultVisible) const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildRateTable(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFAB47BC)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6A1B9A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter your monthly electricity usage to estimate your bill. '
              'Select a month, enter units (1–1000 kWh), and adjust the rebate if applicable.',
              style: TextStyle(color: Color(0xFF4A148C), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Bill Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 16),

            // Month Dropdown
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Select Month',
                prefixIcon: Icon(Icons.calendar_month),
              ),
              items: _months.map((month) {
                return DropdownMenuItem(value: month, child: Text(month));
              }).toList(),
              onChanged: (val) => setState(() => _selectedMonth = val),
              validator: (val) => val == null ? 'Please select a month' : null,
            ),
            const SizedBox(height: 16),

            // Units Input
            TextFormField(
              controller: _unitsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Units Used (kWh)',
                prefixIcon: Icon(Icons.electric_meter),
                hintText: 'Enter 1 – 1000 kWh',
                suffixText: 'kWh',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter units used';
                final parsed = double.tryParse(val);
                if (parsed == null) return 'Enter a valid number';
                if (parsed < 1) return 'Minimum is 1 kWh';
                if (parsed > 1000) return 'Maximum is 1000 kWh';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Rebate Slider
            Text(
              'Rebate: ${_rebatePercent.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A1B9A),
                fontSize: 15,
              ),
            ),
            const Text(
              'Slide to set rebate percentage (0% – 5%)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Slider(
              value: _rebatePercent,
              min: 0,
              max: 5,
              divisions: 10,
              label: '${_rebatePercent.toStringAsFixed(1)}%',
              onChanged: (val) => setState(() => _rebatePercent = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: const Color(0xFF6A1B9A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧾 Calculation Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.white54),
            const SizedBox(height: 8),
            _buildResultRow('Month', _selectedMonth ?? '-'),
            _buildResultRow(
              'Units Used',
              '${double.tryParse(_unitsController.text)?.toStringAsFixed(1) ?? '-'} kWh',
            ),
            _buildResultRow(
              'Total Charges',
              'RM ${_totalCharges?.toStringAsFixed(3) ?? '-'}',
            ),
            _buildResultRow(
              'Rebate Applied',
              '${_rebatePercent.toStringAsFixed(1)}%',
            ),
            const Divider(color: Colors.white54),
            _buildResultRow(
              'Final Cost',
              'RM ${_finalCost?.toStringAsFixed(2) ?? '-'}',
              isBold: true,
              valueColor: const Color(0xFFE1BEE7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isBold = false,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
            onPressed: _calculate,
          ),
        ),
        if (_resultVisible) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
              ),
              onPressed: _saveRecord,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRateTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Tariff Rate Table',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                color: const Color(0xFFAB47BC),
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              children: [
                _tableHeader(),
                _tableRow('First 200 kWh (1–200)', '21.8 sen/kWh'),
                _tableRow('Next 100 kWh (201–300)', '33.4 sen/kWh'),
                _tableRow('Next 300 kWh (301–600)', '51.6 sen/kWh'),
                _tableRow('Next 400 kWh (601–1000)', '54.6 sen/kWh'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF6A1B9A)),
      children: [
        _tableCell('Block', isHeader: true),
        _tableCell('Rate', isHeader: true),
      ],
    );
  }

  TableRow _tableRow(String block, String rate) {
    return TableRow(
      children: [
        _tableCell(block),
        _tableCell(rate),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }
}