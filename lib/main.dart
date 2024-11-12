import 'package:flutter/material.dart';
import 'mqtt_service.dart'; // Import file MqttService
import 'dart:convert';
import 'models/sensor_data.dart'; // Import model SensorData
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion Chart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Data Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SensorDataScreen(),
    );
  }
}

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  late MqttService mqttService;
  List<SensorData> sensorDataList = []; // Store historical data for chart

  SensorData sensorData = SensorData(
    suhu: 0.0,
    kelembapan: 0.0,
    kekeruhan: 0.0,
    ph: 0.0,
    timestamp: DateTime.now().toString(),
  );

  @override
  void initState() {
    super.initState();
    mqttService = MqttService();
    mqttService.connect();
    mqttService.listenToMessages((message) {
      setState(() {
        final decodedMessage = json.decode(message);
        sensorData = SensorData.fromJson(decodedMessage);
        sensorDataList.add(sensorData);

        // Keep only the last 20 records for better performance
        if (sensorDataList.length > 20) {
          sensorDataList.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensor Data')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.2, // Mengatur ukuran tile agar lebih kecil
                children: [
                  _buildSensorTile(
                    icon: Icons.thermostat,
                    label: 'Suhu',
                    value: '${sensorData.suhu}°C',
                  ),
                  _buildSensorTile(
                    icon: Icons.water_drop,
                    label: 'Kelembapan',
                    value: '${sensorData.kelembapan}%',
                  ),
                  _buildSensorTile(
                    icon: Icons.opacity,
                    label: 'Kekeruhan',
                    value: '${sensorData.kekeruhan}',
                  ),
                  _buildSensorTile(
                    icon: Icons.science,
                    label: 'pH',
                    value: '${sensorData.ph}',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2, // Mengurangi tinggi grafik agar proporsi lebih kecil
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Timestamp'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Sensor Values'),
                ),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  LineSeries<SensorData, String>(
                    name: 'Suhu',
                    dataSource: sensorDataList,
                    xValueMapper: (SensorData data, _) => data.timestamp,
                    yValueMapper: (SensorData data, _) => data.suhu,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<SensorData, String>(
                    name: 'Kelembapan',
                    dataSource: sensorDataList,
                    xValueMapper: (SensorData data, _) => data.timestamp,
                    yValueMapper: (SensorData data, _) => data.kelembapan,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<SensorData, String>(
                    name: 'Kekeruhan',
                    dataSource: sensorDataList,
                    xValueMapper: (SensorData data, _) => data.timestamp,
                    yValueMapper: (SensorData data, _) => data.kekeruhan,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                  LineSeries<SensorData, String>(
                    name: 'pH',
                    dataSource: sensorDataList,
                    xValueMapper: (SensorData data, _) => data.timestamp,
                    yValueMapper: (SensorData data, _) => data.ph,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Menjaga warna background tetap putih
    );
  }

  Widget _buildSensorTile(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[100], // Mengubah warna tile menjadi hijau muda
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 40, color: Colors.green), // Mengubah ikon menjadi hijau
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
