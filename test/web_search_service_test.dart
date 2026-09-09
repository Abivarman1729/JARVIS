import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jarvis/services/web/web_search_service.dart';

void main() {
  test('rejects empty search queries before network access', () {
    final service = WebSearchService(
      provider: DuckDuckGoSearchProvider(client: MockClient((_) async {
        fail('The network must not be called for an empty query.');
      })),
    );

    expect(() => service.search('  '), throwsArgumentError);
  });

  test('parses nested real provider results and filters unsafe URLs', () async {
    final provider = DuckDuckGoSearchProvider(
      client: MockClient((request) async {
        expect(request.url.host, 'api.duckduckgo.com');
        return http.Response(
          '{"RelatedTopics":[{"Text":"Safe","FirstURL":"https://example.com/safe"},'
          '{"Text":"Unsafe","FirstURL":"javascript:alert(1)"},'
          '{"Topics":[{"Text":"Nested","FirstURL":"https://example.com/nested"}]}]}',
          200,
        );
      }),
    );

    final results = await WebSearchService(provider: provider).search('jarvis');

    expect(results.map((result) => result.title), ['Safe', 'Nested']);
  });
}
