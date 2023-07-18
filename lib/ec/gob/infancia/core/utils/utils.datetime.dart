/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-27
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

/// Clase utilitaria para la gestión de campos de fecha.
class UtilsDatetime {
  /// Abre el calendario de la app para seleccionar una fecha.
  static openCalendar({
    required BuildContext context,
    String? hintText,
    required DateTime initialDate,
    required DateTime firstDate,
    required void Function(DateTime? picked) onPicked,
  }) {
    var theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _showAndroidCalendar(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          onPicked: onPicked,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _showIOsCalendar(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          onPicked: onPicked,
        );
        break;
    }
  }

  /// Calendario para dispositivos Android.
  static _showAndroidCalendar({
    required BuildContext context,
    String hintText = '',
    required DateTime initialDate,
    required DateTime firstDate,
    required void Function(DateTime? picked) onPicked,
  }) {
    showDatePicker(
      context: context,
      locale: const Locale('es', 'EC'),
      helpText: hintText,
      firstDate: firstDate,
      initialDate: initialDate,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: UtilsColorPalette.primary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: UtilsColorPalette.secondary,
            ),
          ),
        ),
        child: child!,
      ),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    ).then(onPicked);
  }

  /// Calendario para dispositivos iOS.
  static _showIOsCalendar({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required void Function(DateTime? picked) onPicked,
  }) {
    var currentYear = DateTime.now().year;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: onPicked,
            initialDateTime: initialDate,
            minimumDate: firstDate,
            maximumYear: currentYear,
          ),
        );
      },
    );
  }

  /// Calcular la edad según la fecha de nacimiento.
  static int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();

    var diff = currentDate.difference(birthDate);
    var diffInDays = diff.inDays - 730;
    var diffInYears = diff.inDays ~/ 365;

    if (diffInDays < 0) {
      return diffInYears;
    } else if (diffInYears == 2) {
      diffInYears++;
    }
    return diffInYears;
  }

  static String calculateAgeAMD(DateTime birthDate) {
    DateTime currentDate = DateTime.now();

    var diff = currentDate.difference(birthDate);
    var diffInYears = diff.inDays ~/ 365;

    if (diffInYears == 2) {
      diffInYears++;
    }

    var restDays=diff.inDays-(365*diffInYears);
    var diffMoths=restDays ~/30.417;
    var restDaysAux= (restDays-(diffMoths.toDouble()*30.417))~/1;
    return "$diffInYears años $diffMoths meses $restDaysAux días";
  }

}
