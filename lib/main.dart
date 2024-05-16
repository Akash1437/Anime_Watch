import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Watch',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimeSearchPage(),
    );
  }
}

class AnimeSearchPage extends StatefulWidget {
  @override
  _AnimeSearchPageState createState() => _AnimeSearchPageState();
}

class _AnimeSearchPageState extends State<AnimeSearchPage> {
  List<dynamic> topAnimeList = [];
  TextEditingController _searchController = TextEditingController();
  bool isHomeScreen = true;

  @override
  void initState() {
    super.initState();
    _fetchTopAnime();
  }

  Future<void> _fetchTopAnime() async {
    final response =
        await http.get(Uri.parse('https://api.jikan.moe/v4/top/anime'));

    if (response.statusCode == 200) {
      setState(() {
        Container(
          height: 10,
          child: Text('Top 10 anime'),
        );
        topAnimeList = jsonDecode(response.body)['data'].take(24).toList();
      });
    } else {
      throw Exception('Failed to fetch top anime data');
    }
  }

  Future<void> _searchAnime(String query) async {
    final response =
        await http.get(Uri.parse('https://api.jikan.moe/v4/anime?q=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      isHomeScreen = false;

      if (data.isEmpty) {
        // Handle empty data list
        setState(() {
          topAnimeList = [];

          // Set the topAnimeList to an empty list
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              width: 300, // Set the desired width
              height: 30, // Set the desired height
              child: Center(
                child: Text(
                  'No anime found for the given search.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ), // Center the text
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating, // Set the SnackBar to float
            backgroundColor:
                Color.fromARGB(255, 236, 94, 83), // Set the background color
            elevation: 6.0, // Set the elevation
          ),
        );
      } else {
        setState(() {
          topAnimeList = data;
        });
      }
    } else {
      throw Exception('Failed to fetch anime data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey.shad,
      backgroundColor: Color.fromARGB(255, 2, 52, 63),
      appBar: AppBar(
        title: Text('Anime Watch'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search anime...',

                //fillColor: Color.fromARGB(255, 240, 237, 204),
                filled: true,
                fillColor: Color.fromARGB(220, 240, 237, 204),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchAnime(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (String value) {
                _searchAnime(value); // Trigger search when enter is pressed
              },
            ),
          ),
          //Expanded(child: Text('Top 10 anime')),
          if (isHomeScreen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Top anime you would like...',
                  style: TextStyle(
                    color: Color.fromARGB(220, 240, 237, 204),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
              ),
              itemCount: topAnimeList.length,
              itemBuilder: (context, index) {
                final anime = topAnimeList[index];
                return GestureDetector(
                  onTap: () {
                    _launchYouTubeTrailer(anime['trailer']['url']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Card(
                      color: Color.fromARGB(230, 240, 237, 204),
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          // Set the border side
                          color: Color.fromARGB(
                              255, 240, 237, 204), // Set the border color
                          width: 3.0, // Set the border width
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.0),
                              ),
                              child: anime['images']['jpg']['image_url'] != null
                                  ? Image.network(
                                      anime['images']['jpg']['image_url'],
                                      fit: BoxFit.cover,
                                    )
                                  : SizedBox(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              anime['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color.fromARGB(255, 2, 52, 63),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchYouTubeTrailer(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
