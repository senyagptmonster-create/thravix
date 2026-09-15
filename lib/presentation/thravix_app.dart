import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/turnstile_history_repository.dart';
import 'pages/capacity_alerts_page.dart';
import 'pages/gate_counter_page.dart';
import 'pages/hourly_throughput_page.dart';
import 'pages/session_reports_page.dart';

class ThravixGateApp extends StatelessWidget {
  const ThravixGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TurnstileHistoryRepository(),
      child: MaterialApp(
        title: 'Thravix Gate Access',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B111E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF10B981),
            secondary: Color(0xFF06B6D4),
            surface: Color(0xFF141D2B),
            onSurface: Colors.white,
            error: Color(0xFFEF4444),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF141D2B),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF26354A)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A2637),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        home: const ThravixHomeScaffold(),
      ),
    );
  }
}

class ThravixHomeScaffold extends StatefulWidget {
  const ThravixHomeScaffold({super.key});

  @override
  State<ThravixHomeScaffold> createState() => _ThravixHomeScaffoldState();
}

class _ThravixHomeScaffoldState extends State<ThravixHomeScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    GateCounterPage(),
    HourlyThroughputPage(),
    CapacityAlertsPage(),
    SessionReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF0E1624),
        indicatorColor: const Color(0xFF10B981).withAlpha(50),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sensor_door_outlined),
            selectedIcon: Icon(Icons.sensor_door, color: Color(0xFF10B981)),
            label: 'Gate',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF06B6D4)),
            label: 'Throughput',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_on_outlined),
            selectedIcon: Icon(Icons.alarm_on, color: Color(0xFFF59E0B)),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF38BDF8)),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
