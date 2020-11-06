import 'package:wonderlist_frontend/Activities.dart';
import 'package:wonderlist_frontend/main.dart';
import 'package:flutter/material.dart';
import 'Requests.dart';

import 'dart:async';

/// Shows List of all saved activities collated in each location.
/// Calls _TripsState to createState().
class Trips extends StatefulWidget {
  @override
  _TripsState createState() => _TripsState();
}

/// Creates the primary scaffold for the [Trips] page.
/// Fetches all of the saved activities from the server and
/// parse it to TripCards class to create a list of trip cards.
class _TripsState extends State<Trips> {
  /// The list of all saved activities for the user
  Future<List<SavedActivityInTrips>> savedActivity;

  @override
  void initState() {
    super.initState();
    savedActivity = fetchSavedActivitiesForTrips();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomInset: true,
        body: ListView(
          children: [
            new Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: new Center(
                    child: new Text(
                  "Saved Activities",
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontFamily: 'Roboto-Bold'),
                ))),
            new Container(child: new Center(child: TripCards(savedActivity))),
          ],
        ));
  }
}

/// Iterate throught the list of saved activities and
/// separates them into each locations.
/// Details of each location, such as [activityCount] and [totalPoints] are
/// also computed and saved.
/// Parse the [activitiesPerLocation] and details to TripCard class.
class TripCards extends StatelessWidget {
  /// List of savedActivity recieved from _TripState class.
  final Future<List<SavedActivityInTrips>> futureSavedActivity;

  /// List of TripCard widgets to return to the _TripState class.
  final List<Widget> childrens = [];

  /// Details of each trip, such as location name, number of activities and
  /// total number of points per location.
  final List<String> locations = [];
  final List<int> activityCount = [];
  final List<int> totalPoints = [];

  /// Map of each location with its corresponding list of actitivies.
  final Map<String, List<TripActivity>> activitiesPerLocation = {};

  TripCards(this.futureSavedActivity);

  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<SavedActivityInTrips>>(
        future: futureSavedActivity,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            for (var i = 0; i < snapshot.data.length; i++) {
              /// If the location is a new location, CREATE a new
              /// {location : activities} in [activitiesPerLocation].
              if (locations
                      .contains(snapshot.data[i].tripActivity.location.name) ==
                  false) {
                locations.add(snapshot.data[i].tripActivity.location.name);
                activityCount.add(1);
                totalPoints.add(snapshot.data[i].tripActivity.points);
                activitiesPerLocation[snapshot.data[i].tripActivity.location
                    .name] = [snapshot.data[i].tripActivity];
              } else {
                /// If the location is an existing location, ADD the activity
                /// into {location : activities} in [activitiesPerLocation]
                /// in its specific location.
                int newActivityNum = activityCount[locations
                        .indexOf(snapshot.data[i].tripActivity.location.name)] +
                    1;
                activityCount.insert(
                    locations
                        .indexOf(snapshot.data[i].tripActivity.location.name),
                    newActivityNum);
                activityCount.removeAt(locations
                        .indexOf(snapshot.data[i].tripActivity.location.name) +
                    1);
                int newTotalPoints = totalPoints[locations
                        .indexOf(snapshot.data[i].tripActivity.location.name)] +
                    snapshot.data[i].tripActivity.points;
                totalPoints.insert(
                    locations
                        .indexOf(snapshot.data[i].tripActivity.location.name),
                    newTotalPoints);
                totalPoints.removeAt(locations
                        .indexOf(snapshot.data[i].tripActivity.location.name) +
                    1);
                activitiesPerLocation[
                        snapshot.data[i].tripActivity.location.name]
                    .add(snapshot.data[i].tripActivity);
              }
            }

            /// Iterate through each [locations] and create a trip card.
            /// Add those trip card into [childrens].
            for (var i = 0; i < locations.length; i++) {
              TripCard tripcard = TripCard(
                  locations[i],
                  'assets/${locations[i]}.jpg',
                  activityCount[i].toString(),
                  totalPoints[i].toString(),
                  activitiesPerLocation[locations[i]]);
              childrens.add(tripcard);
            }

            /// Returns the column of [children], which consists of trip card.
            return Column(
              children: childrens,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

/// Returns a container view of ONE trip card for ONE location
class TripCard extends StatelessWidget {
  /// Details of the location recieved from TripCards class.
  final String city;
  final String picture;
  final String numberOfActivities;
  final String totalPoints;

  /// List of activities to return to the TripCards class.
  /// The list is also parse into Activities class.
  final List<TripActivity> listOfSavedActivities;

  TripCard(this.city, this.picture, this.numberOfActivities, this.totalPoints,
      this.listOfSavedActivities);

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(2),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8,
            child: Column(children: [
              Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      /// Goes to Activities page that shows
                      /// the list of activities within its location.
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Activities(),
                              settings: RouteSettings(
                                  arguments: TripDetail(
                                      city, picture, listOfSavedActivities))));
                    },
                    child: Stack(children: <Widget>[
                      Image.asset(
                        picture,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 40.0, left: 30.0),
                          child: Text(
                            city,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Roboto-Light',
                            ),
                          )),
                    ]),
                  )),
              Container(
                  margin: const EdgeInsets.only(left: 20, top: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "$numberOfActivities activities saved",
                        style: TextStyle(
                            fontFamily: 'Roboto-Light',
                            color: hexToColor("#333333"),
                            fontSize: 15),
                      ))),
              Container(
                  margin: const EdgeInsets.only(left: 20, top: 3, bottom: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total points available : $totalPoints",
                        style: TextStyle(
                            fontFamily: 'Roboto-Light',
                            color: hexToColor("#333333"),
                            fontSize: 15),
                      ))),
            ])));
  }
}
