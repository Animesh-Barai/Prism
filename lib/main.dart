import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:Prism/screens/firstscreen.dart';
import 'package:Prism/data/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  List<ThemeItem> data = List();

  String dynTheme;
  Future<void> getDefault() async {
    data = ThemeItem.getThemeItems();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynTheme = prefs.getString("dynTheme") ?? 'light-white-black';
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (Brightness brightness) {
          getDefault();
          for (int i = 0; i < data.length; i++) {
            if (data[i].slug == this.dynTheme) {
              return data[i].themeData;
            }
          }
          return data[0].themeData;
        },
        themedWidgetBuilder: (context, theme) {
          FlutterStatusbarcolor.setStatusBarColor(Color(0x50FFFFFF));
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Prism',
            theme: theme,
            home: LoginScreen3(),
          );
        });
  }
}
