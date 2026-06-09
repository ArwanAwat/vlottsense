import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bill_record.dart';
import '../utils/bill_calculator.dart';

class DetailScreen extends StatefulWidget {
  final int recordId;

  const DetailScreen({super.key, required this.recordId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  BillRecord? _record;
  bool _isEditing = false;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  String? _editMonth;
  final _editUnitsController = TextEditingController();
  double _editRebate = 0.0;

  final List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  @override
  void dispose() {
    _editUnitsController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    final record = await DatabaseHelper.instance.getBillById(widget.recordId);
    setState(() {
      _record = record;
      _isLoading = false;
      if (record != null) {
        _editMonth = record.month;
        _editUnitsController.text = record.units.toStringAsFixed(1);
        _editRebate = record.rebatePercent;
      }
    });
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_editMonth == null) {
      _showSnackBar('⚠️ Please select a month.', isError: true);
      return;
    }

    final units = double.tryParse(_editUnitsController.text.trim());
    if (units == null || units < 1 || units > 1000) {
      _showSnackBar('⚠️ Units must be between 1 and 1000 kWh.', isError: true);
      return;
    }

    final total = BillCalculator.calculateTotalCharges(units);
    final finalCost = BillCalculator.calculateFinalCost(total, _editRebate);

    final updated = BillRecord(
      id: _record!.id,
      month: _editMonth!,
      units: units,
      totalCharges: total,
      rebatePercent: _editRebate,
      finalCost: finalCost,
    );

    await DatabaseHelper.instance.updateBill(updated);
    setState(() {
      _record = updated;
      _isEditing = false;
    });
    _showSnackBar('✅ Record updated successfully!');
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteBill(_record!.id!);
      if (mounted) Navigator.pop(context);
    }
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
        title: Text(_isEditing ? '✏️ Edit Record' : '🔍 Record Detail'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _isLoading ? null : _deleteRecord,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            )
          : _record == null
              ? const Center(child: Text('Record not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isEditing ? _buildEditForm() : _buildDetailView(),
                ),
    );
  }

  Widget _buildDetailView() {
    final r = _record!;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📄 Bill Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const Divider(color: Color(0xFFAB47BC)),
                _detailRow('Month', r.month),
                _detailRow('Units Used', '${r.units.toStringAsFixed(1)} kWh'),
                _detailRow('Total Charges', 'RM ${r.totalCharges.toStringAsFixed(3)}'),
                _detailRow('Rebate', '${r.rebatePercent.toStringAsFixed(1)}%'),
                const Divider(color: Color(0xFFAB47BC)),
                _detailRow(
                  'Final Cost',
                  'RM ${r.finalCost.toStringAsFixed(2)}',
                  isBold: true,
                  valueColor: const Color(0xFF6A1B9A),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () => setState(() => _isEditing = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                onPressed: _deleteRecord,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
    Color valueColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✏️ Edit Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _editMonth,
                    decoration: const InputDecoration(
                      labelText: 'Select Month',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    items: _months.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (val) => setState(() => _editMonth = val),
                    validator: (val) =>
                        val == null ? 'Please select a month' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _editUnitsController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Units Used (kWh)',
                      prefixIcon: Icon(Icons.electric_meter),
                      suffixText: 'kWh',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter units';
                      final parsed = double.tryParse(val);
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < 1) return 'Minimum is 1 kWh';
                      if (parsed > 1000) return 'Maximum is 1000 kWh';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rebate: ${_editRebate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  Slider(
                    value: _editRebate,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: '${_editRebate.toStringAsFixed(1)}%',
                    onChanged: (val) => setState(() => _editRebate = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6A1B9A),
                    side: const BorderSide(color: Color(0xFF6A1B9A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => setState(() => _isEditing = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  onPressed: _saveEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}