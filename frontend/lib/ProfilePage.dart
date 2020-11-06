import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Rewards.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //title: 'Fetch Data Example',
      //theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),

      appBar: AppBar(
          backgroundColor: SUSTAINABLE,
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          )),
      body: Center(
        child: FutureBuilder<Album>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                  "The id is ${snapshot.data.userId} and name is ${snapshot.data.id} and city is ${snapshot.data.title}");
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Future<Album> fetchAlbum() async {
  final response =
      await http.get('https://deco3801-nintendogs.uqcloud.net/api/businesses');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    //[0] HERE IS GETTING THE FIRST ELEMENT.
    // LOOP THROUGH LATER
    return Album.fromJson(jsonDecode(response.body)[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String userId;
  final String id;
  final String title;

  Album({this.userId, this.id, this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['id'].toString(),
      id: json['name'],
      title: json['city'].toString(),
    );
  }
}
