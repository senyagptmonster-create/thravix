import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/turnstile_history_repository.dart';
import '../../domain/turnstile_counter_engine.dart';

class GateCounterPage extends StatelessWidget {
  const GateCounterPage({super.key});

  void _triggerHaptic(BuildContext context, TurnstileHistoryRepository repo) {
    if (repo.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void _showArchiveDialog(BuildContext context, TurnstileHistoryRepository repo) {
    final nameCtrl = TextEditingController(text: 'Shift ${DateTime.now().hour}:00');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161E2E),
        title: const Text('Close & Save Shift Session', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Archiving will record total IN/OUT statistics to the Session Reports ledger and reset the turnstile gate counter to 0.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Shift / Event Label'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              repo.archiveCurrentSession(nameCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift session saved to Reports!')),
              );
            },
            child: const Text('Archive & Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TurnstileHistoryRepository>();
    final net = repo.netOccupancy;
    final max = repo.maxCapacity;
    final ratio = repo.occupancyRatio;
    final status = repo.status;

    Color statusColor;
    switch (status) {
      case CapacityStatus.normal:
        statusColor = const Color(0xFF10B981); // Emerald
        break;
      case CapacityStatus.warning:
        statusColor = const Color(0xFFF59E0B); // Amber
        break;
      case CapacityStatus.critical:
        statusColor = const Color(0xFFF97316); // Orange
        break;
      case CapacityStatus.breached:
        statusColor = const Color(0xFFEF4444); // Red alert
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111E),
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensor_door_outlined, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text('Turnstile Access Gate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Archive Shift Session',
            icon: const Icon(Icons.archive_outlined, color: Color(0xFF38BDF8)),
            onPressed: () => _showArchiveDialog(context, repo),
          ),
          IconButton(
            tooltip: 'Reset Counters',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF161E2E),
                  title: const Text('Reset Live Counter?', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'This will reset the active IN and OUT counters without saving.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        repo.resetCounterOnly();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Venue Status & Occupancy Gauge Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141D2B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: status == CapacityStatus.breached ? Colors.redAccent : const Color(0xFF26354A),
                  width: status == CapacityStatus.breached ? 2 : 1,
                ),
                boxShadow: [
                  if (status == CapacityStatus.breached)
                    BoxShadow(
                      color: Colors.redAccent.withAlpha(50),
                      blurRadius: 16,
                    ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Limit: $max',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Huge Net Occupancy Number
                  Text(
                    '$net',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const Text(
                    'CURRENT NET OCCUPANCY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Capacity progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(ratio * 100).toStringAsFixed(1)}% Venue Capacity',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        'Peak Today: ${repo.peakOccupancy}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Secondary Quick Batch Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBatchChip(context, repo, '+5 IN', 5, true),
                  _buildBatchChip(context, repo, '+10 IN', 10, true),
                  _buildBatchChip(context, repo, '-5 OUT', 5, false),
                  _buildBatchChip(context, repo, '-10 OUT', 10, false),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Large Tactile IN / OUT Tap Pads
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Massive IN Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _triggerHaptic(context, repo);
                          repo.registerIn(count: 1);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF059669), Color(0xFF047857)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withAlpha(80),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF34D399), width: 2),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_downward_rounded, size: 40, color: Colors.white),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'ENTRY',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '+ IN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(60),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Total: ${repo.inCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Massive OUT Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _triggerHaptic(context, repo);
                          repo.registerOut(count: 1);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withAlpha(80),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFF87171), width: 2),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_upward_rounded, size: 40, color: Colors.white),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'EXIT',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '- OUT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(60),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Total: ${repo.outCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchChip(
    BuildContext context,
    TurnstileHistoryRepository repo,
    String label,
    int amount,
    bool isIn,
  ) {
    return InkWell(
      onTap: () {
        if (isIn) {
          repo.registerIn(count: amount);
        } else {
          repo.registerOut(count: amount);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF172130),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isIn ? const Color(0xFF10B981).withAlpha(80) : const Color(0xFFEF4444).withAlpha(80),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isIn ? const Color(0xFF34D399) : const Color(0xFFF87171),
          ),
        ),
      ),
    );
  }
}
