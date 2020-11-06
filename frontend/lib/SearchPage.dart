import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';

import 'package:wonderlist_frontend/main.dart';
import 'Requests.dart';
import 'Rewards.dart';

import 'dart:async';
import 'dart:convert';

/// Shows all the activities within the location searched.
/// The [String] given to construtor is the location to query.
class Search extends StatefulWidget {
  /// The [String] representing the city to be queried on search page.
  final String searchQuery;

  Search({this.searchQuery});

  @override
  _SearchState createState() => _SearchState(searchQuery: searchQuery);
}

/// Creates the primary scaffold for the [Search] page.
/// Loads a list of activities from the database.
class _SearchState extends State<Search> {
  /// The [String] representing the city to be queried on search page.
  final String searchQuery;

  _SearchState({this.searchQuery});

  /// Holds all the cities currently available in database.
  List<City> cities = List<City>();

  /// Holds all the activities currently available in database.
  List<Activity> activities = List<Activity>();

  /// Fetches and stores all cities in the database
  /// The cities are added to the citeies [List] of [_SearchState]
  /// Returns the [Future] of all activities found in database.
  Future<List<City>> getCityInfo(String s) async {
    List<City> futureCities = await fetchCities();
    this.cities.addAll(futureCities);
    return futureCities;
  }

  /// Fetches and stores all activites in the database.
  /// The activites are added to the activities [List] of [_SearchState]
  /// Returns the [Future] of all activities found in database.
  Future<List<Activity>> getActivitesForCity(int cityId) async {
    List<Activity> futureActivities = await fetchActivities();

    for (int i = 0; i < futureActivities.length; i++) {
      if (futureActivities[i].cityId == cityId) {
        this.activities.add(futureActivities[i]);
      }
    }
    return this.activities;
  }

  /// Checks whether the current searchQuery matches the name of any cities
  /// currently stored in cities [List].
  /// Returns id of city, if found. Else, returns -1.
  int checkCurrentCity() {
    for (int i = 0; i < cities.length; i++) {
      if (cities[i].name == searchQuery) {
        return cities[i].id;
      }
    }
    return -1;
  }

  /// Creates a scaffold for the [Search] page when search query did not match
  /// a city.
  Scaffold dataNotFound(String searchQuery) {
    return new Scaffold(
        body: new SingleChildScrollView(
            child: new Column(children: [
      new Container(
          margin: const EdgeInsets.only(top: 30.0, left: 30.0),
          child: Text(
            'Sorry, there are no activites in "$searchQuery"',
            style: TextStyle(
                fontSize: 40,
                fontFamily: 'Roboto-Light',
                color: Colors.black.withOpacity(0.6)),
          )),
      new Container(
          margin: const EdgeInsets.only(top: 30.0),
          child: Image.asset(
            "assets/brisbane.jpg",
            height: 250,
            width: 250,
            fit: BoxFit.cover,
          )),
      const SizedBox(height: 30),
      RaisedButton(
          onPressed: () {},
          child: const Text('Back to Home', style: TextStyle(fontSize: 20))),
    ])));
  }

  /// Creates a scaffold for the [Search] page when the search query matched a
  /// city.
  /// Fetches activities for the specified city, displaying a progress bar
  /// while the data has not been fethced yet.
  /// The scaffold contains all activities currently available in the city
  /// described by [cityId] and [searchQuery].
  Scaffold dataIsPresent(String searchQuery, int cityId) {
    return new Scaffold(

        // We need to display all the activites at this location.
        body: new FutureBuilder(
            future: getActivitesForCity(cityId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                for (int i = 0; i < activities.length; i++) {}
                // Check whether our keyword is found.
                if (activities.length == 0) {
                  return dataNotFound(searchQuery);
                } else {
                  return new Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: Column(
                        children: <Widget>[
                          new Container(
                            margin:
                                const EdgeInsets.only(top: 10.0, bottom: 15.0),
                          ),
                          new Column(
                            children: [
                              new Container(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    elevation: 8,
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: InkWell(
                                        splashColor: Colors.blue.withAlpha(30),
                                        child: Stack(
                                          children: <Widget>[
                                            Image.asset(
                                              "assets/$searchQuery.jpg",
                                              height: 70,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 15.0, left: 30.0),
                                                child: Text(
                                                  "$searchQuery",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30,
                                                      fontFamily:
                                                          'Roboto-Bold'),
                                                ))
                                          ],
                                        )),
                                  )),
                            ],
                          ),
                          new Expanded(
                            child: new ActivityCards(activities: activities),
                          )
                        ],
                      ));
                }
              } else {
                // We can show the loading view until the data comes back.
                return CircularProgressIndicator();
              }
            }));
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        body: FutureBuilder(
      future: getCityInfo(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Check whether our keyword is found.
          int city = checkCurrentCity();
          if (city == -1) {
            return dataNotFound(searchQuery);
          } else {
            return dataIsPresent(searchQuery, city);
          }
        } else {
          // We can show the loading view until the data comes back.
          return CircularProgressIndicator();
        }
      },
    ));
  }
}

/// A grid view of all the activities at a given city
class ActivityCards extends StatelessWidget {
  /// The activites to be displayed
  List<Activity> activities;

  /// The activities stored as card widgets
  List<ActivityCard> activityCards;

  ActivityCards({this.activities});

  /// Returns a list of [ActivityCards] that reflect the [Activity] list
  List<ActivityCard> createChildren() {
    List<ActivityCard> activityCards = List<ActivityCard>();

    Activity currentActivity;
    for (int i = 0; i < activities.length; i++) {
      currentActivity = activities[i];

      activityCards.add(ActivityCard(
          currentActivity.id,
          currentActivity.name,
          "assets/${currentActivity.name}.jpg",
          currentActivity.desc,
          "${currentActivity.points}",
          currentActivity.address,
          "..",
          1));
    }
    return activityCards;
  }

  Widget build(BuildContext context) {
    this.activityCards = createChildren();

    return GridView.count(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 3.65 / 3,
        children: createChildren());
  }
}

/// Stores all the necessary information that is required to display an activity
class ActivityDisp {
  final int id;
  final String activity;
  final String picture;
  final String description;
  final String point;
  final String address;
  final String code;
  final int cityId;

  ActivityDisp(this.id, this.activity, this.picture, this.description,
      this.point, this.address, this.code, this.cityId);
}

/// Creates route and transition motion between the current page and the
/// [ActivityDetail] page.
Route _createRoute(ActivityDisp activity) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ActivityDetail(activity),
    settings: RouteSettings(arguments: activity),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Shows all the details of an [Activity]
class ActivityDetail extends StatefulWidget {
  /// The activity details to be displayed.
  final ActivityDisp activity;
  ActivityDetail(this.activity);

  @override
  _ActivityDetailState createState() => _ActivityDetailState(this.activity);
}

/// Creates the primary scaffold for the [ActivityDetail] page.
/// Loads the list of activities for a particular activity and user.
class _ActivityDetailState extends State<ActivityDetail> {
  final ActivityDisp activity;
  _ActivityDetailState(this.activity);

  bool itemSaved;
  String _save;
  Map<String, dynamic> userInformation = Map<String, dynamic>();
  Map<String, dynamic> activityInfo = Map<String, dynamic>();

  /// Fetches the user information of the current user.
  /// This helps to narrow down whether the activity has been liked by users.
  Future<Map<String, dynamic>> fetchUserSavedActivity(int userId) async {
    final response = await http
        .get('https://deco3801-nintendogs.uqcloud.net/api/saved-activities');

    if (response.statusCode == 200) {
      for (var i = 0; i < jsonDecode(response.body).length; i++) {
        if (jsonDecode(response.body)[i]['user']['id'] == userId) {
          userInformation.addAll(jsonDecode(response.body)[i]['user']);
          return this.userInformation;
        }
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  /// Stores the values from the [activity] into [activityInfo].
  void saveActivityInfo() {
    activityInfo['id'] = activity.id;
    activityInfo['name'] = activity.activity;
    activityInfo['description'] = activity.description;
    activityInfo['address'] = activity.address;
    activityInfo['code'] = "";
    activityInfo['points'] = activity.point;
    activityInfo['city'] = Map<String, dynamic>();
    activityInfo['city']['id'] = activity.cityId;
    activityInfo['city']['name'] = 'null';
  }

  /// Handles the fetching of the activity data from the server.
  /// This is called when the page is first built, as the data is necessary
  /// for the building of page.
  Future<bool> activityLookup() async {
    // Get user information
    fetchUserSavedActivity(1);

    // Get activity information
    List<SavedActivity> activities = await fetchSavedActivity(1);

    // Save activity information
    saveActivityInfo();

    for (int i = 0; i < activities.length; i++) {
      if (activities[i].activityId == activity.id) {
        this._save = "Saved";
        this.itemSaved = true;
        return Future.value(true);
      }
    }

    this._save = "Save";
    this.itemSaved = false;

    return Future.value(false);
  }

  /// Handles the fetching or deleting actions necessary following the like
  /// button being tapped.
  /// If [isLiked] is true, the [activity] is unsaved by the current user.
  /// Else, the activity is saved by the current user.
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// Send user's request here.
    if (!isLiked) {
      final bool success =
          await saveActivity(1, this.userInformation, this.activityInfo);
      changeText(true);
      return true;
    } else {
      final bool success =
          await deleteActivity(1, this.userInformation, this.activityInfo);
      changeText(false);
      return false;
    }
  }

  /// Changes the [_save] variable depending on the status of [isLiked].
  void changeText(bool isLiked) {
    setState(() {
      if (isLiked) {
        this._save = "Saved";
      } else {
        this._save = "Save  ";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ActivityDisp args = ModalRoute.of(context).settings.arguments;

    return new FutureBuilder(
        future: activityLookup(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new Scaffold(
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    actionsIconTheme: IconThemeData(opacity: 0.0),
                    flexibleSpace: Stack(
                      children: <Widget>[
                        Positioned.fill(
                            child: Image.asset(
                          args.picture,
                          fit: BoxFit.cover,
                        )),
                        FlexibleSpaceBar()
                      ],
                    ),
                  ),

                  // The rest
                  SliverToBoxAdapter(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child:
                            new ListView(shrinkWrap: true, children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(children: [
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                args.activity,
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontFamily: 'Roboto'),
                                              ))),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 20, 5),
                                          child: Row(children: [
                                            Image.asset(
                                              'assets/coin_black.png',
                                              width: 20,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 0, 0, 0)),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('${args.point}',
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontFamily: 'Roboto')))
                                          ])),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                args.address,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontFamily: 'Roboto-Light',
                                                ),
                                              ))),
                                    ])),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                                    child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Column(children: [
                                          Container(
                                            child: LikeButton(
                                              isLiked: this.itemSaved,
                                              onTap: onLikeButtonTapped,
                                              likeBuilder: (bool isLiked) {
                                                return Icon(
                                                  Icons.favorite,
                                                  color: isLiked
                                                      ? SUSTAINABLE
                                                      : Colors.grey,
                                                  size: 40,
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, left: 5),
                                              alignment: Alignment.centerLeft,
                                              child: Text("$_save"))
                                        ])))
                              ]),
                          Divider(
                            color: Colors.grey[300],
                            height: 20,
                            thickness: 1.5,
                            indent: 10,
                            endIndent: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 40, 10),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    args.description,
                                    style: TextStyle(
                                      fontSize: 19,
                                      height: 1.4,
                                      fontFamily: 'Roboto',
                                    ),
                                  ))),
                          Divider(
                            color: Colors.grey[300],
                            height: 20,
                            thickness: 1.5,
                            indent: 10,
                            endIndent: 20,
                          ),
                        ])),
                  )
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

/// A container that contains information populated  regarding an activity.
class ActivityCard extends StatelessWidget {
  final int id;
  final String activity;
  final String picture;
  final String description;
  final String point;
  final String address;
  final String code;
  final int cityId;

  ActivityCard(this.id, this.activity, this.picture, this.description,
      this.point, this.address, this.code, this.cityId);

  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(_createRoute(ActivityDisp(id, activity,
                picture, description, point, address, code, cityId)));
          },
          child: Card(
            color: Colors.white,
            elevation: 8,
            child: ClipPath(
              child: Container(
                  child: Column(children: [
                Image.asset(
                  this.picture,
                  height: 80, //MediaQuery.of(context).size.height / 7,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16, 7, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(activity,
                          style: new TextStyle(
                              color: hexToColor("#000000"),
                              fontSize: 18,
                              fontFamily: 'Roboto')),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 7, 0, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Image.asset(
                            'assets/coin_black.png',
                            width: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          ),
                          Text(
                            point.toString(),
                            style: new TextStyle(
                                color: hexToColor("#000000"),
                                fontSize: 18,
                                fontFamily: 'Roboto-Light'),
                          ),
                        ]))),
              ])),
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3))),
            ),
            shadowColor: Colors.black,
          ),
        ));
  }
}

/// Handles the deleting of an activity from the server
/// Fetches all saved activities, then finds the corresponding activity to
/// [activityId] and attempts to delete this activity from the server.
Future<bool> deleteActivity(int activityId, Map<String, dynamic> userInfo,
    Map<String, dynamic> activityInfo) async {
  // Fetch all saved activities.
  final responseGet = await http
      .get('https://deco3801-nintendogs.uqcloud.net/api/saved-activities/');

  int delActivityId;

  // Find saved activity id that represents activity to be deleted
  if (responseGet.statusCode == 200) {
    for (var i = 0; i < jsonDecode(responseGet.body).length; i++) {
      if (jsonDecode(responseGet.body)[i]['activity']['id'] ==
          activityInfo["id"]) {
        delActivityId = jsonDecode(responseGet.body)[i]["id"];
      }
    }
  }

  // Attempt to delete from server
  final http.Response response = await http.delete(
      'https://deco3801-nintendogs.uqcloud.net/api/saved-activity/$delActivityId');

  // Deletion was successful
  if (response.statusCode == 201) {
    return true;
  } else {
    throw Exception('Failed to create album.');
  }
}

/// Posts a given activity, as described by [activityId] to savedActivites
/// The server is updated to include the specified activity within the current
/// users saved activities list.
Future<bool> saveActivity(int activityId, Map<String, dynamic> userInfo,
    Map<String, dynamic> activityInfo) async {
  Map<String, dynamic> json = {"user": 1, "activity": activityInfo["id"]};

  // Attemp to post the data
  final http.Response response = await http.post(
      'https://deco3801-nintendogs.uqcloud.net/api/save-saved-activity/',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Vary': 'Accept'
      },
      body: jsonEncode(json));

  // Was the post request successful
  if (response.statusCode == 201) {
    return true;
  } else {
    throw Exception('Failed to create album.');
  }
}
