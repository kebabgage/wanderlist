import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:wonderlist_frontend/Requests.dart';
import 'package:wonderlist_frontend/RewardDetail.dart';

import 'package:wonderlist_frontend/main.dart';
import 'RewardDetail.dart';

/// Main app colour [SUSTAINABLE]
final Color SUSTAINABLE = hexToColor("#049DBF");

/// Represents the listing of Reward objects within a page
class RewardPage extends StatefulWidget {
  @override
  _RewardPageState createState() => _RewardPageState();
}

/// Represents a specific locked rewardard card within the page itself.
/// Users are only able to see this state and not directly interact with it as
/// they do not have enough points.
class LockedRewardCardState extends StatefulWidget {
  final business;
  final reward;

  LockedRewardCardState(this.business, this.reward);
  @override
  _LockedRewardCard createState() =>
      _LockedRewardCard(this.business, this.reward);
}

/// Represents a specific unlockable rewardard card within the page itself.
/// Users are able to click on these cards and navigate to a different state.
class RewardCardState extends StatefulWidget {
  final business;
  final reward;
  RewardCardState(this.business, this.reward);
  @override
  _RewardCard createState() => _RewardCard(this.business, this.reward);
}

/// Represents the entire page displaying the rewardards that a user can and
/// cannot access.
class _RewardPageState extends State<RewardPage> {
  User user;
  List<Reward> reward = List<Reward>();
  Map<Reward, Business> rewardLink = new HashMap<Reward, Business>();

  /// Gathers information from the server on the user, the rewards they can
  /// access and the businesses these rewards can be redeemed from.
  Future<User> loadRewardData() async {
    this.user = await fetchUser(1);
    this.reward = await fetchRewards();
    for (var i = 0; i < this.reward.length; i++) {
      int bid = this.reward[i].business;
      Business b = await fetchBusiness(bid);
      if (this.reward[i].count > 0) {
        rewardLink.putIfAbsent(this.reward[i], () => b);
      }
    }
    return this.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("#FFFFFF"),
      resizeToAvoidBottomInset: true,
      body: Column(children: <Widget>[
        new Padding(padding: const EdgeInsets.all(10)),
        new Center(
          child: new Text(
            "Rewards Near You",
            style: new TextStyle(
                color: Colors.black, fontSize: 30.0, fontFamily: 'Roboto-Bold'),
          ),
        ),
        new Padding(padding: const EdgeInsets.all(10)),
        new Container(
            height: MediaQuery.of(context).size.height / 1.45,
            width: MediaQuery.of(context).size.width,
            child: new Center(

                /// Use api request to load data on a user.
                child: FutureBuilder<User>(
                    future: loadRewardData(),
                    builder: (context, user) {
                      if (user.hasData) {
                        return CardGridSpace(user.data.points, this.rewardLink);
                      } else if (user.hasError) {
                        return Text("${user.error}");
                      } else {
                        return CircularProgressIndicator();
                      }
                    }))),
      ]),
    );
  }
}

/// Represents the grid space that reward cards are displayed in.
class CardGridSpace extends StatelessWidget {
  /// Create referecnces to new lists.
  final Map<Reward, Business> rewardLink;
  final points;
  final children = List<Widget>();

  CardGridSpace(this.points, this.rewardLink);

  Widget build(BuildContext context) {
    /// Oredering indexes for locked and unlocked rewards.
    int rewardardPos = 0;
    int lockedPos = rewardLink.length - 1;
    final sparseList = HashMap<int, Widget>();

    this.rewardLink.forEach((key, value) {
      Widget newCard;

      /// Check whether user surpasses the points threshold for a reward.
      if (this.points >= int.parse(key.points)) {
        newCard = RewardCardState(value, key);
        sparseList[rewardardPos] = newCard;
        rewardardPos++;
      } else {
        newCard = LockedRewardCardState(value, key);
        sparseList[lockedPos] = newCard;
        lockedPos--;
      }
      children.add(newCard);
    });

    /// Add all rewards to a list in a sorted order.
    for (var entry in sparseList.entries) {
      children[entry.key] = entry.value;
    }

    /// Create grid view to represent the reward cards in.
    return Container(
      child: GridView.count(
          childAspectRatio: 3.6 / 3,
          primary: false,
          padding: const EdgeInsets.all(5),
          crossAxisCount: 2,
          children: children),
    );
  }
}

/// Represents the specific locked reward card within the gridview.
class _LockedRewardCard extends State<LockedRewardCardState> {
  final business;
  final reward;

  _LockedRewardCard(this.business, this.reward);

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(2),
        child: InkWell(
            child: Card(
          color: hexToColor("#DDDDDD"),

          /// Locked reward representation has no elevation.
          elevation: 0,
          borderOnForeground: true,
          child: ClipPath(
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 8))),
                child: Opacity(
                  opacity: 0.75,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /// Create opaque overlay of the image.
                      Opacity(
                          opacity: 0.6,
                          child: Image.asset(
                            'assets/${this.reward.name} Points.jpg',
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 12,
                            fit: BoxFit.cover,
                          )),

                      /// Create Header representation of reward information.
                      CardHeader(this.reward, this.business)
                    ],
                  ),
                )),
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
          ),
          shadowColor: Colors.black,
        )),
      ),
    );
  }
}

/// Represents the specific unlccked reward card within the gridview.
class _RewardCard extends State<RewardCardState> {
  final business;
  final reward;

  _RewardCard(this.business, this.reward);

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.all(2),
          child: InkWell(
              child: Card(
                color: Colors.white,

                /// Make unlocked rewards pop off the screen.
                elevation: 8,
                borderOnForeground: true,
                child: ClipPath(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: SUSTAINABLE /*Colors.green*/,
                                width: 8))),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          'assets/${this.reward.name}.jpg',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 12,
                          fit: BoxFit.cover,
                        ),
                        CardHeader(this.reward, this.business)
                      ],
                    ),
                  ),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                ),
                shadowColor: Colors.black,
              ),
              onTap: () {
                /// Create route to relevant reward detail page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DetailState(this.reward, this.business)));
              }),
        ));
  }
}

/// Represents the main information displayed from both [reward] and [business].
class CardHeader extends StatelessWidget {
  final business;
  final reward;

  CardHeader(this.reward, this.business);

  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      new Padding(
          padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(this.reward.name,
                  style: TextStyle(
                    fontSize: 14,
                  )))),
      new Column(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(this.business.name,
                  style: new TextStyle(
                      color: hexToColor("#aaa9ab"), fontSize: 11)),
            )),
        Padding(
            padding: EdgeInsets.fromLTRB(10, 3, 10, 7),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(

                  /// Display only the address on the reward header.
                  this.business.address.split(', ')[1],
                  style: new TextStyle(
                      color: hexToColor("#aaa9ab"), fontSize: 11)),
            )),
      ]),
    ]));
  }
}
