# otel_apigee

Dartastic OpenTelemetry bridge for Apigee (Google API management).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_apigee/otel_apigee.dart';

await tracedApigee<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return ApigeeCallResult(value: r, result: ApigeeResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutApigeeInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
