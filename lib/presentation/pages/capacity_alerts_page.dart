import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/turnstile_history_repository.dart';

class CapacityAlertsPage extends StatefulWidget {
  const CapacityAlertsPage({super.key});

  @override
  State<CapacityAlertsPage> createState() => _CapacityAlertsPageState();
}

class _CapacityAlertsPageState extends State<CapacityAlertsPage> {
  bool _alarmTestActive = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TurnstileHistoryRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111E),
        elevation: 0,
        title: const Text('Capacity & Visual Alarms', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Test Alarm Banner
              if (_alarmTestActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 36, color: Colors.redAccent),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ALARM TEST ACTIVE',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Visual and sensory warning alert triggered.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _alarmTestActive = false),
                      ),
                    ],
                  ),
                ),

              // Max Venue Capacity Setting
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26354A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.meeting_room_outlined, color: Color(0xFF38BDF8), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Maximum Venue Capacity',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Strict legal or fire code occupancy ceiling for this gate zone.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Limit:', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text(
                          '${repo.maxCapacity} people',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: repo.maxCapacity.toDouble(),
                      min: 50,
                      max: 2500,
                      divisions: 49,
                      activeColor: const Color(0xFF38BDF8),
                      inactiveColor: const Color(0xFF1E293B),
                      onChanged: (val) {
                        repo.updateMaxCapacity(val.toInt());
                      },
                    ),
                    // Quick Presets
                    Wrap(
                      spacing: 8,
                      children: [100, 250, 500, 1000, 2000].map((cap) {
                        return ActionChip(
                          backgroundColor: repo.maxCapacity == cap
                              ? const Color(0xFF38BDF8).withAlpha(40)
                              : const Color(0xFF172130),
                          side: BorderSide(
                            color: repo.maxCapacity == cap ? const Color(0xFF38BDF8) : const Color(0xFF26354A),
                          ),
                          label: Text('$cap', style: const TextStyle(fontSize: 11, color: Colors.white)),
                          onPressed: () => repo.updateMaxCapacity(cap),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Thresholds Configuration Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26354A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune_outlined, color: Color(0xFFF59E0B), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Alert Trigger Thresholds',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Warning Threshold
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Warning Level (Amber)', style: TextStyle(color: Color(0xFFF59E0B))),
                        Text(
                          '${repo.warningThresholdPct}% (${(repo.maxCapacity * repo.warningThresholdPct / 100).round()} people)',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                    Slider(
                      value: repo.warningThresholdPct.toDouble(),
                      min: 60,
                      max: 90,
                      divisions: 6,
                      activeColor: const Color(0xFFF59E0B),
                      inactiveColor: const Color(0xFF1E293B),
                      onChanged: (val) {
                        repo.updateThresholds(val.toInt(), repo.criticalThresholdPct);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Critical Threshold
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Critical Limit (Red)', style: TextStyle(color: Color(0xFFEF4444))),
                        Text(
                          '${repo.criticalThresholdPct}% (${(repo.maxCapacity * repo.criticalThresholdPct / 100).round()} people)',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                    Slider(
                      value: repo.criticalThresholdPct.toDouble(),
                      min: 80,
                      max: 99,
                      divisions: 19,
                      activeColor: const Color(0xFFEF4444),
                      inactiveColor: const Color(0xFF1E293B),
                      onChanged: (val) {
                        repo.updateThresholds(repo.warningThresholdPct, val.toInt());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Hardware Feedback Settings
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26354A)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Haptic Vibration Feedback', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Physical buzz upon every IN / OUT turnstile click', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      value: repo.hapticEnabled,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (val) => repo.toggleHaptic(val),
                    ),
                    const Divider(height: 1, color: Color(0xFF26354A)),
                    ListTile(
                      title: const Text('Test Visual Strobe Alarm', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Simulate high-capacity strobe alert in UI', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _alarmTestActive ? Colors.grey : const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _alarmTestActive = !_alarmTestActive;
                          });
                        },
                        child: Text(_alarmTestActive ? 'Stop Test' : 'Test Strobe'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
