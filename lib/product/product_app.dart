import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/brand.dart';
import 'screens.dart';
import 'thravix_store.dart';

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  _ProductAppState createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  Widget _current = GateCounterScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThravixStore()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Thravix',
        home: Scaffold(
          backgroundColor: cBg,
          appBar: AppBar(backgroundColor: cSurface, title: Text('Thravix', style: TextStyle(color: cInk))),
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(title: Text('Counter'), onTap: () { if (mounted) { setState(() => _current = GateCounterScreen()); } Navigator.pop(context); }),
                ListTile(title: Text('Throughput'), onTap: () { if (mounted) { setState(() => _current = HourlyChartScreen()); } Navigator.pop(context); }),
                ListTile(title: Text('Capacity Alerts'), onTap: () { if (mounted) { setState(() => _current = CapacityAlertScreen()); } Navigator.pop(context); }),
                ListTile(title: Text('Session Reports'), onTap: () { if (mounted) { setState(() => _current = SessionReportsScreen()); } Navigator.pop(context); }),
              ],
            ),
          ),
          body: _current,
        ),
      ),
    );
  }
}
