import 'package:flutter/material.dart';
import 'database_helper.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  @override
  _FavoriteMoviesScreenState createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  List<Map<String, dynamic>> _favoriteMovies = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getFavoriteMovies(); // Call the method to fetch favorite movies
  }

  Future<void> _getFavoriteMovies() async {
    try {
      List<Map<String, dynamic>> favorites = await _dbHelper.getFavoriteMovies();
      setState(() {
        _favoriteMovies = favorites;
      });
    } catch (e) {
      print("Error getting favorite movies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Movies')),
      body: _favoriteMovies.isEmpty
          ? Center(child: Text('No favorite movies yet'))
          : ListView.builder(
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_favoriteMovies[index]['Title']),
                  subtitle: Text(_favoriteMovies[index]['Year']),
                  leading: Image.network(_favoriteMovies[index]['Poster']),
                  // Add logic to display movie details or other actions when tapped
                );
              },
            ),
    );
  }
}