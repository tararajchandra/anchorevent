import 'package:flutter_test/flutter_test.dart';
import 'package:services/services.dart';

void main() {
  test('RestApi isCloudConfigured is true by default', () {
    expect(RestApi.instance.isCloudConfigured, isTrue);
  });
}
