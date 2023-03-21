import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where  you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<_ChartData> _ListChartData = [];
  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final _database = FirebaseDatabase.instance.ref();
  late StreamSubscription _streamSubscription;

  @override
  void initState(){
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    _streamSubscription = _database.child("Log").onValue.listen((event) {
      var data;
      // List<_ChartData> newData = [];
      for (final child in event.snapshot.children) {
        data = child.value as Map<String, dynamic>;
        _ListChartData.add(_ChartData.fromRTDB(data));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                child: SfCartesianChart(

                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(text: 'Temperature graph'),
                    // Enable legend
                    legend: Legend(isVisible: true),
                    // Enable tooltip
                    tooltipBehavior: _tooltipBehavior,

                    series: <LineSeries<_ChartData, DateTime>>[
                      LineSeries<_ChartData, DateTime>(
                          dataSource:  _ListChartData,
                          xValueMapper: (_ChartData data, _) => data.timestamp,
                          yValueMapper: (_ChartData data, _) => data.temperature,
                          color: Colors.blue,
                      ),
                      LineSeries<_ChartData, DateTime>(
                          dataSource:  _ListChartData,
                          xValueMapper: (_ChartData data, _) => data.timestamp,
                          yValueMapper: (_ChartData data, _) => data.speed / 10,
                          color: Colors.red,
                      )
                    ]
                )
            )
        )
    );
  }

  @override
  void deactivate() {
    _streamSubscription.cancel();
    super.deactivate();
  }
}

class _ChartData {
  _ChartData({required this.humidity, required this.outsideTemp,
    required this.speed, required this.temperature, required this.timestamp});
  final int humidity;
  final double outsideTemp;
  final int speed;
  final double temperature;
  final DateTime timestamp;

  factory _ChartData.fromRTDB(Map<String, dynamic> data) {
    return _ChartData(humidity: data["humidity"], outsideTemp: data['outsideTemp'],
        speed: data['speed'], temperature: data['temperature'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000));
  }
}
