import 'dart:convert';
import 'package:http/http.dart' as http;

class GiphyService {
  static const String _apiKey = 'KMaGeMMll3HkrBrzWJO5GBvGcXswl7Cb';
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<Map<String, dynamic>?> getRandomGif({
    String tag = '',
    String rating = 'g',
    required String randomId,
    String language = 'en',
  }) async {
    final url = Uri.parse(
      '$_baseUrl/random?api_key=$_apiKey'
      '&tag=$tag'
      '&rating=$rating'
      '&random_id=$randomId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['images'] != null) {
        return data['data'];
      } else {
        throw Exception('Nenhum GIF retornado pela API');
      }
    } else {
      throw Exception('Erro ao buscar GIF: ${response.statusCode}');
    }
  }

Future<String> getRandomId() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'local_$timestamp';
}
}
