import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whereabouts_client/screens/map_page.dart';
import 'package:whereabouts_client/services/preferences.dart';

void main() {
  //Lock screen orientation to portraitUp
  //I can't be bothered to fix the ui to also work decently in landscape
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) {
    //Load in Preferences before launching the app itself
    Preferences.initialise().then((value) {
      runApp(MyApp());
    });
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Material(
        //This Material widget only exists make the rest of the Material widgets stop complaning
        child: MapPage(),
      ),
    );
  }
}
