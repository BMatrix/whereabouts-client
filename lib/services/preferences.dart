import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  //Almost all of Preferences is static so the preferences can be accessed from anywhere

  static SharedPreferences _sharedPreferences;

  //The default values of all preferences
  static Map<String, dynamic> _preferenceDefaultValues = {
    "updatePositionTime": 60,
    "getPositionTime": 60,
    "serverIp": "",
    "serverPort": 34464,
  };

  //The current preferences
  static Map<String, dynamic> preferenceValues = {
    "updatePositionTime": null,
    "getPositionTime": null,
    "serverIp": null,
    "serverPort": null,
  };

  //Load SharedPreferences, load preferences into preferenceValues, save preferences (preferences that were null get the default value)
  static Future<void> initialise() {
    return SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
      getPreferences();
      setPreferences();
    });
  }

  //Load all preferences into preferenceValues and fill in null values with the _preferenceDefaultValues
  static void getPreferences() {
    preferenceValues["updatePositionTime"] = _sharedPreferences.getInt("updatePositionTime");
    preferenceValues["getPositionTime"] = _sharedPreferences.getInt("getPositionTime");
    preferenceValues["serverIp"] = _sharedPreferences.getString("serverIp");
    preferenceValues["serverPort"] = _sharedPreferences.getInt("serverPort");

    preferenceValues.forEach((key, value) {
      if (value == null) {
        preferenceValues[key] = _preferenceDefaultValues[key];
      }
    });
  }

  //Store all preferences
  static void setPreferences() {
    _sharedPreferences.setInt("updatePositionTime", preferenceValues["updatePositionTime"]);
    _sharedPreferences.setInt("getPositionTime", preferenceValues["getPositionTime"]);
    _sharedPreferences.setString("serverIp", preferenceValues["serverIp"]);
    _sharedPreferences.setInt("serverPort", preferenceValues["serverPort"]);
  }

  //Reset all preferences to the _preferencesDefaultValues
  static void resetPreferences() {
    _sharedPreferences.setInt("updatePositionTime", _preferenceDefaultValues["updatePositionTime"]);
    _sharedPreferences.setInt("getPositionTime", _preferenceDefaultValues["getPositionTime"]);
    _sharedPreferences.setString("serverIp", _preferenceDefaultValues["serverIp"]);
    _sharedPreferences.setInt("serverPort", _preferenceDefaultValues["serverPort"]);

    getPreferences();
  }
}
