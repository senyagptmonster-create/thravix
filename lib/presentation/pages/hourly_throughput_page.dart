import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/turnstile_history_repository.dart';
import '../../domain/turnstile_counter_engine.dart';

class HourlyThroughputPage extends StatelessWidget {
  const HourlyThroughputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TurnstileHistoryRepository>();
    final buckets = repo.hourlyBuckets;

    int maxVolume = 1;
    HourlyThroughputBucket? peakBucket;

    for (final b in buckets) {
      if (b.totalVolume > maxVolume) {
        maxVolume = b.totalVolume;
      }
      if (peakBucket == null || b.totalVolume > peakBucket.totalVolume) {
        peakBucket = b;
      }
    }

    final totalDayTraffic = repo.inCount + repo.outCount;
    final avgHourly = (totalDayTraffic / buckets.length).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111E),
        elevation: 0,
        title: const Text('Hourly Throughput', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary KPI Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'TOTAL VOLUME',
                      '$totalDayTraffic',
                      'Turnstile cycles',
                      const Color(0xFF06B6D4),
                      Icons.swap_vert_circle_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      'PEAK HOUR',
                      peakBucket != null && peakBucket.totalVolume > 0
                          ? '${peakBucket.hour}:00'
                          : '--:--',
                      '${peakBucket?.totalVolume ?? 0} people',
                      const Color(0xFFF59E0B),
                      Icons.access_time_filled,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      'HOURLY AVG',
                      avgHourly,
                      'Flow rate',
                      const Color(0xFF10B981),
                      Icons.speed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Chart Container
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
                    Row(
                      children: [
                        const Icon(Icons.bar_chart, color: Color(0xFF06B6D4), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Entry vs Exit Flow (6:00 - 22:00)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Spacer(),
                        // Legend
                        _buildLegendItem('IN', const Color(0xFF10B981)),
                        const SizedBox(width: 10),
                        _buildLegendItem('OUT', const Color(0xFFEF4444)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Scrollable Bar Graph
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: buckets.map((bucket) {
                            final inRatio = bucket.inCount / maxVolume;
                            final outRatio = bucket.outCount / maxVolume;
                            final inBarHeight = (inRatio * 130).clamp(4.0, 130.0);
                            final outBarHeight = (outRatio * 130).clamp(4.0, 130.0);
                            final isCurrentHour = bucket.hour == DateTime.now().hour;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // IN bar
                                      Container(
                                        width: 10,
                                        height: inBarHeight,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      // OUT bar
                                      Container(
                                        width: 10,
                                        height: outBarHeight,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isCurrentHour ? const Color(0xFF06B6D4) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${bucket.hour}h',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                                        color: isCurrentHour ? Colors.black : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Hourly breakdown ledger
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF26354A)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A2637),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('HOUR', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text('IN', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text('OUT', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(child: Text('NET', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    ...buckets.where((b) => b.totalVolume > 0).map((b) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF1F2B3E))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('${b.hour}:00 - ${b.hour + 1}:00', style: const TextStyle(fontSize: 13, color: Colors.white)),
                            ),
                            Expanded(child: Text('+${b.inCount}', style: const TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                            Expanded(child: Text('-${b.outCount}', style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                            Expanded(
                              child: Text(
                                b.netFlow >= 0 ? '+${b.netFlow}' : '${b.netFlow}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (buckets.every((b) => b.totalVolume == 0))
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No visitor gate activity recorded yet today.',
                          style: TextStyle(color: Color(0xFF64748B)),
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

  Widget _buildMetricTile(String label, String value, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26354A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
