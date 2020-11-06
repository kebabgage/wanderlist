import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'Requests.dart';
import 'Rewards.dart';

/// Represents the description page for a specific reward
/// including information on both the reward itself, the business it can be
/// redeemed at and where the business is located.
/// Calls class [_Details] to create state.
class DetailState extends StatefulWidget {
  final reward;
  final business;

  DetailState(this.reward, this.business);

  /// A state created with reward and business information.
  @override
  _Details createState() => _Details(this.reward, this.business);
}

/// Update the reward information of [rewardToUpdte]
/// using a api put call to the database through the call to [updateReward].
Future _redeem(Reward rewardToUpdate) async {
  rewardToUpdate.count = rewardToUpdate.count - 1;
  updateReward(rewardToUpdate);
}

/// Creates Detail widget representation within page from a call from
/// [DetailState] class.
class _Details extends State<DetailState> {
  final reward;
  final business;
  Color iconColour = Colors.grey;
  String iconText = "redeem";

  /// Creates a pop up dialog box asking for user comformation on redeeming the
  /// specific [rewardToUpdate].
  Future<void> _showMyDialog(Reward rewardToUpdate) async {
    return showDialog<void>(
      context: context,

      /// User must tap button.
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to redeem this reward?'),
              ],
            ),
          ),

          /// Represent Cancel and Confirm buttons on pop up.
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              onTap: () {
                /// Return to previous context page.
                Navigator.of(context).pop();
              },
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Approve',
                  style: TextStyle(color: SUSTAINABLE, fontSize: 16),
                ),
              ),
              onTap: () {
                /// Update reward icons fill colour and message.
                setState(() {
                  iconColour = SUSTAINABLE;
                  iconText = "enjoy";

                  /// Update database to decrement redeem count.
                  _redeem(rewardToUpdate);
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _Details(this.reward, this.business);

  /// Return widget representation of reward specific data.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor("#FFFFFF"),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            actionsIconTheme: IconThemeData(opacity: 0.0),
            flexibleSpace: Stack(
              children: <Widget>[
                /// Specific reward imagery placement.
                Positioned.fill(
                    child: Image.asset(
                  'assets/${this.reward.name}.jpg',
                  fit: BoxFit.cover,
                )),
                FlexibleSpaceBar()
              ],
            ),
          ),
          SliverToBoxAdapter(
            /// Header image and content display.
            child: Container(
                padding: EdgeInsets.all(10),
                child: new ListView(shrinkWrap: true, children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Reward heading information.
                        DetailHeader(this.reward, this.business),

                        /// Icon image, name and touch functionality.
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: InkWell(
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Column(children: [
                                    Container(
                                        child: Icon(
                                      Icons.star,
                                      color: iconColour,
                                      size: 40,
                                    )),
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(iconText))
                                  ])),
                              onTap: () {
                                setState(() {
                                  _showMyDialog(this.reward);
                                });
                              },
                            ))
                      ]),
                  RewardDescription(this.reward)
                ])),
          )
        ],
      ),
    );
  }
}

/// Represents the main information displayed from both [reward] and [business].
class DetailHeader extends StatelessWidget {
  final reward;
  final business;

  DetailHeader(this.reward, this.business);

  /// Widget representaion of information.
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.only(left: 10),
        child: Column(children: [
          /// Reward Name.
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                this.reward.name,
                style: TextStyle(
                  fontSize: 30,
                ),
              )),
          Padding(
            padding: EdgeInsets.all(5),
          ),

          /// Business address.
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                this.business.address,
                style: TextStyle(fontSize: 17),
              )),
        ]));
  }
}

/// Represents the desciption of a specific reward defined by [reward].
class RewardDescription extends StatelessWidget {
  final reward;

  RewardDescription(this.reward);

  /// Returns column view of Reward Desciption.
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
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
                this.reward.desc,
                style: TextStyle(
                  fontSize: 19,
                  height: 1.4,
                ),
              ))),
      Divider(
        color: Colors.grey[300],
        height: 20,
        thickness: 1.5,
        indent: 10,
        endIndent: 20,
      ),
    ]));
  }
}
