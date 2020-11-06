import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';

import 'package:wonderlist_frontend/Requests.dart';
import 'package:wonderlist_frontend/Rewards.dart';
import 'package:wonderlist_frontend/SearchPage.dart';

import 'dart:convert';
import 'dart:async';

/// Shows the details of corresponding activity.
/// Have similar structure as [SearchPage],
/// but this has one extra important feature - [_scanQR]].
class ActivityDetail extends StatefulWidget {
  final ActivityDisp activity;
  ActivityDetail(this.activity);
  @override
  _ActivityDetailState createState() => _ActivityDetailState(this.activity);
}

/// Creates the primary scaffold for the [ActivityDetail] page.
class _ActivityDetailState extends State<ActivityDetail> {
  String result = "completed";

  final ActivityDisp activity;
  _ActivityDetailState(this.activity);

  bool itemSaved;
  String _save;
  Map<String, dynamic> userInformation = Map<String, dynamic>();
  Map<String, dynamic> activityInfo = Map<String, dynamic>();

  /// Fetches all the saved activities for the [userId] from server.
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
      throw Exception('Failed to load saved activity');
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

  /// Scans the QR code using user's camera and compares the QR code with
  /// the current activity.
  /// If matches, the activity is marked as 'completed' and saved in server.
  /// If else, user returns to the previous page.
  Future _scanQR(CodesToCompare codesToCompare) async {
    try {
      /// Starts scanning.
      var qrResult = await BarcodeScanner.scan();

      /// Methods called when codes matches.
      if (codesToCompare.activityCode == qrResult) {
        /// Get user information.
        User fetchedUser = await fetchUser(1);

        /// Add the user's points and activity's point.
        fetchedUser.points = fetchedUser.points + codesToCompare.pointsToAdd;

        /// Create a new saved activity in database.
        createSavedActivity(codesToCompare.dataForScanning);

        /// Updates new number of points for the user in database
        updateUserPoints(fetchedUser);

        /// Update states.
        setState(() {
          result = "success";
        });

        /// Confirmation message pop up.
        _showMyDialog();
      } else {
        setState(() {
          result = "try again";
        });
      }
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Denied";
        });
      } else {
        setState(() {
          result = "Error";
        });
      }
    } on FormatException {
      setState(() {
        result = "Canceled";
      });
    } catch (ex) {
      setState(() {
        result = "Error";
      });
    }
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
      print("We need to delete the saved activity");
      final bool success =
          await deleteActivity(1, this.userInformation, this.activityInfo);
      changeText(false);
      return false;
    }
  }

  /// Changes the [_save] variable depending on the status of [isLiked].
  void changeText(bool isLiked) {
    setState(() {
      // Change state of current text
      if (isLiked) {
        this._save = "Saved";
      } else {
        this._save = "Save  ";
      }
    });
  }

  /// Creates a pop up message for the confirmation of the activity.
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Activity Completed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You have completed ${activity.activity}.'),
                Text('You gained ${activity.point} points.'),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Okay',
                  style: TextStyle(
                      color: SUSTAINABLE, fontSize: 16, fontFamily: 'Roboto'),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoadedActivity args = ModalRoute.of(context).settings.arguments;

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
                                                    fontFamily: 'Roboto-Bold'),
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
                                                    fontFamily: 'Roboto'),
                                              ))),
                                    ])),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
              floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  _scanQR(CodesToCompare(
                      args.code, DataForScanning(1, args.id), args.point));
                },
                label: Text(result),
                backgroundColor: Colors.black,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
