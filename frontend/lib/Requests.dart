import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a reward and the details around a specific reward.
class Reward {
  final String id;
  final String name;
  final int business;
  final String points;
  final String desc;
  final String expires;
  int count;

  Reward(
      {this.id,
      this.name,
      this.points,
      this.expires,
      this.business,
      this.desc,
      this.count});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'].toString(),
      name: json['name'],
      points: json['points'].toString(),
      expires: json['expires'],
      desc: json["description"],
      business: json['business'],
      count: json['count'],
    );
  }

  /// Setter for a reward using [newCount].
  void set counter(int nextCount) {
    this.count = nextCount;
  }

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "name": this.name,
        "count": this.count,
        "points": this.points,
        "expires": this.expires,
        "business": this.business,
        "description": this.desc,
      };
}

/// Request to collate all rewards into a list.
Future<List<Reward>> fetchRewards() async {
  final response =
      await http.get('https://deco3801-nintendogs.uqcloud.net/api/rewards');

  if (response.statusCode == 200) {
    List<Reward> rewards = List<Reward>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      rewards.add(Reward.fromJson(jsonDecode(response.body)[i]));
    }
    return rewards;
  } else {
    throw Exception('Failed to load rewards');
  }
}

/// Request to collate one reward into a reward format using [rewardId].
Future<Reward> fetchReward(int rewardId) async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/rewards/' +
          rewardId.toString());

  if (response.statusCode == 200) {
    return Reward.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load reward');
  }
}

/// Uses a put request to update the database given a [reward].
void updateReward(Reward reward) async {
  final response = await http.put(
    'https://deco3801-nintendogs.uqcloud.net/api/rewards/' +
        reward.id.toString(),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(reward.toDatabaseJson()),
  );

  if (response.statusCode == 200) {
    print("updated");
  } else {
    print("failed");
    throw Exception('Failed to create reward');
  }
}

/// Function to collate saved Activities and the details around
/// all saved activities.
Future<List<SavedActivity>> fetchSavedActivities() async {
  final response = await http
      .get('https://deco3801-nintendogs.uqcloud.net/api/saved-activity/');

  if (response.statusCode == 200) {
    List<SavedActivity> savedActivities = List<SavedActivity>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      savedActivities.add(SavedActivity.fromJson(jsonDecode(response.body)[i]));
    }
    return savedActivities;
  } else {
    throw Exception('Failed to load saved activities');
  }
}

/// Represents the entire information around a specific activity including both
/// specific city and user that it belongs it.
class EntireActivity {
  final int id;
  final User user;
  final Activity activity;

  EntireActivity({this.id, this.user, this.activity});

  factory EntireActivity.fromJson(Map<String, dynamic> json) {
    return EntireActivity(
        id: json['id'],
        user: User.fromJson(json['user']),
        activity: Activity.fromJson(json['activity']));
  }
}

/// Function to gather information about a specific completed Activities and
/// the details around said completed activities based on the [userId].
Future<List<int>> fetchCompletedActivityId(int userId) async {
  print('starting to fetch completed activity id');
  List<int> fetchedCompletedActivityId = [];
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/completed-activities/?user__id=${userId.toString()}');

  if (response.statusCode == 200) {
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      fetchedCompletedActivityId
          .add(jsonDecode(response.body)[i]['activity']['id']);
    }
    return fetchedCompletedActivityId;
  } else {
    throw Exception('Failed to load completed activities for the user');
  }
}

/// Gather information about all completed activities from the server.
Future<List<SavedActivity>> fetchCompletedActivities() async {
  final response = await http
      .get('https://deco3801-nintendogs.uqcloud.net/api/completed-activity/');

  if (response.statusCode == 200) {
    List<SavedActivity> completedActivities = List<SavedActivity>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      completedActivities
          .add(SavedActivity.fromJson(jsonDecode(response.body)[i]));
    }
    return completedActivities;
  } else {
    throw Exception('Failed to load completed activities');
  }
}

/// Load all the saved activities. Go through and collect the ones that belong
/// to the specfic user [userId].
Future<List<SavedActivity>> fetchSavedActivity(int userId) async {
  final response = await http
      .get('https://deco3801-nintendogs.uqcloud.net/api/saved-activities');

  if (response.statusCode == 200) {
    List<SavedActivity> savedActivities = List<SavedActivity>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      print(i);
      if (jsonDecode(response.body)[i]['user']['id'] == userId) {
        print(jsonDecode(response.body)[i]);
        savedActivities
            .add(SavedActivity.fromJson(jsonDecode(response.body)[i]));
      }
    }
    return savedActivities;
  } else {
    throw Exception('Failed to load saved activity for the user');
  }
}

/// Represtents a saved acitivity structure.
class SavedActivity {
  final int id;
  final int userId;
  final int activityId;

  SavedActivity({this.id, this.userId, this.activityId});

  factory SavedActivity.fromJson(Map<String, dynamic> json) {
    return SavedActivity(
        id: json['id'],
        userId: json['user']['id'],
        activityId: json['activity']['id']);
  }
}

/// Call to gather information about all businesses within the database.
Future<List<Business>> fetchBusinesses() async {
  final response =
      await http.get('https://deco3801-nintendogs.uqcloud.net/api/businesses');

  if (response.statusCode == 200) {
    List<Business> businesses = List<Business>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      businesses.add(Business.fromJson(jsonDecode(response.body)[i]));
    }
    return businesses;
  } else {
    throw Exception('Failed to load business');
  }
}

/// Call to gather information about a specific business within the database
/// using the [id].
Future<Business> fetchBusiness(int id) async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/businesses/' +
          id.toString());

  if (response.statusCode == 200) {
    return Business.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

/// Represents a business and the information around one.
class Business {
  final String userId;
  final String name;
  final String address;
  final int cityId;

  Business({this.userId, this.name, this.address, this.cityId});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
        userId: json['id'].toString(),
        name: json['name'],
        address: json['address'].toString(),
        cityId: json['city']);
  }
}

/// Represents city information pulled from the database.
class City {
  final int id;
  final String name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

/// Call to gather all cities within the database.
Future<List<City>> fetchCities() async {
  final response =
      await http.get('https://deco3801-nintendogs.uqcloud.net/api/city');

  if (response.statusCode == 200) {
    List<City> cities = List<City>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      cities.add(City.fromJson(jsonDecode(response.body)[i]));
    }
    return cities;
  } else {
    throw Exception('Failed to load cities');
  }
}

/// Call to gather a specific city within the database using [cityId].
Future<City> fetchCity(int cityId) async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/city/' + cityId.toString());

  if (response.statusCode == 200) {
    return City.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

/// Represents a saved acitvity structure from the database.
class Activity {
  final int id;
  final String name;
  final String desc;
  final String code;
  final int points;
  final String address;
  final int cityId;

  Activity(
      {this.id,
      this.name,
      this.desc,
      this.code,
      this.points,
      this.address,
      this.cityId});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        id: json['id'],
        name: json['name'],
        desc: json['description'],
        code: json['code'],
        points: json['points'],
        address: json['address'],
        cityId: json['city']);
  }
}

/// Call to fetch a certain saved activity from the database based on
/// [activityId].
Future<Activity> fetchActivity(int activityId) async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/activities/' +
          activityId.toString());

  if (response.statusCode == 200) {
    return Activity.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load the specific activity');
  }
}

/// Gathers information on all activities within the database
Future<List<Activity>> fetchActivities() async {
  final response =
      await http.get('https://deco3801-nintendogs.uqcloud.net/api/activities');

  if (response.statusCode == 200) {
    List<Activity> activities = List<Activity>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      activities.add(Activity.fromJson(jsonDecode(response.body)[i]));
    }
    return activities;
  } else {
    throw Exception('Failed to load activities');
  }
}

/// Represents a user and its relevant information within the database.
class User {
  final int id;
  final String name;
  final String email;
  int points;
  final String mobile;

  User({this.id, this.name, this.email, this.points, this.mobile});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        points: json['points'],
        mobile: json['mobile'].toString());
  }

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "name": this.name,
        "email": this.email,
        "points": this.points,
        "mobile": this.mobile
      };
}

/// Fetch a specific users information from an api request to the database.
Future<User> fetchUser(int userId) async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/user/' + userId.toString());

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load specific user');
  }
}

/// Represents the details of the trip.
class TripDetail {
  final String city;
  final String picture;
  final List activityList;

  TripDetail(this.city, this.picture, this.activityList);
}

/// Fetch and returns the list of SavedActivities from server.
Future<List<SavedActivityInTrips>> fetchSavedActivitiesForTrips() async {
  final response = await http.get(
      'https://deco3801-nintendogs.uqcloud.net/api/saved-activities/?user__id=1');

  if (response.statusCode == 200) {
    List<SavedActivityInTrips> l = List<SavedActivityInTrips>();
    for (var i = 0; i < jsonDecode(response.body).length; i++) {
      l.add(SavedActivityInTrips.fromJson(jsonDecode(response.body)[i]));
    }
    return l;
  } else {
    throw Exception('Failed to load saved activities for trips page');
  }
}

/// Represents all the details required for saved activities
/// suitable for the use in [Trips] page.
class SavedActivityInTrips {
  final int id;
  final TripActivity tripActivity;

  SavedActivityInTrips({this.id, this.tripActivity});

  factory SavedActivityInTrips.fromJson(Map<String, dynamic> json) {
    return SavedActivityInTrips(
        id: json['id'], tripActivity: TripActivity.fromJson(json['activity']));
  }
}

/// Represents all the details required for activity that is
/// suitable for the use in [Trips] page.
class TripActivity {
  final int id;
  final String name;
  final String description;
  final String address;
  final String code;
  final int points;
  final Location location;

  TripActivity(
      {this.id,
      this.name,
      this.description,
      this.address,
      this.code,
      this.points,
      this.location});

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    return TripActivity(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        address: json['address'],
        code: json['code'],
        points: json['points'],
        location: Location.fromJson(json['city']));
  }
}

/// Represents the location entity.
class Location {
  final int id;
  final String name;

  Location({this.id, this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(id: json['id'], name: json['name']);
  }
}

/// Represents the loaded activity used for [Activities] and [ActivityDetail].
class LoadedActivity {
  final String activity;
  final String picture;
  final String description;
  final int point;
  final String address;
  final String code;
  final int id;
  LoadedActivity(this.activity, this.picture, this.description, this.point,
      this.address, this.code, this.id);
}

/// Represents the activity code for QRcode scanning method.
class CodesToCompare {
  final String activityCode;
  final DataForScanning dataForScanning;
  final int pointsToAdd;

  CodesToCompare(this.activityCode, this.dataForScanning, this.pointsToAdd);
}

/// Stores the details for the scanned data.
class DataForScanning {
  final int userId;
  final int activityId;

  DataForScanning(this.userId, this.activityId);

  Map<String, dynamic> toDatabaseJson() =>
      {"user": this.userId, "activity": this.activityId};
}

/// Creates a new saved activity.
Future<String> createSavedActivity(DataForScanning activityToSave) async {
  final http.Response response = await http.post(
    'https://deco3801-nintendogs.uqcloud.net/api/save-completed-activity/',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(activityToSave.toDatabaseJson()),
  );

  if (response.statusCode == 201) {
    return "Posted";
  } else {
    throw Exception('Failed to create saved activity.');
  }
}

/// Updates the user point with new point for specific [user].
Future<String> updateUserPoints(User user) async {
  final http.Response response = await http.put(
      'https://deco3801-nintendogs.uqcloud.net/api/user/${user.id}',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toDatabaseJson()));

  if (response.statusCode == 200) {
    return "Put success";
  } else {
    throw Exception('Failed to update user point');
  }
}
