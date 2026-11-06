import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory(
    Platform.environment['CAPTURE_OUTPUT_DIR'] ?? 'build/store-captures',
  );
  await output.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('${output.path}/$name.png').writeAsBytes(bytes, flush: true);
      return true;
    },
    responseDataCallback: (_) async {},
  );
}
