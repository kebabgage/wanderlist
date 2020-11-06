import 'package:wonderlist_frontend/ActivityDetail.dart';
import 'package:wonderlist_frontend/main.dart';
import 'package:wonderlist_frontend/Rewards.dart';
import 'package:wonderlist_frontend/Requests.dart';
import 'package:wonderlist_frontend/SearchPage.dart' as s;
import 'package:flutter/material.dart';

/// Shows the list of all activities within the same location.
class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

/// Creates the primary scaffold for the [Activities] page.
/// Loads the list of IDs for completed activities and
/// parse the [completedIds] and list of activities to ActivityCards class.
class _ActivitiesState extends State<Activities> {
  List<int> completedIds;
  String result = "not loaded";

  /// Populates [completedIds].
  Future<String> loadCompletedIds() async {
    this.completedIds = await fetchCompletedActivityId(1);
    result = "loaded";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final TripDetail city = ModalRoute.of(context).settings.arguments;
    loadCompletedIds();
    return new Scaffold(
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
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(children: <Widget>[
        new Container(
            margin: const EdgeInsets.only(top: 30.0, bottom: 15.0),
            child: new Center(
                child: Text(
              'Saved Activities',
              style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Roboto-Bold',
                  color: Colors.black.withOpacity(0.6)),
            ))),
        new Column(
          children: [
            new Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
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
                            city.picture,
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                          Container(
                              margin:
                                  const EdgeInsets.only(top: 15.0, left: 30.0),
                              child: Text(
                                city.city,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontFamily: 'Roboto-Bold'),
                              ))
                        ],
                      )),
                )),
          ],
        ),
        new Expanded(
            child: FutureBuilder(
                future: loadCompletedIds(),
                builder: (context, user) {
                  if (user.hasData) {
                    return ActivityCards(city.activityList, completedIds);
                  } else if (user.hasError) {
                    return Text("${user.error}");
                  } else {
                    return CircularProgressIndicator();
                  }
                })),
      ]),
    );
  }
}

/// Returns the grid view of all activities (both completed and not completed).
class ActivityCards extends StatelessWidget {
  /// Variables recieved from _ActivityState class.
  final List<TripActivity> tripActivities;
  final List<int> completedIds;

  /// Variables returned to _ActivityState class.
  final List<Widget> listOfActivityCard = [];
  final List<CompletedActivityCard> listOfCompletedCard = [];

  ActivityCards(this.tripActivities, this.completedIds);

  Widget build(BuildContext context) {
    /// Iterate through each activities and
    /// create CompletedActivityCard if its id is in [completedIds],
    /// and create ActivityCard if else.
    for (var i = 0; i < tripActivities.length; i++) {
      if (completedIds.contains(tripActivities[i].id)) {
        listOfActivityCard.add(CompletedActivityCard(
            tripActivities[i].name,
            "assets/${tripActivities[i].name}.jpg",
            tripActivities[i].description,
            tripActivities[i].points,
            tripActivities[i].address,
            tripActivities[i].code,
            tripActivities[i].id));
      } else {
        listOfActivityCard.add(ActivityCard(
            tripActivities[i].name,
            "assets/${tripActivities[i].name}.jpg",
            tripActivities[i].description,
            tripActivities[i].points,
            tripActivities[i].address,
            tripActivities[i].code,
            tripActivities[i].id));
      }
    }
    return GridView.count(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 3.65 / 3,
        children: listOfActivityCard);
  }
}

/// Returns one container for completed activity.
/// Structure is same with [ActivityCard] class,
/// except it is greyed out and unclickable.
class CompletedActivityCard extends StatelessWidget {
  final String activity;
  final String picture;
  final String description;
  final int point;
  final String address;
  final String code;
  final int id;

  CompletedActivityCard(this.activity, this.picture, this.description,
      this.point, this.address, this.code, this.id);

  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () {},
          child: Card(
            color: Colors.grey,
            elevation: 8,
            child: ClipPath(
              child: Container(
                  child: Column(children: [
                Image.asset(
                  this.picture,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16, 7, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(activity,
                          style: new TextStyle(
                              color: hexToColor("#DDDDDD"),
                              fontSize: 18,
                              fontFamily: 'Roboto')),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(16, 7, 0, 0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(children: [
                          Image.asset(
                            'assets/coin_grey.png',
                            width: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          ),
                          Text(
                            point.toString(),
                            style: new TextStyle(
                                color: hexToColor("#DDDDDD"),
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

/// Returns one container for uncompleted activity.
/// Structure is same with [CompledActivityCard] class,
/// except it is clickable.
class ActivityCard extends StatelessWidget {
  final String activity;
  final String picture;
  final String description;
  final int point;
  final String address;
  final String code;
  final int id;

  ActivityCard(this.activity, this.picture, this.description, this.point,
      this.address, this.code, this.id);

  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () {
            /// When tapped, it goes to [ActivityDetail] page.
            /// It shows the details of the corresponding activity.
            Navigator.of(context).push(_createRoute(LoadedActivity(
                activity, picture, description, point, address, code, id)));
          },
          child: Card(
            color: Colors.white,
            elevation: 8,
            child: ClipPath(
              child: Container(
                  child: Column(children: [
                Image.asset(
                  this.picture,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(16, 7, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(activity,
                          style: new TextStyle(
                              color: hexToColor("#000000"), fontSize: 18)),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(16, 7, 0, 0),
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

/// Creates route and transition motion between the current page
/// and the [ActivityDetail] class.
Route _createRoute(LoadedActivity activity) {
  var a = s.ActivityDisp(
      activity.id,
      activity.activity,
      activity.picture,
      activity.description,
      '${activity.point}',
      activity.address,
      activity.code,
      1);

  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ActivityDetail(a),
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
