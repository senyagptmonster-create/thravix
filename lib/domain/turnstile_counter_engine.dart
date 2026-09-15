enum CapacityStatus {
  normal('Normal Occupancy', 0.0),
  warning('Approaching Capacity (80%+)', 0.80),
  critical('Critical Threshold (95%+)', 0.95),
  breached('CAPACITY EXCEEDED', 1.0);

  final String label;
  final double thresholdRatio;

  const CapacityStatus(this.label, this.thresholdRatio);
}

class HourlyThroughputBucket {
  final int hour; // 0 to 23
  int inCount;
  int outCount;

  HourlyThroughputBucket({
    required this.hour,
    this.inCount = 0,
    this.outCount = 0,
  });

  int get netFlow => inCount - outCount;
  int get totalVolume => inCount + outCount;

  Map<String, dynamic> toMap() => {
        'hour': hour,
        'inCount': inCount,
        'outCount': outCount,
      };

  factory HourlyThroughputBucket.fromMap(Map<String, dynamic> map) =>
      HourlyThroughputBucket(
        hour: map['hour'] as int? ?? 0,
        inCount: map['inCount'] as int? ?? 0,
        outCount: map['outCount'] as int? ?? 0,
      );
}

class GateSessionReport {
  final String id;
  final String sessionName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalIn;
  final int totalOut;
  final int peakOccupancy;
  final int maxCapacityConfigured;

  GateSessionReport({
    required this.id,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    required this.totalIn,
    required this.totalOut,
    required this.peakOccupancy,
    required this.maxCapacityConfigured,
  });

  int get netRemaining => totalIn - totalOut;
  double get capacityUtilization =>
      maxCapacityConfigured > 0 ? (peakOccupancy / maxCapacityConfigured) * 100 : 0.0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionName': sessionName,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalIn': totalIn,
        'totalOut': totalOut,
        'peakOccupancy': peakOccupancy,
        'maxCapacityConfigured': maxCapacityConfigured,
      };

  factory GateSessionReport.fromMap(Map<String, dynamic> map) =>
      GateSessionReport(
        id: map['id'] as String? ?? '',
        sessionName: map['sessionName'] as String? ?? 'General Gate Session',
        startTime: map['startTime'] != null
            ? DateTime.tryParse(map['startTime'] as String) ?? DateTime.now()
            : DateTime.now(),
        endTime: map['endTime'] != null
            ? DateTime.tryParse(map['endTime'] as String) ?? DateTime.now()
            : DateTime.now(),
        totalIn: map['totalIn'] as int? ?? 0,
        totalOut: map['totalOut'] as int? ?? 0,
        peakOccupancy: map['peakOccupancy'] as int? ?? 0,
        maxCapacityConfigured: map['maxCapacityConfigured'] as int? ?? 100,
      );
}

class TurnstileCounterEngine {
  static CapacityStatus evaluateCapacity(int currentOccupancy, int maxCapacity) {
    if (maxCapacity <= 0) return CapacityStatus.normal;
    final ratio = currentOccupancy / maxCapacity;
    if (ratio >= 1.0) return CapacityStatus.breached;
    if (ratio >= 0.95) return CapacityStatus.critical;
    if (ratio >= 0.80) return CapacityStatus.warning;
    return CapacityStatus.normal;
  }

  static double calculateOccupancyRatio(int currentOccupancy, int maxCapacity) {
    if (maxCapacity <= 0) return 0.0;
    return (currentOccupancy / maxCapacity).clamp(0.0, 1.5);
  }
}
