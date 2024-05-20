import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'favoriteMovieScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OmdbMoviesScreen extends StatefulWidget {
  @override
  _OmdbMoviesScreenState createState() => _OmdbMoviesScreenState();
}

class _OmdbMoviesScreenState extends State<OmdbMoviesScreen> {
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchMovies(); // Panggil _fetchMovies() di initState()
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true; // Set loading indicator menjadi true sebelum memanggil API
    });

    final apiKey = '5bc3e310';
    final apiUrl = 'http://www.omdbapi.com/?s=batman&apikey=$apiKey'; // Contoh panggilan API untuk mencari film Batman
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        setState(() {
          _movies = List<Map<String, dynamic>>.from(data['Search']);
          _isLoading = false; // Set loading indicator menjadi false setelah mendapatkan data
        });
      } else {
        print('API returned an error: ${data['Error']}');
        setState(() {
          _isLoading = false; // Set loading indicator menjadi false jika ada error pada API
        });
      }
    } else {
      print('Failed to load data from API');
      setState(() {
        _isLoading = false; // Set loading indicator menjadi false jika gagal memanggil API
      });
    }
  }

  Future<void> _showMovieDetails(Map<String, dynamic> movie) async {
    // Implementasi tampilan deskripsi film, misalnya menggunakan bottom sheet
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
              // Tambahkan deskripsi film atau info lain yang ingin ditampilkan
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
    await prefs.setBool('isLoggedIn', false); // Hapus status login dari SharedPreferences
    Navigator.pushReplacementNamed(context, '/login'); // Arahkan pengguna kembali ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDB Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteMoviesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout), // Tambahkan tombol logout
            onPressed: () => _logout(context), // Panggil fungsi _logout saat tombol logout ditekan
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Tampilkan loading indicator jika masih memuat data
          : _movies.isEmpty
              ? Center(child: Text('No movies found')) // Tampilkan pesan jika daftar film kosong
              : ListView.builder(
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_movies[index]['Title']), // Tampilkan judul film
                      subtitle: Text(_movies[index]['Year']), // Tampilkan tahun rilis film
                      leading: Image.network(_movies[index]['Poster']), // Tampilkan gambar poster film
                      onTap: () => _showMovieDetails(_movies[index]), // Panggil fungsi _showMovieDetails saat pengguna mengklik film
                      trailing: IconButton(
                        icon: Icon(Icons.favorite_border), // Tambahkan tombol favorit
                        onPressed: () => _addToFavorites(_movies[index]), // Panggil fungsi _addToFavorites saat pengguna mengklik tombol favorit
                      ),
                    );
                  },
                ),
    );
  }
}
