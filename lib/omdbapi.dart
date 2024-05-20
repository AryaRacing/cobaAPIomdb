import 'package:http/http.dart' as http;
import 'dart:convert';

class OmdbApi {
  static const String _baseUrl = 'http://www.omdbapi.com/';
  static const String _apiKey = '5bc3e310'; // Ganti dengan kunci API Anda

  static Future<Map<String, dynamic>> fetchMovieDetails(String imdbId) async {
    final url = '$_baseUrl/?apikey=$_apiKey&i=$imdbId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
