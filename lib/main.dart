/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated: 2022-01-17

library ec.gob.infancia.ecuadorsincero;

import 'dart:developer';
import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/ec/gob/infancia/login/login.dart';
import 'package:sqflite/sqflite.dart';

late Database sqliteDB;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqliteDB = await UtilsSqlite.open();
  print(sqliteDB);


  var prefs = await SharedPreferences.getInstance();
  UtilsHttp.cookieInfo = prefs.getString('cookie');
  bool hasUsername = prefs.containsKey('username');

  //HttpOverrides.global = MyHttpOverrides();
  runApp(EcuadorSinceroApp(goLogin: !hasUsername));

  manageLocationPermission().then((enabled) {
    if (kDebugMode) {
      log('GPS is ${enabled ? 'enabled' : 'disabled'}');
    }
  });
}

class EcuadorSinceroApp extends StatelessWidget {
  final String title = 'Sincero';
  final bool goLogin;

  const EcuadorSinceroApp({Key? key, required this.goLogin}) : super(key: key);

  FloatingActionButtonThemeData get floatingActionButtonTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: UtilsColorPalette.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(200),
          ),
        ),
      );

  ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
            const Size(double.infinity, 52),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(52),
            ),
          ),
        ),
      );

  InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        fillColor: Colors.white,
        filled: true,
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 11,
        ),
      );

  TabBarTheme get tabBarTheme => const TabBarTheme(
        unselectedLabelColor: UtilsColorPalette.primary,
        labelColor: Colors.white,
        indicator: BoxDecoration(color: UtilsColorPalette.secondary),
      );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: title,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: UtilsColorPalette.theme,
        textTheme: const TextTheme(
          headline1: TextStyle(
            color: UtilsColorPalette.gray900,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 26,
            height: 1.5,
          ),
          headline2: TextStyle(
            color: UtilsColorPalette.gray900,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 24,
            height: 1.5,
          ),
          headline3: TextStyle(
            color: UtilsColorPalette.gray700,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 22,
            height: 1.5,
          ),
          headline4: TextStyle(
            color: UtilsColorPalette.gray700,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            height: 1.5,
          ),
          headline5: TextStyle(
            color: UtilsColorPalette.gray700,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            height: 1.5,
          ),
          bodyText2: TextStyle(
            color: UtilsColorPalette.gray500,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        floatingActionButtonTheme: floatingActionButtonTheme,
        elevatedButtonTheme: elevatedButtonTheme,
        inputDecorationTheme: inputDecorationTheme,
        tabBarTheme: tabBarTheme,
      ),
      home: AnimatedSplashScreen(
        splashIconSize: double.infinity,
        backgroundColor: const Color.fromRGBO(7, 45, 97, 1),
        splash: 'assets/graphics/splash.gif',
        nextScreen: goLogin ? const LoginWidget() : const HomeWidget(),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
      ],
      onGenerateRoute: onGenerateRoute,
    );
  }
}
/*class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) =(angle_bracket) true;
  }
}*/
