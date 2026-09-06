class WebSearchResult { const WebSearchResult(this.title, this.url, this.snippet); final String title; final String url; final String snippet; }

abstract interface class WebSearchProvider { Future<List<WebSearchResult>> search(String query); }

class WebSearchService {
  WebSearchService({required this.provider});
  final WebSearchProvider provider;
  Future<List<WebSearchResult>> search(String query) => provider.search(query);
}
