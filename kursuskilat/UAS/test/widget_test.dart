import 'package:flutter_test/flutter_test.dart';
import 'package:kursuskilat/app.dart';

void main() {
  testWidgets('kursuskilat smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyStoreApp()); // ← pakai MyStoreApp
    expect(find.text('kursuskilat'), findsNothing);
  });
}