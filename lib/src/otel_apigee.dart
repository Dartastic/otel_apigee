// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_apigee_suppression.dart';

class ApigeeResult {
  const ApigeeResult({
    this.organization,
    this.environment,
    this.apiProxy,
    this.revision,
    this.targetEndpoint,
    this.flowName,
    this.developerApp,
    this.productName,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? organization;
  final String? environment;
  final String? apiProxy;
  final String? revision;
  final String? targetEndpoint;
  final String? flowName;
  final String? developerApp;
  final String? productName;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class ApigeeCallResult<T> {
  const ApigeeCallResult({required this.value, this.result});
  final T value;
  final ApigeeResult? result;
}

Future<T> tracedApigee<T>({
  required String operation,
  required Future<ApigeeCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (apigeeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_apigee');
  final span = t.startSpan('apigee $operation', kind: SpanKind.server);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('http.route', operation)]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.organization', res.organization!)]));
      }
      if (res.environment != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.environment', res.environment!)]));
      }
      if (res.apiProxy != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.api_proxy', res.apiProxy!)]));
      }
      if (res.revision != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.revision', res.revision!)]));
      }
      if (res.targetEndpoint != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('apigee.target.endpoint', res.targetEndpoint!)
        ]));
      }
      if (res.flowName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.flow.name', res.flowName!)]));
      }
      if (res.developerApp != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.developer.app', res.developerApp!)]));
      }
      if (res.productName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.product', res.productName!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('apigee.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'apigee.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
