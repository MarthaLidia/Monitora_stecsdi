/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2021-05-17

part of ec.gob.infancia.ecuadorsincero.utils;

/// Utilitario que administra las rutas de la aplicación.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  Widget? screen;

  switch (settings.name) {
    case HomeWidget.routeName:
      screen = const HomeWidget();
      break;
    case LoginWidget.routeName:
      screen = const LoginWidget();
      break;
    case PlanningWidget.routeName:
      screen = const PlanningWidget();
      break;
    case FormHouseWidget.routeName:
      screen = const FormHouseWidget();
      break;
    case FormHouseWidget.routeNameEdit:
      Map<String, int?> param = {
        'id': null,
      };
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        param['id'] = args['id'];
      }
      screen = FormHouseWidget(
        formId: param['id'],
      );
      break;
    case FormHomeWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = FormHomeWidget(
        formId: id,
      );
      break;
    case FormPeopleWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = FormPeopleWidget(
        formId: id,
      );
      break;
    case FormPersonWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = FormPersonWidget(
        formId: id,
        code: code,
      );
      break;
    case FormWomanWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = FormWomanWidget(
        formId: id,
        code: code,
      );
      break;
    case FormChildWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = FormChildWidget(
        formId: id,
        code: code,
      );
      break;

    case FormsMapWidget.routeName:
      var latitude = 0.0;
      var longitude = 0.0;

      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        latitude = args['latitude'];
        longitude = args['longitude'];
      }
      screen = FormsMapWidget(
        latitude: latitude,
        longitude: longitude,
      );
      break;

    // TODO: TEMP ROUTING
    case module02.FormHouseWidget.routeName:
      screen = const module02.FormHouseWidget();
      break;
    case module02.FormHouseWidget.routeNameEdit:
      Map<String, int?> param = {
        'id': null,
      };
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        param['id'] = args['id'];
      }
      screen = module02.FormHouseWidget(
        formId: param['id'],
      );
      break;
    case module02.FormHomeWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module02.FormHomeWidget(
        formId: id,
      );
      break;
    case module02.FormPeopleWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module02.FormPeopleWidget(
        formId: id,
      );
      break;
    case module02.FormPersonWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module02.FormPersonWidget(
        formId: id,
        code: code,
      );
      break;
    case module02.FormWomanWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module02.FormWomanWidget(
        formId: id,
        code: code,
      );
      break;
    case module02.FormChildWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module02.FormChildWidget(
        formId: id,
        code: code,
      );
      break;
  // TODO: TEMP ROUTING modulo 3
    case module03.FormHouseWidget.routeName:
      screen = const module03.FormHouseWidget();
      break;
    case module03.FormHouseWidget.routeNameEdit:
      Map<String, int?> param = {
        'id': null,
      };
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        param['id'] = args['id'];
      }
      screen = module03.FormHouseWidget(
        formId: param['id'],
      );
      break;
    case module03.FormHomeWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module03.FormHomeWidget(
        formId: id,
      );
      break;
    case module03.FormPeopleWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module03.FormPeopleWidget(
        formId: id,
      );
      break;
    case module03.FormPersonWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module03.FormPersonWidget(
        formId: id,
        code: code,
      );
      break;
    case module03.FormWomanWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module03.FormWomanWidget(
        formId: id,
        code: code,
      );
      break;
    case module03.FormChildWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module03.FormChildWidget(
        formId: id,
        code: code,
      );
      break;


  // TODO: TEMP ROUTING modulo 5
    case module05.FormHouseWidget.routeName:
      screen = const module05.FormHouseWidget();
      break;
    case module05.FormHouseWidget.routeNameEdit:
      Map<String, int?> param = {
        'id': null,
      };
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        param['id'] = args['id'];
      }
      screen = module05.FormHouseWidget(
        formId: param['id'],
      );
      break;
    case module05.FormHomeWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module05.FormHomeWidget(
        formId: id,
      );
      break;
    case module05.FormPeopleWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module05.FormPeopleWidget(
        formId: id,
      );
      break;
    case module05.FormPersonWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module05.FormPersonWidget(
        formId: id,
        code: code,
      );
      break;
    case module05.FormWomanWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module05.FormWomanWidget(
        formId: id,
        code: code,
      );
      break;
    case module05.FormChildWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module05.FormChildWidget(
        formId: id,
        code: code,
      );
      break;
  // TODO: TEMP ROUTING modulo 6
    case module06.FormHouseWidget.routeName:
      screen = const module06.FormHouseWidget();
      break;
    case module06.FormHouseWidget.routeNameEdit:
      Map<String, int?> param = {
        'id': null,
      };
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        param['id'] = args['id'];
      }
      screen = module06.FormHouseWidget(
        formId: param['id'],
      );
      break;
    case module06.FormHomeWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module06.FormHomeWidget(
        formId: id,
      );
      break;
    case module06.FormPeopleWidget.routeName:
      int id = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
      }
      screen = module06.FormPeopleWidget(
        formId: id,
      );
      break;
    case module06.FormPersonWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module06.FormPersonWidget(
        formId: id,
        code: code,
      );
      break;
    case module06.FormWomanWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module06.FormWomanWidget(
        formId: id,
        code: code,
      );
      break;
    case module06.FormChildWidget.routeName:
      int id = -1;
      int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        code = args['code'];
      }
      screen = module06.FormChildWidget(
        formId: id,
        code: code,
      );
      break;
    // TODO: TEMP ROUTING modulo 4
    case module04.FormHouseWidget.routeName:
      int id = -1;
      //int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        //code = args['code'];
      }
      screen = module04.FormHouseWidget(
        formId: null//id,
        //code: code,
      );
      break;
    case module04.FormEmbarazoWidget.routeName:
      int id = -1;
      //int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        //code = args['code'];
      }
      screen = module04.FormEmbarazoWidget(
          formId: null//id,
        //code: code,
      );
      break;
    case module04.FormChildWidget.routeName:
      int id = -1;
      //int code = -1;
      if (settings.arguments != null) {
        dynamic args = settings.arguments;
        id = args['id'];
        //code = args['code'];
      }
      screen = module04.FormChildWidget(
          formId: null//id,
        //code: code,
      );
      break;

    case ReportsFormsByUserWidget.routeName:
      screen = const ReportsFormsByUserWidget();
      break;
    case ReportsFormsByUserWidget.routeName:
      screen = const ReportsFormsByUserWidget();
      break;
  }
  if (screen != null) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, animationAlt) => screen!,
      transitionsBuilder: (context, animation, animationAlt, child) =>
          SlideTransition(
        position: animation.drive(Tween(
          end: Offset.zero,
          begin: const Offset(1.5, 0.0),
        )),
        child: child,
      ),
    );
  }
  return null;
}
