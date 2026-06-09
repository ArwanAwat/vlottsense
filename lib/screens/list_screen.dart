import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bill_record.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<BillRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _recordsFuture = DatabaseHelper.instance.getAllBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Saved Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadRecords,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: FutureBuilder<List<BillRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading records.'),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Color(0xFFCE93D8)),
                  SizedBox(height: 12),
                  Text(
                    'No records yet.',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Calculate and save a bill to see it here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6A1B9A),
                    child: Text(
                      record.month.substring(0, 3),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    record.month,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to view details',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Final Cost',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        'RM ${record.finalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(recordId: record.id!),
                      ),
                    );
                    _loadRecords();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}