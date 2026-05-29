import 'package:flutter/foundation.dart';

@immutable
class PaketGoConfig {
  const PaketGoConfig({
    required this.postgrestBaseUrl,
  });

  factory PaketGoConfig.fromEnvironment() {
    const configuredUrl = String.fromEnvironment(
      'PAKETGO_POSTGREST_URL',
      defaultValue: 'https://api.paketgo.com',
    );

    return const PaketGoConfig(postgrestBaseUrl: configuredUrl);
  }

  final String postgrestBaseUrl;

  Uri endpoint(String path, [Map<String, String>? queryParameters]) {
    final normalizedBaseUrl = postgrestBaseUrl.endsWith('/')
        ? postgrestBaseUrl.substring(0, postgrestBaseUrl.length - 1)
        : postgrestBaseUrl;

    return Uri.parse('$normalizedBaseUrl$path').replace(
      queryParameters: queryParameters,
    );
  }
}
