import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List favoriteCosmetics = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteCosmetics();
  }

  Future<void> fetchFavoriteCosmetics() async {
    final response = await http.get(Uri.parse(
        'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/favorite.php?action=read'));
    if (response.statusCode == 200) {
      setState(() {
        favoriteCosmetics = json.decode(response.body);
      });
    }
  }

  Future<void> deleteFavoriteCosmetics(int id) async {
    final response = await http.post(
      Uri.parse(
          'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/favorite.php?action=delete'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      fetchFavoriteCosmetics();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cosmetic removed from favorites'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove Cosmetic from favorites'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favoriteCosmetics.isEmpty
          ? Center(child: Text('Tidak ada data barang elektronik favorit'))
          : ListView.builder(
              itemCount: favoriteCosmetics.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: favoriteCosmetics[index]['image'] != null
                        ? Image.network(
                            'https://a242-36-69-98-90.ngrok-free.app/project_uas_api/${favoriteCosmetics[index]['image']}',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                    title: Text(favoriteCosmetics[index]['name']),
                    subtitle: Text(
                        'Kategori: ${favoriteCosmetics[index]['category_name']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteFavoriteCosmetics(
                            int.parse(favoriteCosmetics[index]['id']));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
