import 'package:flutter/material.dart';
import 'package:wonderlist_frontend/Trips.dart';
import 'package:wonderlist_frontend/requests.dart';

import 'HomePage.dart';
import 'Rewards.dart';
import 'SearchPage.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Wonderlist';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// Main state for the app.
/// Creates the bottom navigator with HOME as the inital tab.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedPage = 0;
  int _selectedNav = 0;

  List<Widget> _widgetOptions;
  Future<User> futureUser;

  @override
  void initState() {
    _widgetOptions = [
      HomePage(onSubmitted: (submittedString) {
        _toSearchPage(3, submittedString);
      }, onActivity: (submittedActivity) {
        Navigator.of(context).push(_createRoute(ActivityDisp(
            submittedActivity.id,
            submittedActivity.name,
            "assets/${submittedActivity.name}.jpg",
            submittedActivity.desc,
            "${submittedActivity.points}",
            submittedActivity.address,
            submittedActivity.code,
            submittedActivity.cityId)));
      }),
      Trips(),
      RewardPage(),
      Search()
    ];

    super.initState();
  }

  Route _createRoute(ActivityDisp activity) {
    return PageRouteBuilder(
      pageBuilder: (contextWhole, animation, secondaryAnimation) =>
          ActivityDetail(activity),
      settings: RouteSettings(arguments: activity),
      transitionsBuilder: (contextWhole, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Updates the page at index to include string value as searchQuery.
  /// For use on the [SearchPage].
  void _toSearchPage(int index, String queryValue) {
    /// Update page.
    _widgetOptions[index] = Search(searchQuery: queryValue);

    /// Update the state and also fetch user information.
    setState(() {
      _selectedPage = index;
      futureUser = fetchUser(1);
    });
  }

  /// Called when a navigation bar item is tapped.
  /// Updates the selected page and navigation indices.
  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
      _selectedNav = index;
      futureUser = fetchUser(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      futureUser = fetchUser(1);
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SUSTAINABLE,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/coin_top.png',
                width: 35,
              )),
          Padding(
              padding: EdgeInsets.only(
                right: 40,
                top: 10,
              ),
              child: FutureBuilder<User>(
                  future: futureUser,
                  builder: (context, user) {
                    if (user.hasData) {
                      return Text(
                        user.data.points.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'Roboto'),
                      );
                    } else if (user.hasError) {
                      return Text("${user.error}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Roboto'));
                    } else {
                      return Text("",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Roboto'));
                    }
                  })),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Activities'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            title: Text('Rewards'),
          ),
        ],
        currentIndex: _selectedNav,
        backgroundColor: Colors.white,
        selectedItemColor: hexToColor("#049DBF"),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Converts the colour code to the hex code.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
