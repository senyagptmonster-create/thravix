import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/turnstile_history_repository.dart';
import '../../domain/turnstile_counter_engine.dart';

class SessionReportsPage extends StatelessWidget {
  const SessionReportsPage({super.key});

  void _exportSessionText(BuildContext context, GateSessionReport report) {
    final csv = 'Session: ${report.sessionName}\n'
        'Start: ${report.startTime.toLocal()}\n'
        'End: ${report.endTime.toLocal()}\n'
        'Total IN: ${report.totalIn}\n'
        'Total OUT: ${report.totalOut}\n'
        'Peak Occupancy: ${report.peakOccupancy}\n'
        'Max Configured: ${report.maxCapacityConfigured}\n'
        'Utilization: ${report.capacityUtilization.toStringAsFixed(1)}%';

    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session report copied to clipboard!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TurnstileHistoryRepository>();
    final sessions = repo.pastSessions;

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111E),
        elevation: 0,
        title: const Text('Gate Session Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 54, color: Colors.blueGrey.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      'No Archived Shift Sessions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When a gate shift concludes, tap the archive icon\non the Counter screen to generate a certified report.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final duration = s.endTime.difference(s.startTime);
                  final hours = duration.inHours;
                  final minutes = duration.inMinutes % 60;
                  final dateStr =
                      '${s.startTime.month}/${s.startTime.day} • ${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')} - ${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141D2B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF26354A)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.sessionName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                                color: const Color(0xFF1E293B),
                                onSelected: (action) {
                                  if (action == 'copy') {
                                    _exportSessionText(context, s);
                                  } else if (action == 'delete') {
                                    repo.deleteSessionReport(s.id);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy, size: 16, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Copy Summary', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFF1E293B)),
                          const SizedBox(height: 12),
                          // Stats grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildReportStat('IN', '+${s.totalIn}', const Color(0xFF10B981)),
                              _buildReportStat('OUT', '-${s.totalOut}', const Color(0xFFEF4444)),
                              _buildReportStat('PEAK', '${s.peakOccupancy}', const Color(0xFFF59E0B)),
                              _buildReportStat('UTILIZATION', '${s.capacityUtilization.toStringAsFixed(0)}%', const Color(0xFF38BDF8)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shift Duration: ${hours}h ${minutes}m',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF38BDF8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                ),
                                onPressed: () => _exportSessionText(context, s),
                                icon: const Icon(Icons.share, size: 14, color: Color(0xFF38BDF8)),
                                label: const Text('Export', style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildReportStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
