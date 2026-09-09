import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class WebSearchResult {
  const WebSearchResult(this.title, this.url, this.snippet);

  final String title;
  final String url;
  final String snippet;
}

abstract interface class WebSearchProvider {
  Future<List<WebSearchResult>> search(String query);
}

class WebSearchService {
  WebSearchService({required this.provider});

  final WebSearchProvider provider;

  Future<List<WebSearchResult>> search(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(query, 'query', 'A search query is required.');
    }
    return provider.search(normalized);
  }
}

class DuckDuckGoSearchProvider implements WebSearchProvider {
  DuckDuckGoSearchProvider({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  @override
  Future<List<WebSearchResult>> search(String query) async {
    final uri = Uri.https(
      'api.duckduckgo.com',
      '/',
      <String, String>{
        'q': query,
        'format': 'json',
        'no_html': '1',
        'no_redirect': '1',
        'skip_disambig': '1',
      },
    );
    final response = await _client.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw StateError('Search failed with HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Search returned an invalid response.');
    }
    return _parseTopics(decoded['RelatedTopics']);
  }

  List<WebSearchResult> _parseTopics(Object? topics) {
    if (topics is! List) return const [];
    final results = <WebSearchResult>[];
    for (final topic in topics) {
      if (topic is Map && topic['Topics'] is List) {
        results.addAll(_parseTopics(topic['Topics']));
        continue;
      }
      if (topic is! Map) continue;
      final text = topic['Text'];
      final firstUrl = topic['FirstURL'];
      if (text is! String || firstUrl is! String) continue;
      final uri = Uri.tryParse(firstUrl);
      if (uri == null || !const {'http', 'https'}.contains(uri.scheme)) {
        continue;
      }
      results.add(WebSearchResult(text, uri.toString(), text));
    }
    return results;
  }
}
