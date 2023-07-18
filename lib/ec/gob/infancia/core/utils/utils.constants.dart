/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-13
/// @Updated: 2022-05-17

part of ec.gob.infancia.ecuadorsincero.utils;

class UtilsConstants {
  //static String host ='brigadasdev.infancia.gob.ec';
  static String host =
      kDebugMode ? 'brigadasdev.infancia.gob.ec' : 'brigadas.infancia.gob.ec';
  //static String apiUrl = 'brigadasdev.infancia.gob.ec';

  static String apiUrl = '${UtilsConstants.host}:8090';
  static String apiUrlPeople = '${UtilsConstants.host}:8091';

  static bool automaticSave = true;
}

/// Paleta de colores para la app.
class UtilsColorPalette {
  static MaterialColor theme = MaterialColor(
    const Color.fromRGBO(31, 51, 96, 1).value,
    const {
      50: Color.fromRGBO(31, 51, 96, .1),
      100: Color.fromRGBO(31, 51, 96, .2),
      200: Color.fromRGBO(31, 51, 96, .3),
      300: Color.fromRGBO(31, 51, 96, .4),
      400: Color.fromRGBO(31, 51, 96, .5),
      500: Color.fromRGBO(31, 51, 96, .6),
      600: Color.fromRGBO(31, 51, 96, .7),
      800: Color.fromRGBO(31, 51, 96, .9),
      700: Color.fromRGBO(31, 51, 96, .8),
      900: Color.fromRGBO(31, 51, 96, 1),
    },
  );

  static const Color primary = Color.fromRGBO(31, 51, 96, 1);
  static const Color secondary = Color.fromRGBO(228, 172, 49, 1);
  static const Color secondary25 = Color.fromRGBO(228, 172, 49, .25);
  static const Color tertiary = Color.fromRGBO(0, 159, 227, 1);

  static const Color gray900 = Color.fromRGBO(36, 36, 36, 1);
  static const Color gray700 = Color.fromRGBO(85, 85, 85, 1);
  static const Color gray500 = Color.fromRGBO(75, 75, 75, 1);
  static const Color gray400 = Color.fromRGBO(150, 150, 150, 1);
  static const Color gray300 = Color.fromRGBO(219, 219, 219, 1);
  static const Color gray100 = Color.fromRGBO(245, 245, 245, 1);

  static const Color reportColor01 = Colors.amber;
  static const Color reportColor02 = Colors.green;
  static const Color reportColor03 = Colors.deepOrange;
}
