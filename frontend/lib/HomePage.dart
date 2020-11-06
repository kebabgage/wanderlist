import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wonderlist_frontend/main.dart';
import 'package:wonderlist_frontend/Rewards.dart';

import 'dart:math';
import 'Requests.dart';

/// Displays an instance of [HomePageLayout]
/// Calls _HomePage to createState().
/// Requires [ValueChanged] callbacks as to notice actions upon widgets.
class HomePage extends StatefulWidget {
  /// Callbacks to notice actions within the page
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Activity> onActivity;

  HomePage({@required this.onSubmitted, this.onActivity});

  @override
  _HomePageState createState() => _HomePageState(
      onSubmitted: this.onSubmitted, onActivity: this.onActivity);
}

/// Creates the primary scaffold for [HomePage] page.
/// Uses [HomePageLayout] as body of scaffold.
/// Requires [ValueChanged] as parameters for callback functionality.
class _HomePageState extends State<HomePage> {
  /// Callbacks to notice actions within the page.
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Activity> onActivity;

  _HomePageState({@required this.onSubmitted, this.onActivity});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: MaterialApp(
              home: HomePageLayout(
        onSubmitted: this.onSubmitted,
        onActivity: this.onActivity,
      ))),
    );
  }
}

/// Displays a search bar, location and activity cards.
/// Requires [ValueChanged] callbacks to notice actions upon widgets.
class HomePageLayout extends StatefulWidget {
  /// Callbacks to notice actions within the page
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Activity> onActivity;

  HomePageLayout({@required this.onSubmitted, this.onActivity});

  @override
  _HomePageLayoutState createState() => _HomePageLayoutState(
      onSubmitted: this.onSubmitted, onActivity: this.onActivity);
}

/// Creates the primary scaffold for [HomePage].
/// Fetches data from data from server and displays a city widget and two
/// activitiy widgets. The data for each widget is randomly determined.
class _HomePageLayoutState extends State<HomePageLayout> {
  /// Callbacks to notice actions within the page
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Activity> onActivity;

  _HomePageLayoutState({@required this.onSubmitted, this.onActivity});

  List<Activity> activites = List<Activity>();
  City homePageCity;

  /// Handles the search bar changing values.
  final notifier = new ChangeNotifier();

  // Fetch the cities and activities available. Choose a location and activitiy
  // at random. Store them as variables.
  Future<City> loadData() async {
    // Load the necessary data.
    List<City> futureCities = await fetchCities();
    List<Activity> futureActivities = await fetchActivities();

    // Choose a random city.
    var rng = new Random();
    int cityInt = rng.nextInt(futureCities.length);
    this.homePageCity = futureCities[cityInt];

    // Choose two random activities for the home page.
    int num1 = rng.nextInt(futureActivities.length);
    this.activites.add(futureActivities[num1]);

    int num2 = rng.nextInt(futureActivities.length);
    while (num2 == num1) {
      num2 = rng.nextInt(futureActivities.length);
    }
    this.activites.add(futureActivities[num2]);

    return futureCities[0];
  }

  /// Creates a [GestureDetector] that holds the image of the activity
  /// described by [Activity].
  /// On tap, handles callback to [OnValueChanged] activity so appropriate
  /// action can be taken.
  GestureDetector createActivityGesture(
      Activity activity, BuildContext contextWhole) {
    return new GestureDetector(
        onTap: () {
          this.onActivity(activity);
        },
        child: Container(
            height: 185,
            width: 185,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    'assets/${activity.name}.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(bottom: 10, left: 10),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "${activity.name}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Roboto-Light'),
                        ))),
              ]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 5,
            )));
  }

  /// Returns a [Container] that is populated with two instances of
  /// [GestureDetector] - one for each activity.
  Container generateHomeActivities(BuildContext context) {
    Activity activityOne = this.activites[0];
    Activity activityTwo = this.activites[1];

    return new Container(
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          createActivityGesture(activityOne, context),
          createActivityGesture(activityTwo, context)
        ]));
  }

  /// Creates a [GestureDetector] that holds the image of the location
  /// described by the homePageCity
  /// On tap, handles callback to [OnValueChanged] onSubmitted so appropriate
  /// can be taken.
  GestureDetector createMainPicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.onSubmitted("${this.homePageCity.name}");
      },
      child: new Container(
        height: 300,
        width: 400,
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: <Widget>[
              Image.asset(
                'assets/${this.homePageCity.name}.jpg',
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 10, left: 10),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${this.homePageCity.name}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'Roboto-Bold'),
                      )))
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
    );
  }

  /// Returns [Scaffold] object that contains the necessary objects
  /// for home page.
  /// On tap, loses the focus of the keyboard - if active.
  Scaffold homePage(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Material(
              child: SingleChildScrollView(
                  child: new Container(
                      padding: const EdgeInsets.all(15.0),
                      color: hexToColor("#F8F9FB"),

                      // Contains all the page stuff.
                      child: new Container(
                          child: new Center(
                              // FlexBox for all the vertical stuff.
                              child: new Column(children: [
                        new Padding(padding: EdgeInsets.only(top: 20)),

                        new Text("Get out and stretch your imagination",
                            style: TextStyle(
                                fontFamily: 'Roboto-Light', fontSize: 22.0)),

                        new Padding(padding: EdgeInsets.only(top: 20)),

                        /// [ValueChanged] required for this.
                        new SearchBar(onSubmitted: this.onSubmitted),

                        new Padding(padding: EdgeInsets.only(top: 20)),

                        /// Creates [GestureDetector].
                        createMainPicture(context),

                        new Text(
                          "Explore",
                          style: new TextStyle(
                              fontSize: 20.0, fontFamily: 'Roboto'),
                        ),

                        /// Generate [GestureDetector].
                        generateHomeActivities(context)
                      ]))))),
            )));
  }

  Widget build(BuildContext contextWhole) => FutureBuilder(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return homePage(contextWhole);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });
}

/// Search bar widget that is used on the home page
/// Requires [ValueChanged] callback to trigger appropriate functionality of
/// search bar.
/// Calls _SearchBarState to createState().
class SearchBar extends StatefulWidget {
  // Handles callback for when search bar has been submitted
  final ValueChanged<String> onSubmitted;
  SearchBar({@required this.onSubmitted});

  @override
  _SearchBarState createState() =>
      _SearchBarState(onSubmitted: this.onSubmitted);
}

/// Creates [Container] that holds [TextEditingController]
/// Uses [ValueChanged] as callback when the content is submitted.
class _SearchBarState extends State<SearchBar> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  String searchQuery;

  // Handles catching whether the search bar has been submitted.
  final ValueChanged<String> onSubmitted;
  _SearchBarState({@required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      new TextFormField(
        onFieldSubmitted: (dt) {
          widget.onSubmitted(dt);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: SUSTAINABLE,
          ),
          filled: true,
          fillColor: Colors.blue[50],
          hintText: "Where will you wander?",
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[50], width: 0.0),
              borderRadius: new BorderRadius.circular(25.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green[50], width: 0.0),
              borderRadius: new BorderRadius.circular(25.0)),
        ),
        validator: (val) {
          if (val.length == 0) {
            return "Search query cannot be empty";
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.emailAddress,
        style: new TextStyle(
          fontFamily: 'Roboto',
        ),
        controller: myController,
      ),
    ]));
  }
}
