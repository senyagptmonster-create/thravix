import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/turnstile_counter_engine.dart';

class TurnstileHistoryRepository extends ChangeNotifier {
  static const String _keyIn = 'thravix_in_count_v1';
  static const String _keyOut = 'thravix_out_count_v1';
  static const String _keyCap = 'thravix_max_capacity_v1';
  static const String _keyWarnPct = 'thravix_warn_pct_v1';
  static const String _keyCritPct = 'thravix_crit_pct_v1';
  static const String _keyPeak = 'thravix_peak_occupancy_v1';
  static const String _keyStart = 'thravix_session_start_v1';
  static const String _keyHourly = 'thravix_hourly_buckets_v1';
  static const String _keySessions = 'thravix_past_sessions_v1';
  static const String _keyHaptic = 'thravix_haptic_v1';

  int _inCount = 0;
  int _outCount = 0;
  int _maxCapacity = 250;
  int _warningThresholdPct = 80;
  int _criticalThresholdPct = 95;
  int _peakOccupancy = 0;
  DateTime _sessionStart = DateTime.now();
  bool _hapticEnabled = true;

  final Map<int, HourlyThroughputBucket> _hourlyBuckets = {};
  List<GateSessionReport> _pastSessions = [];
  bool _isLoaded = false;

  int get inCount => _inCount;
  int get outCount => _outCount;
  int get netOccupancy => (_inCount - _outCount).clamp(0, 999999);
  int get maxCapacity => _maxCapacity;
  int get warningThresholdPct => _warningThresholdPct;
  int get criticalThresholdPct => _criticalThresholdPct;
  int get peakOccupancy => _peakOccupancy;
  DateTime get sessionStart => _sessionStart;
  bool get hapticEnabled => _hapticEnabled;
  bool get isLoaded => _isLoaded;
  List<GateSessionReport> get pastSessions => List.unmodifiable(_pastSessions);

  CapacityStatus get status =>
      TurnstileCounterEngine.evaluateCapacity(netOccupancy, _maxCapacity);

  double get occupancyRatio =>
      TurnstileCounterEngine.calculateOccupancyRatio(netOccupancy, _maxCapacity);

  List<HourlyThroughputBucket> get hourlyBuckets {
    final list = <HourlyThroughputBucket>[];
    for (int h = 6; h <= 22; h++) {
      list.add(_hourlyBuckets[h] ?? HourlyThroughputBucket(hour: h));
    }
    return list;
  }

  TurnstileHistoryRepository() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _inCount = prefs.getInt(_keyIn) ?? 142;
    _outCount = prefs.getInt(_keyOut) ?? 89;
    _maxCapacity = prefs.getInt(_keyCap) ?? 250;
    _warningThresholdPct = prefs.getInt(_keyWarnPct) ?? 80;
    _criticalThresholdPct = prefs.getInt(_keyCritPct) ?? 95;
    _peakOccupancy = prefs.getInt(_keyPeak) ?? 78;
    _hapticEnabled = prefs.getBool(_keyHaptic) ?? true;

    final startStr = prefs.getString(_keyStart);
    if (startStr != null) {
      _sessionStart = DateTime.tryParse(startStr) ?? DateTime.now();
    }

    final rawHourly = prefs.getString(_keyHourly);
    if (rawHourly != null && rawHourly.isNotEmpty) {
      final List<dynamic> decoded = json.decode(rawHourly) as List<dynamic>;
      for (final item in decoded) {
        final bucket = HourlyThroughputBucket.fromMap(item as Map<String, dynamic>);
        _hourlyBuckets[bucket.hour] = bucket;
      }
    } else {
      // Seed default today hourly stats
      _seedDefaultHourly();
    }

    final rawSessions = prefs.getStringList(_keySessions);
    if (rawSessions != null && rawSessions.isNotEmpty) {
      _pastSessions = rawSessions
          .map((s) => GateSessionReport.fromMap(json.decode(s) as Map<String, dynamic>))
          .toList();
    } else {
      // Seed starter session reports
      _pastSessions = [
        GateSessionReport(
          id: 'sess_1',
          sessionName: 'Morning Exhibition Shift',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          totalIn: 380,
          totalOut: 365,
          peakOccupancy: 215,
          maxCapacityConfigured: 250,
        ),
        GateSessionReport(
          id: 'sess_2',
          sessionName: 'Evening Gala Entry Gate',
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
          endTime: DateTime.now().subtract(const Duration(days: 2)),
          totalIn: 245,
          totalOut: 240,
          peakOccupancy: 230,
          maxCapacityConfigured: 250,
        ),
      ];
    }

    _isLoaded = true;
    notifyListeners();
  }

  void _seedDefaultHourly() {
    _hourlyBuckets[8] = HourlyThroughputBucket(hour: 8, inCount: 15, outCount: 2);
    _hourlyBuckets[9] = HourlyThroughputBucket(hour: 9, inCount: 32, outCount: 8);
    _hourlyBuckets[10] = HourlyThroughputBucket(hour: 10, inCount: 28, outCount: 12);
    _hourlyBuckets[11] = HourlyThroughputBucket(hour: 11, inCount: 20, outCount: 22);
    _hourlyBuckets[12] = HourlyThroughputBucket(hour: 12, inCount: 24, outCount: 20);
    _hourlyBuckets[13] = HourlyThroughputBucket(hour: 13, inCount: 14, outCount: 15);
    _hourlyBuckets[14] = HourlyThroughputBucket(hour: 14, inCount: 9, outCount: 10);
  }

  Future<void> _saveState([SharedPreferences? instance]) async {
    final prefs = instance ?? await SharedPreferences.getInstance();
    await prefs.setInt(_keyIn, _inCount);
    await prefs.setInt(_keyOut, _outCount);
    await prefs.setInt(_keyCap, _maxCapacity);
    await prefs.setInt(_keyWarnPct, _warningThresholdPct);
    await prefs.setInt(_keyCritPct, _criticalThresholdPct);
    await prefs.setInt(_keyPeak, _peakOccupancy);
    await prefs.setString(_keyStart, _sessionStart.toIso8601String());
    await prefs.setBool(_keyHaptic, _hapticEnabled);

    final hourlyList = _hourlyBuckets.values.map((b) => b.toMap()).toList();
    await prefs.setString(_keyHourly, json.encode(hourlyList));

    final sessionList =
        _pastSessions.map((s) => json.encode(s.toMap())).toList();
    await prefs.setStringList(_keySessions, sessionList);
  }

  Future<void> registerIn({int count = 1}) async {
    _inCount += count;
    final curOcc = netOccupancy;
    if (curOcc > _peakOccupancy) {
      _peakOccupancy = curOcc;
    }

    final currentHour = DateTime.now().hour;
    final bucket = _hourlyBuckets.putIfAbsent(
      currentHour,
      () => HourlyThroughputBucket(hour: currentHour),
    );
    bucket.inCount += count;

    await _saveState();
    notifyListeners();
  }

  Future<void> registerOut({int count = 1}) async {
    if (_inCount - _outCount <= 0) return; // Cannot have negative visitors
    _outCount += count;

    final currentHour = DateTime.now().hour;
    final bucket = _hourlyBuckets.putIfAbsent(
      currentHour,
      () => HourlyThroughputBucket(hour: currentHour),
    );
    bucket.outCount += count;

    await _saveState();
    notifyListeners();
  }

  Future<void> updateMaxCapacity(int newCapacity) async {
    _maxCapacity = newCapacity.clamp(10, 50000);
    await _saveState();
    notifyListeners();
  }

  Future<void> updateThresholds(int warnPct, int critPct) async {
    _warningThresholdPct = warnPct.clamp(50, 90);
    _criticalThresholdPct = critPct.clamp(80, 99);
    await _saveState();
    notifyListeners();
  }

  Future<void> toggleHaptic(bool enabled) async {
    _hapticEnabled = enabled;
    await _saveState();
    notifyListeners();
  }

  Future<void> archiveCurrentSession(String sessionName) async {
    final report = GateSessionReport(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      sessionName: sessionName.trim().isEmpty ? 'Shift at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}' : sessionName.trim(),
      startTime: _sessionStart,
      endTime: DateTime.now(),
      totalIn: _inCount,
      totalOut: _outCount,
      peakOccupancy: _peakOccupancy,
      maxCapacityConfigured: _maxCapacity,
    );

    _pastSessions.insert(0, report);
    _inCount = 0;
    _outCount = 0;
    _peakOccupancy = 0;
    _sessionStart = DateTime.now();
    _hourlyBuckets.clear();

    await _saveState();
    notifyListeners();
  }

  Future<void> resetCounterOnly() async {
    _inCount = 0;
    _outCount = 0;
    _peakOccupancy = 0;
    _sessionStart = DateTime.now();
    _hourlyBuckets.clear();
    await _saveState();
    notifyListeners();
  }

  Future<void> deleteSessionReport(String id) async {
    _pastSessions.removeWhere((s) => s.id == id);
    await _saveState();
    notifyListeners();
  }
}
