import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_helper/shared/styles/Colors.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    scrolledUnderElevation: 0.0,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    titleTextStyle: TextStyle(
      fontSize: 17.0,
      color: Colors.black,
      letterSpacing: 0.5,
      fontFamily: 'Nunito',
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    clipBehavior: Clip.antiAlias,
    backgroundColor: Colors.white,
  ),
);


ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: darkBackground,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.dark(
    primary: darkPrimary,
  ),
  appBarTheme: AppBarTheme(
    color: darkBackground,
    scrolledUnderElevation: 0.0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 17.0,
      letterSpacing: 0.5,
      color: Colors.white,
      fontFamily: 'Nunito',
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: darkBackground,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: darkColor2,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    clipBehavior: Clip.antiAlias,
    backgroundColor: darkBackground,
  ),
);