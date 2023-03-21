class ChartData {
  ChartData(
      {required this.humidity,
      required this.outsideTemp,
      required this.speed,
      required this.temperature,
      required this.timestamp});
  final int humidity;
  final double outsideTemp;
  final double speed;
  final double temperature;
  final DateTime timestamp;

  factory ChartData.fromRTDB(Map<String, dynamic> data) {
    return ChartData(
        humidity: data["humidity"],
        outsideTemp: data['outsideTemp'],
        speed: data['speed'] / 10,
        temperature: data['temperature'],
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000));
  }
}
