import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gif_model.dart';
import '../utils/constants.dart';

class GiphyService {
  static String get _apiKey {
    return Constants.giphyApiKey == 'YOUR_GIPHY_API_KEY_HERE'
        ? 'GlVGYHkr3WSBnllca54iNt0yFbjz7L65'
        : Constants.giphyApiKey;
  }

  static Future<List<GifModel>> getTrendingGifs({int offset = 0}) async {
    final url = Uri.parse(
        '${Constants.giphyBaseUrl}/trending?api_key=$_apiKey&limit=${Constants.defaultLimit}&offset=$offset'
    );

    try {
      final response = await http.get(url);


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> gifs = data['data'];
          return gifs.map((gif) => GifModel.fromJson(gif)).toList();
        } else {
          throw Exception('No data in response');
        }
      } else {
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<GifModel>> searchGifs(String query, {int offset = 0}) async {
    if (query.isEmpty) {
      return getTrendingGifs(offset: offset);
    }

    final url = Uri.parse(
        '${Constants.giphyBaseUrl}/search?api_key=$_apiKey&q=${Uri.encodeComponent(query)}&limit=${Constants.defaultLimit}&offset=$offset'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> gifs = data['data'];
          return gifs.map((gif) => GifModel.fromJson(gif)).toList();
        } else {
          throw Exception('No data in response');
        }
      } else {
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  static Future<List<GifModel>> getGifsByIds(List<String> ids) async {
    final idsString = ids.join(',');
    final url = Uri.parse(
        'https://api.giphy.com/v1/gifs?api_key=$_apiKey&ids=$idsString'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> gifs = data['data'];
          return gifs.map((gif) => GifModel.fromJson(gif)).toList();
        } else {
          throw Exception('No data in response');
        }
      } else {
        throw Exception('Failed to load GIFs by IDs');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}