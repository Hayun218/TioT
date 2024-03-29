import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//https://www.youtube.com/watch?v=wbHYho6zoyE

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData();
  ThemeProvider(this._themeData);

  ThemeData get getTheme => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
