import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the URL.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ℹ️ About')),
      backgroundColor: const Color(0xFFF3E5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStudentCard(context),
            const SizedBox(height: 16),
            _buildHowToUseCard(),
            const SizedBox(height: 16),
            _buildCopyrightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xFF6A1B9A),
              backgroundImage: const AssetImage('assets/icon/profile.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Arwan Awat Othman',  
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: 6),
            _infoChip(Icons.badge, 'QIU23-0265'),      
            const SizedBox(height: 6),
            _infoChip(Icons.school, 'Course: Mobile Technology'), 
            _infoChip(Icons.code, 'Course Code: ICT602'),        
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFAB47BC)),
            const SizedBox(height: 8),
            const Text(
              '⚡ Electricity Bill Estimator',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A Flutter-based Android application for estimating monthly electricity bills '
              'using TNB tariff rates. Supports local database storage, editing, and deletion of records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visit App GitHub Page'),
              onPressed: () => _launchUrl(
                context,
                'https://github.com/ArwanAwat/vlottsense', 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A1B9A)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildHowToUseCard() {
    final steps = [
      ('1️⃣  Select Month', 'Choose the billing month from the dropdown menu.'),
      ('2️⃣  Enter Units', 'Type the electricity units used (1 – 1000 kWh).'),
      ('3️⃣  Set Rebate', 'Use the slider to set a rebate (0% – 5%) if applicable.'),
      ('4️⃣  Calculate', 'Tap the Calculate button to see your estimated bill.'),
      ('5️⃣  Save Record', 'Tap Save to store the result in the local database.'),
      ('6️⃣  View Records', 'Go to the Records tab to view all saved bills.'),
      ('7️⃣  Edit / Delete', 'Tap any record to view details, edit, or delete it.'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📖 How to Use',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const Divider(color: Color(0xFFAB47BC)),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                    Text(
                      step.$2,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyrightCard() {
    return Card(
      color: const Color(0xFF6A1B9A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            '© 2024 Your Full Name. All rights reserved.\n'
            'Electricity Bill Estimator v1.0.0\n'
            'Built with Flutter for Android.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }
}