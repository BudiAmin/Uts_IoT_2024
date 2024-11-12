import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final String broker = 'broker.hivemq.com'; // Ganti dengan broker Anda
  final String topic =
      'hydroponic/sensor'; // Topik MQTT untuk menerima data sensor

  // Fungsi untuk menghubungkan ke broker MQTT
  Future<void> connect() async {
    client = MqttServerClient(broker, 'flutter_client');
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.autoReconnect = true; // Mengaktifkan auto reconnect
    client.resubscribeOnAutoReconnect =
        true; // Resubscribe ke topik setelah reconnect
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onDisconnected = onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean();
    client.connectionMessage = connMess;

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('Successfully connected to MQTT broker');
      } else {
        print('Failed to connect, status: ${client.connectionStatus}');
        client.disconnect();
      }
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
      client.disconnect();
    }
  }

  // Callback ketika terhubung ke broker
  void onConnected() {
    print('Connected to MQTT broker');
    client.subscribe(topic, MqttQos.atMostOnce); // Berlangganan ke topik
  }

  // Callback ketika berhasil berlangganan topik
  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  // Callback ketika koneksi terputus
  void onDisconnected() {
    print('Disconnected from MQTT broker. Trying to reconnect...');
    Future.delayed(Duration(seconds: 5), () {
      connect(); // Coba reconnect setelah 5 detik
    });
  }

  // Fungsi untuk menerima pesan dari broker MQTT
  void listenToMessages(Function(String) onMessageReceived) {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage message = event[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      onMessageReceived(payload); // Kirim data ke UI
    });
  }

  // Fungsi untuk menutup koneksi MQTT
  void disconnect() {
    client.disconnect();
  }
}
