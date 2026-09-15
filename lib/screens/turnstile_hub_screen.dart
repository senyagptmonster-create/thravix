import 'package:flutter/material.dart';
import '../theme/thravix_theme.dart';
import '../painters/turnstile_flow_painter.dart';
import 'hourly_throughput_screen.dart';

class TurnstileHubScreen extends StatefulWidget {
  const TurnstileHubScreen({super.key});

  @override
  State<TurnstileHubScreen> createState() => _TurnstileHubScreenState();
}

class _TurnstileHubScreenState extends State<TurnstileHubScreen> {
  int _currentOccupancy = 342;
  final int _maxCapacity = 500;
  double _rotorAngle = 0.0;

  void _recordEntry(int count) {
    setState(() {
      _currentOccupancy = (_currentOccupancy + count).clamp(0, _maxCapacity);
      _rotorAngle += 0.4;
    });
  }

  void _recordExit(int count) {
    setState(() {
      _currentOccupancy = (_currentOccupancy - count).clamp(0, _maxCapacity);
      _rotorAngle -= 0.4;
    });
  }

  void _resetSession() {
    setState(() {
      _currentOccupancy = 0;
      _rotorAngle = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fraction = _currentOccupancy / _maxCapacity;
    final isNearLimit = fraction >= 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('THRAVIX GATE FLOW', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HourlyThroughputScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Over-capacity banner if applicable
              if (isNearLimit)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThravixTheme.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThravixTheme.danger),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: ThravixTheme.danger),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'CAPACITY ALERT: Venue at 90%+ limit!',
                          style: TextStyle(color: ThravixTheme.danger, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              // Central Turnstile Flow Painter
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(
                    painter: TurnstileFlowPainter(
                      occupancyFraction: fraction,
                      rotorAngle: _rotorAngle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_currentOccupancy',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: ThravixTheme.ink,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            '/ $_maxCapacity MAX',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ThravixTheme.accent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Entry Controls (Green)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThravixTheme.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _recordEntry(1),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('+1 ENTRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThravixTheme.surface,
                          foregroundColor: ThravixTheme.success,
                          side: const BorderSide(color: ThravixTheme.success),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _recordEntry(5),
                        child: const Text('+5 Group', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Exit Controls (Amber)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThravixTheme.warning,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _recordExit(1),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('-1 EXIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThravixTheme.surface,
                          foregroundColor: ThravixTheme.warning,
                          side: const BorderSide(color: ThravixTheme.warning),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _recordExit(5),
                        child: const Text('-5 Group', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Reset & Hub Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _resetSession,
                    icon: const Icon(Icons.refresh, size: 16, color: ThravixTheme.muted),
                    label: const Text('Reset Session Tally', style: TextStyle(color: ThravixTheme.muted)),
                  ),
                  const SizedBox(width: 20),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HourlyThroughputScreen()),
                      );
                    },
                    icon: const Icon(Icons.show_chart, size: 16, color: ThravixTheme.accent),
                    label: const Text('Hourly Stats', style: TextStyle(color: ThravixTheme.accentLight)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
