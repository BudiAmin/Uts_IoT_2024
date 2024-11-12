import 'package:flutter_test/flutter_test.dart';
import 'package:uts_iot/main.dart'; // Ganti dengan jalur ke main.dart Anda

void main() {
  testWidgets('Test app widget', (WidgetTester tester) async {
    // Memuat widget utama aplikasi
    await tester.pumpWidget(MyApp());

    // Tambahkan tes lainnya sesuai kebutuhan
  });
}
