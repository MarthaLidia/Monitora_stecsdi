/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.home;


class HomeBloc extends BaseBloc<HomeBlocState> {
  late String username;
  final ScrollController _drawerScrollController = ScrollController();

  HomeBloc({
    required context,
  }) : super(context: context, creator: () => HomeBlocState());

  @override
  onLoad() async {
    state.loading = true;
    //await handleSyncAll();
    username = (await prefs).getString('username')!;
    sqliteDB.query(
      'User',
      where: 'u_username = ?',
      whereArgs: [username],
    ).then((value) {
      var user = ModelUser.db(value[0]);
      state.addData('userInfo', user);
      state.loading = false;
    });

    state.addData('syncApp', false);

    state.addData('syncPeople', true);
    state.addData('totalPeople', (await prefs).getInt('totalPeople') ?? 0);
    sqliteDB
        .rawQuery('SELECT COUNT(document) AS total FROM PeopleData')
        .then((value) {
      state.addData('syncPeople', false);
      state.addData('totalPeopleLoaded', value[0]['total'] ?? 0);
    });

    state.addData('syncRs', true);
    state.addData('totalRs', (await prefs).getInt('totalRs') ?? 0);
    sqliteDB
        .rawQuery('SELECT COUNT(document) AS total FROM RsData')
        .then((value) {
      state.addData('syncRs', false);
      state.addData('totalRsLoaded', value[0]['total'] ?? 0);
    });

    handleLoadOffline();

    await checkConnectivity();
    if (state.isOnline) {
      handleQuestionSync(showAlert: false);
    }
  }

  /// Permite cargar la información offline.
  handleLoadOffline() {

    state.loading = true;
    sqliteDB.query('FormHeader').then((formHeader) {
      var formList = formHeader
          .map((data) => ModelFormHeader.db(data))
          .where((element) => element.username==state.data["userInfo"].username)
          .toList()
          .cast<ModelFormHeader>();

      state.addData('forms', formList);
      state.loading = false;
      /*print("Form List");
      print(formList.first.username);
      print(state.data["userInfo"].username);*/
    });
  }

  /// Permite cargar la información online.
  handleLoadOnline() async{
    state.addData('syncOnline', true);
    try{
      List<dynamic> res1= await UtilsHttp.get<List<dynamic>>(
        url: 'v1/registry/form',
      );

      var headers = res1.map((item) => ModelFormHeader.from(item)).toList();
      await sqliteDB.transaction((txn) async {
        for (var header in headers) {
          for (var answer in header.answers ?? <ModelFormAnswer>[]) {
            answer.header = header.id;
            await txn.insert(
              'FormAnswer',
              answer.toDb(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await txn.insert(
            'FormHeader',
            header.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          txn.query('FormAnswer',
              where: 'fa_question = ?',
              whereArgs: ['p_01']).then((people) async {
            for (var person in people) {
              var answer = ModelFormAnswer.db(person);
              var questions = await txn.query('FormAnswer',
                  where:
                  'fa_header = ? AND fa_code = ? AND fa_question IN (?, ?, ?)',
                  whereArgs: [header.id, answer.code, 'p_04', 'p_05', 'p_06']);

              var doc = questions.firstWhere(
                    (item) => item['fa_question'] == 'p_04',
                orElse: () => {'fa_other': null},
              )['fa_other'];
              var lastNames = questions.firstWhere(
                    (item) => item['fa_question'] == 'p_05',
                orElse: () => {'fa_other': null},
              )['fa_other'];
              var names = questions.firstWhere(
                    (item) => item['fa_question'] == 'p_06',
                orElse: () => {'fa_other': null},
              )['fa_other'];

              var womanAns = await txn.query(
                'FormAnswer',
                where:
                'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'm_%', 0],
              );

              var personAns = await txn.query(
                'FormAnswer',
                where:
                'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'p_%', 0],
              );
              var childAns = await txn.query(
                'FormAnswer',
                where:
                'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'n_%', 0],
              );
              var gender = await txn.query(
                'FormAnswer',
                where: 'fa_header = ? AND fa_code = ? AND fa_question = ?',
                whereArgs: [header.id, answer.code, 'p_07'],
              );

              dynamic personInfo = {
                'fpi_header': header.id,
                'fpi_code': answer.code,
                'fpi_document': doc,
                'fpi_lastName': lastNames,
                'fpi_name': names,
                'fpi_ready': 1,
                'fpi_gender': gender.isEmpty ? 0 : gender[0]['fa_other'] ?? '0',
                'fpi_person_answers': personAns.length,
                'fpi_woman_answers': womanAns.length,
                'fpi_child_answers': childAns.length,
              };
              sqliteDB.insert(
                'FormPersonInfo',
                personInfo,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          });
        }
      });
      UtilsToast.showSuccess(localizations.homeSyncFormsMessage);
    }catch(error){
      if (kDebugMode) {
        print('[ERROR] Home Load Online: $error');
      }
    }finally{
      state.addData('syncOnline', false);
      handleLoadOffline();
    }

    return;
    UtilsHttp.get<List<dynamic>>(
      url: 'v1/registry/form',
    ).then((res) {
      var headers = res.map((item) => ModelFormHeader.from(item)).toList();
      sqliteDB.transaction((txn) async {
        for (var header in headers) {
          for (var answer in header.answers ?? <ModelFormAnswer>[]) {
            answer.header = header.id;
            await txn.insert(
              'FormAnswer',
              answer.toDb(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await txn.insert(
            'FormHeader',
            header.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          txn.query('FormAnswer',
              where: 'fa_question = ?',
              whereArgs: ['p_01']).then((people) async {
            for (var person in people) {
              var answer = ModelFormAnswer.db(person);
              var questions = await txn.query('FormAnswer',
                  where:
                      'fa_header = ? AND fa_code = ? AND fa_question IN (?, ?, ?)',
                  whereArgs: [header.id, answer.code, 'p_04', 'p_05', 'p_06']);

              var doc = questions.firstWhere(
                (item) => item['fa_question'] == 'p_04',
                orElse: () => {'fa_other': null},
              )['fa_other'];
              var lastNames = questions.firstWhere(
                (item) => item['fa_question'] == 'p_05',
                orElse: () => {'fa_other': null},
              )['fa_other'];
              var names = questions.firstWhere(
                (item) => item['fa_question'] == 'p_06',
                orElse: () => {'fa_other': null},
              )['fa_other'];

              var womanAns = await txn.query(
                'FormAnswer',
                where:
                    'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'm_%', 0],
              );

              var personAns = await txn.query(
                'FormAnswer',
                where:
                    'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'p_%', 0],
              );
              var childAns = await txn.query(
                'FormAnswer',
                where:
                    'fa_header = ? AND fa_code = ? AND fa_question LIKE ? AND fa_complete = ?',
                whereArgs: [header.id, answer.code, 'n_%', 0],
              );
              var gender = await txn.query(
                'FormAnswer',
                where: 'fa_header = ? AND fa_code = ? AND fa_question = ?',
                whereArgs: [header.id, answer.code, 'p_07'],
              );

              dynamic personInfo = {
                'fpi_header': header.id,
                'fpi_code': answer.code,
                'fpi_document': doc,
                'fpi_lastName': lastNames,
                'fpi_name': names,
                'fpi_ready': 1,
                'fpi_gender': gender.isEmpty ? 0 : gender[0]['fa_other'] ?? '0',
                'fpi_person_answers': personAns.length,
                'fpi_woman_answers': womanAns.length,
                'fpi_child_answers': childAns.length,
              };
              sqliteDB.insert(
                'FormPersonInfo',
                personInfo,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          });
        }
      }).then((_) {});
      UtilsToast.showSuccess(localizations.homeSyncFormsMessage);
    }).catchError((error) {
      if (kDebugMode) {
        print('[ERROR] Home Load Online: $error');
      }
    }).whenComplete(() {
      state.addData('syncOnline', false);
      handleLoadOffline();
    });
  }

  /// Realiza un logout de la aplicación.
  handleLogout() async {
    sqliteDB.delete('User');
    await (await prefs).remove('username');
    await (await prefs).remove('cookie');
    // ignore: use_build_context_synchronously
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginWidget.routeName, (route) => false);
  }

  /// Actualiza las zonas según el usuario.
  handleLoadZones() {
    state.addData('syncZones', true);
    UtilsHttp.get<List<dynamic>>(
      url: 'v1/security/user/locations/:username',
      urlParams: {'username': username},
    ).then((res) {
      var userLocations =
          res.map((item) => item['location']).toList().cast<String>();
      UtilsHttp.get<List<dynamic>>(
        url: 'location',
        isPeople: true,
        queryParams: {'city': userLocations},
      ).then((res) {
        var cities = [];
        var citiesSelection = <String, bool?>{};
        var locations = [];
        for (var location in res) {
          if (cities
              .where((item) => item['code'] == location['city'])
              .isEmpty) {
            cities.add({
              'code': location['city'],
              'label': location['cityLabel'],
            });
            citiesSelection[location['city']] = false;
          }
          locations.add({
            'code': location['location'],
            'label': location['locationLabel'],
            'parent': location['city'],
          });
        }
        state.addData('cities', cities);
        state.addData('locations', locations);
        state.addData('zoneSelection', <String, bool>{});
        state.addData('parentSelection', citiesSelection);
      }).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Home Load Zones: $error');
        }
        UtilsToast.showDanger(localizations.homeDataZoneSyncErrorMessage);
      }).whenComplete(() => state.addData('syncZones', false));
    });
  }

  /// Actualiza la base de personas en el dispositivo.
  handleLoadPeople() async {
    var zonesValues = state.zoneSelection.values;
    if (!zonesValues.contains(true)) {
      UtilsToast.showWarning(localizations.homePeopleNoSelectionMessage);
      return;
    }

    state.addData('syncPeople', true);
    state.addData('syncRs', true);

    var locations = <String>[];
    for (var key in state.zoneSelection.keys) {
      if (state.zoneSelection[key] != null && state.zoneSelection[key]!) {
        locations.add(key);
      }
    }

    state.addData('peopleStopwatch', Stopwatch()..start());
    state.addData('totalPeople', 0);
    state.addData('totalPeopleLoaded', 0);
    await sqliteDB.delete('PeopleData');

    state.addData('rsStopwatch', Stopwatch()..start());
    state.addData('totalRs', 0);
    state.addData('totalRsLoaded', 0);
    await sqliteDB.delete('RsData');

    sqliteDB.transaction((txn) async {
      _manualChangeQty();
      _handlePeopleData(locations, txn);
      _handleRsData(locations, txn);
    }).then((_) {});
  }

  /// Gestiona de forma manual al contador que se visualiza en el dispositivo.
  _manualChangeQty() {
    if (state.data['totalPeopleLoaded'] == 0 ||
        state.data['totalRsLoaded'] == 0) {
      Future.delayed(const Duration(milliseconds: 1000)).then((_) {
        state.addData('incrementForStopwatch',
            state.data['incrementForStopwatch'] ?? 0 + 1);
        _manualChangeQty();
      });
    } else {
      state.addData('incrementForStopwatch', null);
    }
  }

  /// Gestiona la carga de datos de personas en el dispositivo.
  _handlePeopleData(List<String> locations, Transaction txn) {
    UtilsHttp.get<List<dynamic>>(
      url: 'person',
      isPeople: true,
      queryParams: {'location': locations},
    ).then((res) async {
      var prev = state.data['totalPeople'] ?? 0;
      var total = prev + res.length;
      (await prefs).setInt('totalPeople', total);
      state.addData('totalPeople', total);
      state.addPeopleData(res);

      for (var item in res) {
        state.addData(
            'totalPeopleLoaded', prev + state.data['totalPeopleLoaded'] + 1);
        await txn.insert(
          'PeopleData',
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      state.addData('syncPeople', false);
      state.data['peopleStopwatch'].stop();
    }).catchError((_) {
      UtilsToast.showDanger(localizations.homeDataErrorMessage);
      state.addData('syncPeople', false);
      state.data['peopleStopwatch'].stop();
    });
  }

  /// Gestiona la carga de datos de RS en el dispositivo.
  _handleRsData(List<String> locations, Transaction txn) {
    UtilsHttp.get<List<dynamic>>(
      url: 'socialregistry',
      isPeople: true,
      queryParams: {'location': locations},
    ).then((res) async {
      var prev = state.data['totalRs'] ?? 0;
      var total = prev + res.length;
      (await prefs).setInt('totalRs', total);
      state.addData('totalRs', total);
      state.addRsData(res);

      for (var item in res) {
        state.addData('totalRsLoaded', prev + state.data['totalRsLoaded'] + 1);
        await txn.insert(
          'RsData',
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      state.addData('syncRs', false);
      state.data['rsStopwatch'].stop();
    }).catchError((error) {
      UtilsToast.showDanger(localizations.homeDataErrorMessage);
      state.addData('syncRs', false);
      state.data['rsStopwatch'].stop();
    });
  }

  /// Sincroniza las preguntas en el dispositivo.
  handleQuestionSync({bool showAlert = true}) async{
    state.addData('syncApp', true);
    await sqliteDB.transaction((txn) async {
      await txn.delete('Question');
      await txn.delete('AnswerValidation');
      try{
        List<dynamic> res= await  UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question');
        var questions = res.map((item) => ModelQuestion.from(item)).toList();
        for (var question in questions) {
          await txn.insert(
            'Question',
            question.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        if (showAlert) {
          UtilsToast.showSuccess(localizations.homeQuestionsSyncSuccessMessage);
        }

        List<dynamic> res1= await UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question/validations');
        var validations =
        res1.map((item) => ModelAnswerValidation.from(item)).toList();
        for (var validation in validations) {
          await txn.insert(
            'AnswerValidation',
            validation.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

      }catch(error){
        if (kDebugMode) {
          print('[ERROR] Home Questions Sync: $error');
        }
      }finally{
        state.addData('syncApp', false);
      }

      return;
      UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question')
          .then((res) async {
        var questions = res.map((item) => ModelQuestion.from(item)).toList();
        for (var question in questions) {
          await txn.insert(
            'Question',
            question.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        if (showAlert) {
          UtilsToast.showSuccess(localizations.homeQuestionsSyncSuccessMessage);
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Home Questions Sync: $error');
        }
      }).whenComplete(() {
        state.addData('syncApp', false);
      });

      UtilsHttp.get<List<dynamic>>(url: 'v1/registry/question/validations')
          .then((res) async {
        var validations =
            res.map((item) => ModelAnswerValidation.from(item)).toList();
        for (var validation in validations) {
          await txn.insert(
            'AnswerValidation',
            validation.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('[ERROR] Home Validations Sync: $error');
        }
      });
    });
  }

  /// Gestiona la sincronización de los formularios.
  void _handleSync(ModelFormHeader form) async {
    if (state.data['saving_${form.id}'] != null &&
        state.data['saving_${form.id}']) {
      return;
    }

    state.addData('saving_${form.id}', true);
    var formId = form.id;
    UtilsHttp.checkConnectivity().then((_) {
      FormUtils.submitForm(
        context,
        state,
        formId,
        localizations,
        onCompleteOffline: () {
          state.addData('saving_${form.id}', null);
        },
        onCompleteOnline: () {
          handleLoadOffline();
          state.addData('saving_${form.id}', null);
        },
        onError: () {
          UtilsToast.showWarning(localizations.fieldFormError_WAITING_ERROR);
          state.addData('saving_${form.id}', null);
        },
        module: form.module,
      );
    });
  }

  /// Elimina los formularios locales del dispositivo.
  void _handleDelete(ModelFormHeader form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          top: 20,
          right: 20,
          bottom: 10,
          left: 20,
        ),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: [
              TextSpan(
                text: localizations.homeDeleteFormLabel,
              ),
              const TextSpan(
                text: '\n',
              ),
              TextSpan(
                text: localizations.homeDeleteFormQuestion,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(
          top: 10,
          right: 20,
          bottom: 20,
          left: 20,
        ),
        buttonPadding: EdgeInsets.zero,
        actions: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                _handleDeleteItem(form);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded),
                  Text(localizations.homeDeleteFormYes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _handleDeleteItem(ModelFormHeader form) async {
    sqliteDB.delete(
      'FormAnswer',
      where: 'fa_header = ? AND fa_module = ?',
      whereArgs: [form.id, form.module],
    );
    sqliteDB.delete(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [form.id, form.module],
    );


    sqliteDB.delete(
      'FormPersonInfo',
      where: 'fpi_header = ?',
      whereArgs: [form.id],
    ).then((res) {});

    var forms = state.forms;
    forms.remove(form);
    state.addData('forms', forms);

    handleLoadOffline();

    Navigator.of(context).pop();
  }

  /// Actualiza la ubicación de los formularios de forma manual.
  _manualUpdateLocation(
    ModelFormHeader form,
    double latitude,
    double longitude,
  ) async {
    await checkConnectivity();
    if (state.isOnline) {
      var placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'es_EC',
      );
      var reverseAddress =
          '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].postalCode}';
      form.reverseAddress = reverseAddress;
    }

    form.latitude = double.parse(latitude.toStringAsFixed(7));
    form.longitude = double.parse(longitude.toStringAsFixed(7));

    await sqliteDB.update(
      'FormHeader',
      form.toDb(),
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [form.id, Module01Constants.moduleId],
    );
  }

  /// Permite sincronizar las zonas de DPA para usar en campo de autocompletado.
  _handleDpaSync()async {
    state.addData('syncDpa', true);
    UtilsHttp.get<List<dynamic>>(
      url: 'location',
      isPeople: true,
    ).then((res) {
      var locations = res.map((item) => ModelLocation.from(item)).toList();
      sqliteDB.transaction((txn) async {
        for (var location in locations) {
          await txn.insert(
            'Location',
            location.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }).then((_) {});
      UtilsToast.showSuccess(localizations.homeSyncDpaMessage);
    }).catchError((error) {
      if (kDebugMode) {
        print('[ERROR] Home DPA Sync: $error');
      }
    }).whenComplete(() {
      state.addData('syncDpa', false);
    });
  }

  ///obtener información del cedulado.
  handleMotherInfo(cedula){

    UtilsHttp.get<List<dynamic>>(
        url: 'https://brigadas.infancia.gob.ec:8091/api/person/public/',
        queryParams: {'document':cedula}
    ).then((res) {
      state.addData('motherInfo', res);
    },onError: (err){
      print('[ERROR] Home DPA Sync: $err');
    });
  }
  getProvincia() async {
    state.addData('syncDpa', true);
    try{
      var uri =Uri.https(
          "brigadas.infancia.gob.ec:8091",
          "/api/location"
      );
      var response=await http.get(uri);
      List<dynamic> res= await UtilsHttp.finalResponse(response, uri.toString());
      var locations = res.map((item) => ModelLocation.from(item)).toList();
      sqliteDB.transaction((txn) async {
        for (var location in locations) {
          await txn.insert(
            'Location',
            location.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }).then((_) {});
      UtilsToast.showSuccess(localizations.homeSyncDpaMessage);
      state.addData('syncDpa', false);
    }catch(err){
      state.addData('syncDpa', false);
      print(err);
      print("[ERROR] ${err.toString()}");
    }
  }



  getCaptacion() async {
    state.addData('syncDpa', true);
    try{
      var uri =Uri.https(
          "brigadas.infancia.gob.ec:8091",
          "/api/location"
      );
      var response=await http.get(uri);
      List<dynamic> res= await UtilsHttp.finalResponse(response, uri.toString());
      var locations = res.map((item) => ModelLocation.from(item)).toList();
      sqliteDB.transaction((txn) async {
        for (var location in locations) {
          await txn.insert(
            'Location',
            location.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }).then((_) {});
      UtilsToast.showSuccess(localizations.homeSyncDpaMessage);
      state.addData('syncDpa', false);
    }catch(err){
      state.addData('syncDpa', false);
      print(err);
      print("[ERROR] ${err.toString()}");
    }
  }


  handleSyncAll() async {
    await getProvincia();
    await handleQuestionSync();
    await handleLoadOnline();
    await _handleDpaSync();
    //await handleLoadOffline();
  }
}
