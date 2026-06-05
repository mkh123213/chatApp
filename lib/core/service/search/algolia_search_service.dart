import 'package:algoliasearch/algoliasearch.dart';

class AlgoliaSearchService {
  final AlgoliaSearchClient _client;

  AlgoliaSearchService({
    required String appId,
    required String apiKey,
  }) : _client = AlgoliaSearchClient(appID: appId, apiKey: apiKey);

  Future<void> indexMessage(Map<String, dynamic> message, String indexName) async {
    await _client.saveObject(indexName: indexName, body: message);
  }

  Future<List<Map<String, dynamic>>> searchMessages(String query, String indexName) async {
    final response = await _client.searchSingleIndex(
      request: SearchForHits(indexName: indexName, query: query),
    );
    return response.hits;
  }
}
