import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'database_helper.dart';
import 'favoriteMovieScreen.dart';
import 'gallery_helper.dart';

class OmdbMoviesScreen extends StatefulWidget {
  @override
  _OmdbMoviesScreenState createState() => _OmdbMoviesScreenState();
}

class _OmdbMoviesScreenState extends State<OmdbMoviesScreen> {
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _selectedIndex = 0;
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = '5bc3e310';
    final apiUrl = 'http://www.omdbapi.com/?s=batman&apikey=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        setState(() {
          _movies = List<Map<String, dynamic>>.from(data['Search']);
          _isLoading = false;
        });
      } else {
        print('API returned an error: ${data['Error']}');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Failed to load data from API');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showMovieDetails(Map<String, dynamic> movie) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie['Title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Year: ${movie['Year']}'),
              SizedBox(height: 8),
              Text('Type: ${movie['Type']}'),
              SizedBox(height: 8),
              Text('IMDB ID: ${movie['imdbID']}'),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToFavorites(Map<String, dynamic> movie) async {
    int result = await _dbHelper.insertFavorite(movie);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to favorites')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add to favorites')));
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _accessCamera() async {
    final File? pickedImage = await CameraHelper.takePhoto();
    if (pickedImage != null) {
      setState(() {
        _images.add(pickedImage);
      });
    }
  }

  Future<void> _accessGallery() async {
    final List<File> galleryImages = await GalleryHelper.fetchImages();
    if (galleryImages.isNotEmpty) {
      // Implementasi untuk menampilkan galeri
    } else {
      print('No images found in the gallery.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMoviesList() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _movies.isEmpty
            ? Center(child: Text('No movies found'))
            : ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index]['Title']),
                    subtitle: Text(_movies[index]['Year']),
                    leading: Image.network(_movies[index]['Poster']),
                    onTap: () => _showMovieDetails(_movies[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => _addToFavorites(_movies[index]),
                    ),
                  );
                },
              );
  }

  Widget _buildGallery() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Image.file(_images[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDB Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildMoviesList()
          : _selectedIndex == 1
              ? FavoriteMoviesScreen()
              : _selectedIndex == 2
                  ? _buildGallery()
                  : Container(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
Colors.amber[800],
        onTap: (index) {
          _onItemTapped(index);
          if (index == 3) {
            _accessCamera();
          } else if (index == 2) {
            _accessGallery();
          }
        },
      ),
    );
  }
}
