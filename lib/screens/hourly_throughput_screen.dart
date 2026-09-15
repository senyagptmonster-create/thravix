import 'package:flutter/material.dart';
import '../theme/thravix_theme.dart';

class HourlyThroughputScreen extends StatelessWidget {
  const HourlyThroughputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hourlyData = [
      {'hour': '09:00 - 10:00', 'in': 45, 'out': 12},
      {'hour': '10:00 - 11:00', 'in': 78, 'out': 24},
      {'hour': '11:00 - 12:00', 'in': 112, 'out': 48},
      {'hour': '12:00 - 13:00', 'in': 134, 'out': 85},
      {'hour': '13:00 - 14:00', 'in': 96, 'out': 110},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Throughput', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Visitor Entry & Exit Flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...hourlyData.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThravixTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ThravixTheme.edge),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d['hour'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text('+${d['in']} In', style: const TextStyle(color: ThravixTheme.success, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Text('-${d['out']} Out', style: const TextStyle(color: ThravixTheme.warning, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
