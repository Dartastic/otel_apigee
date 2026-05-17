// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_apigee/otel_apigee.dart';
import 'package:test/test.dart';

void main() {
  group('otel_apigee', () {
    test('suppression toggles in zone', () async {
      expect(apigeeInstrumentationSuppressed(), isFalse);
      await runWithoutApigeeInstrumentationAsync(() async {
        expect(apigeeInstrumentationSuppressed(), isTrue);
      });
      expect(apigeeInstrumentationSuppressed(), isFalse);
    });

    test('ApigeeResult fields default null', () {
      const r = ApigeeResult();
      expect(r.statusCode, isNull);
    });
  });
}
