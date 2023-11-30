import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((bookData) => Book(
        id:bookData['id'],
        title: bookData['title'],
        author: bookData['author'],
        cover_url: bookData['cover_url'],
        download_url: bookData['download_url'],
      )).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
