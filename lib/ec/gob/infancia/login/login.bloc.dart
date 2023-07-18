/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-13
/// @Updated: 2022-01-27

part of ec.gob.infancia.ecuadorsincero.login;

class LoginBloc extends BaseBloc<LoginBlocState> {
  LoginBloc({
    required context,
  }) : super(context: context, creator: () => LoginBlocState());

  @override
  onLoad() async {
    var userController = TextEditingController();
    var passController = TextEditingController();

    state.addData('userController', userController);
    state.addData('passController', passController);
  }

  /// Ejecuta la acción de iniciar sesión en el dispositivo.
  handleSubmit() {
    if (state.loading) {
      return;
    }

    String user = state.userController?.text ?? '';
    String pass = state.passController?.text ?? '';

    if (user.isEmpty || pass.isEmpty) {
      UtilsToast.showDanger(localizations.userAndPassRequired);
      return;
    }

    state.loading = true;
    UtilsHttp.auth(user: user, pass: pass).then((_) {
      _doWhoAmI();
      _doQuestionCatalog();
    }).catchError((error) {
      if (kDebugMode) {
        print('ERROR: $error');
      }
      UtilsToast.showDanger(error.toString().replaceAll('Exception: ', ''));
    }).whenComplete(() => state.loading = false);
  }

  /// Obtiene la información del usuario conectado.
  _doWhoAmI() {
    UtilsHttp.get<Map<String, dynamic>>(url: 'v1/whoami').then((res) async {
      var user = ModelUser.from(res);
      print(res);
      (await prefs).setString('username', user.username);
      sqliteDB.insert(
        'User',
        user.toJsonDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeWidget.routeName,
        (route) => false,
      );
    }).catchError((error) {
      if (kDebugMode) {
        print('[ERROR] Login Who am I: $error');
      }
    }).whenComplete(() => state.loading = false);
  }

  /// Obtiene la información de las preguntas.
  _doQuestionCatalog() {
    sqliteDB.transaction((txn) async {
      await txn.delete('Question');
      await txn.delete('AnswerValidation');

      UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question').then(
        (res) async {
          var questions = res.map((item) => ModelQuestion.from(item)).toList();
          for (var question in questions) {
            await txn.insert(
              'question',
              question.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        },
      ).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Login Questions Sync: $error');
        }
      });

      UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question/validations')
          .then(
        (res) async {
          var validations =
              res.map((item) => ModelAnswerValidation.from(item)).toList();
          for (var validation in validations) {
            await txn.insert(
              'AnswerValidation',
              validation.toDb(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        },
      ).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Login Validations Sync: $error');
        }
      });

      UtilsHttp.get<List<dynamic>>(url: 'location', isPeople: true).then(
        (res) async {
          var locations = res.map((item) => ModelLocation.from(item)).toList();
          for (var location in locations) {
            await txn.insert(
              'Location',
              location.toDb(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        },
      ).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Login Locations Sync: $error');
        }
      });
    }).then((_) {});
  }
}
