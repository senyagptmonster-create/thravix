import 'package:flutter/material.dart';
import '../app/theme.dart';

class GateCounterScreen extends StatelessWidget {
  const GateCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Gate Counter', style: AppTheme.display(context)));
  }
}
class HourlyChartScreen extends StatelessWidget {
  const HourlyChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Hourly Throughput', style: AppTheme.display(context)));
  }
}
class CapacityAlertScreen extends StatelessWidget {
  const CapacityAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Capacity Alerts', style: AppTheme.display(context)));
  }
}
class SessionReportsScreen extends StatelessWidget {
  const SessionReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Session Reports', style: AppTheme.display(context)));
  }
}
