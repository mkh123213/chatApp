import 'package:algoliasearch/algoliasearch_lite.dart';

class AlgoliaSearchService {
  final SearchClient _client;

  AlgoliaSearchService({
    required String appId,
    required String apiKey,
  }) : _client = SearchClient(appId: appId, apiKey: apiKey);

  Future<void> indexMessage(Map<String, dynamic> message, String indexName) async {
    await _client.customPost(
      path: '1/indexes/$indexName',
      body: message,
    );
  }

  Future<List<Map<String, dynamic>>> searchMessages(String query, String indexName) async {
    final response = await _client.searchIndex(
      request: SearchForHits(indexName: indexName, query: query),
    );
    return response.hits.map((hit) => hit.toJson()).toList();
  }
}
