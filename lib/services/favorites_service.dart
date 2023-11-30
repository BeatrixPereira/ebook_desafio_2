import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  // Retorna a lista de títulos favoritos armazenados
  static Future<List<String>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Adiciona um título à lista de favoritos
  static Future<void> addFavorite(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    favorites.add(id);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Remove um título da lista de favoritos
  static Future<void> removeFavorite(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavorites();
    favorites.remove(id);
    await prefs.setStringList(_favoritesKey, favorites);
  }
}
