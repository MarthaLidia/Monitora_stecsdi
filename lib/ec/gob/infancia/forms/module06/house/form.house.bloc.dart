/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2021-05-17

part of ec.gob.infancia.ecuadorsincero.forms.module06.house;

class FormHouseBloc extends BaseBloc<FormHouseBlocState> {
  late int? formId;
  late ModelFormHeader formHeader;
  int code = 0;
  String encuestador = "";
  String nombrecompleto = "";
  String indentificador = "";
  String representante = "";
  late String? representantes = "";
  late String? nombreComplete = "";
  String nombres = "";
  dynamic beneficiario = 0;
  String celular_2 = "";
  String dpa="";

  final ScrollController _autocompleteController = ScrollController();

  FormHouseBloc({
    required context,
    this.formId,
  }) : super(context: context, creator: () => FormHouseBlocState());

  @override
  onLoad() async {
    _handleEditForm();
    state.addData("firma_base64", [""]);
    state.addData("audio_ci", false);

    state.loading = true;
    var username = (await prefs).getString('username');
    var userS = (await prefs).getString('userFullName');
    encuestador = username.toString();
    state.addData('locationController', TextEditingController());

    int id;
    if (formId == null) {
      var formHeaders = await sqliteDB.query('FormHeader');
      var ids = formHeaders.map((item) => item['fh_id']).toList().cast<int>();
      id = -1;
      if (ids.isNotEmpty) {
        var minValue = ids.reduce(min);
        id = minValue > 0 ? 0 : minValue;
        id--;
      }
    } else {
      id = formId!;
    }

    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: id,
      params: ['hs_01', Module06Constants.moduleId],
      action: (questionId) {
        if (questionId == 'h_06' || questionId == 'h_07') {
          formHeader.address =
              '${state.formAnswers['h_06']?.other} ${state.formAnswers['h_07']?.other}';
          sqliteDB.update(
            'FormHeader',
            formHeader.toDb(),
            where: 'fh_id = ? AND fh_module = ?',
            whereArgs: [formHeader.id, Module06Constants.moduleId],
          );
        }
        if (questionId == 'h_15' &&
            state.questionsTextController['h_15']!.text.isNotEmpty) {
          state.setFormErrors('h_16', null);
          /*if (state.questionsTextController['h_15']!.text.length != 9) {
            state.setFormErrors('h_15', localizations.fieldFormError_H15);
          }*/
        } else if (questionId == 'h_16' &&
            state.questionsTextController['h_16']!.text.isNotEmpty) {
          state.setFormErrors('h_15', null);
          if (state.questionsTextController['h_16']!.text.length != 10) {
            state.setFormErrors('h_16', localizations.fieldFormError_H16);
          }
        } /*else if (questionId == 'h_16_1' &&
            state.questionsTextController['h_16_1']!.text.isNotEmpty) {
          state.setFormErrors('h_16_1', null);
          if (state.questionsTextController['h_16_1']!.text.length != 10) {
            state.setFormErrors('h_16_1', localizations.fieldFormError_H16);
          }
        }*/
        else if (questionId == 'h_17') {
          state.setFormErrors('h_17', null);
          if ((state.questionsTextController['h_17']?.text ?? '').isEmpty) {
            FormUtils.removeAnswer(state, ['h_17'], formId!, code);
          }
        }
      },
    );
    //state.data["altura"]=state.data["altitude"];
    if (formId == null) {
      formId = id;
      _handleNewForm();
      sqliteDB.query('Location').then((value) {
        var locations = value
            .map((data) => ModelLocation.db(data))
            .toList()
            .cast<ModelLocation>();
        state.addData('locations', locations);
        state.addData('locationValue', TextEditingValue.empty);
      });
    } else {
      state.addData('formHeader', formId);
      //_handleEditForm();
    }
  }

  _handleNewForm() async {
    var location = await currentLocation;
    await checkConnectivity();
    var reverseAddress = '';
    if (state.isOnline) {
      var placemarks = await geocoding.placemarkFromCoordinates(
        location['latitude']!,
        location['longitude']!,
        localeIdentifier: 'es_EC',
      );
      if (placemarks.isNotEmpty) {
        var placemark = placemarks.first;
        reverseAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}';
      }
    }

    state.addData('formHeader', formId);
    sqliteDB.transaction((txn) async {
      formHeader = ModelFormHeader(
        id: formId!,
        module: Module06Constants.moduleId,
        moduleName: Module06Constants.moduleName,
        latitude: location['latitude'] ?? -1,
        longitude: location['longitude'] ?? -1,
        datetime: DateTime.now(),
        complete: false,
        rsRequest: false,
        comments: '',
        username: state.userInfo.username,
        userFullName: state.userInfo.info.fullName,
        tryNumber: 1,
        reverseAddress: reverseAddress,
        isReady: false,
        code: DateFormat('yyyyMMddHHmmssSSSS').format(DateTime.now()),
        version: state.versionCode,
      );

      await txn
          .insert(
            'FormHeader',
            formHeader.toDb(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .then((value) => state.loading = false);

      await txn.insert(
        'FormRsInfo',
        {
          'frsi_header': formHeader.id,
          'frsi_deficit01': '_',
          'frsi_deficit02': '_',
          'frsi_deficit03': '_',
          'frsi_water': 0,
          'frsi_hygiene': 0,
          'frsi_light': 0,
          'frsi_salary': 0,
          'frsi_food': 0,
          'frsi_alreadyInRs': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _setAutomaticValues(txn);
    }).then((_) {});
  }

  _handleTabBtnNroDoc(String cedula) async {
    final prefs = await SharedPreferences.getInstance();
    print("CEDULA");
    state.loading = true;
    state.questionsTextController["h_06_1"]?.text = "";

    state.loading = true;
    getCaptacionPerson(cedula ?? "").then((value) {
      state.loading = false;
      print("VALUE");
      print(value);

      if (value != null) {
        if (value.isEmpty) {
          UtilsToast.showWarning(
              "No se encontraron datos de la cédula ingresada.");
        }
        var dpacodigo = value["cod_parroquia"] ?? "";
        var dpaprovincia = value["provincia"] ?? "";
        var dpacanton = value["canton"] ?? "";
        var dpaparroquia = value["provincia"] ?? "";
        var dpa = dpacodigo +
            " " +
            dpaprovincia +
            " " +
            dpacanton +
            " " +
            dpaparroquia;
        print("PROVINCIAL");
        print(dpa);
        state.addData("dpa", dpa);
        var nombrecompleto = value["p_nombres_apellidos"] ?? "";
        beneficiario = value["tipo_beneficio"] ?? "";
        var cel = value["celular_1"] ?? "";
        prefs.setString("celular01", cel);
        var hr = int.parse(beneficiario);
        prefs.setInt("identificador", hr);
        representante = value["p_nombres_apellidos_rep"] ?? "";
        print(beneficiario);
        state.addData("nombrecompleto", nombrecompleto);
        state.addData("beneficiario", beneficiario);
        prefs.setString("representante", representante);
        representantes = prefs.getString("representante")!;
        print("REPRESENTANTE");
        print(representantes);
        state.addData("representante", representante);
        var str1 = value["direccion_original"]??"";
        var split1 = str1.split(",");
        var s1 = "";
        if (split1.length > 1) {
          s1 = split1[1];
        }
        var s2 = split1[0];
        print("DIRECCION");
        print(s1);

        state.questionsTextController["h_06_1"]?.text =
            value["identificacion"] ?? "";
        state.questionsTextController["h_06_2"]?.text =
            value["p_nombres"] ?? "";
        state.questionsTextController["h_06_3"]?.text =
            value["p_apellidos"] ?? "";
        state.questionsTextController["h_16"]?.text = value["celular_1"] ?? "";
        state.questionsTextController["h_16_1"]?.text =
            value["celular_2"] ?? "";
        state.questionsTextController["h_01"]?.text =
            value["h_residencia_longitud"] ?? "";
        state.questionsTextController["h_02"]?.text =
            value["h_residencia_latitud"] ?? "";
        state.questionsTextController["h_05"]?.text = dpa;

        state.questionsTextController["h_06_4"]?.text =
            value["direccion_original"] ?? "";
        state.questionsTextController["h_09"]?.text = value["referencia"] ?? "";
      }
    }).catchError((onError) {
      print("error");
      print(onError);
      state.loading = false;
      UtilsToast.showDanger("No se pudo obtener los datos solicitados.");
    });
  }

  Future<dynamic> getCaptacionPerson(cedula) async {
    print("CEDULA");
    try {
      var uri = Uri.https(
          "seguimientodev.infancia.gob.ec", "/api/beneficiariom/$cedula");
      var response = await http.get(uri);
      print("Uri:");
      print(uri);
      if (response.statusCode == 200) {
        var body = json.decode(utf8.decoder.convert(response.bodyBytes));
        print("CAPTADOS");
        print(body);
        return body;
      }
      return {};
    } catch (err) {
      print(err);
      print("[ERROR] ${err.toString()}");
    }
  }

  _handleEditForm() {
    print("Entro al handleEdit");
    sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module06Constants.moduleId],
    ).then((dbData) async {
      formHeader = ModelFormHeader.db(dbData[0]);

      var answersDb = await sqliteDB.query(
        'FormAnswer',
        where:
            'fa_header = ? AND fa_questionParent = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formHeader.id, 'hs_01', code, Module06Constants.moduleId],
      );

      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
          if (state.questionsTextController[item.question] != null) {
            state.questionsTextController[item.question]!.text =
                '${item.other}';
          }
        },
      );

      if (state.formAnswers['h_14']?.other == '1') {
        await _handleConcentimientoDialog('h_14');
      }
      if (state.formAnswers['h_09_4']?.other == '1' || state.formAnswers['h_09_4']?.other == '2') {
        state.addData('showContinuar', true);
      }
      state.loading = false;
      currentLocation.then((_) {});

      sqliteDB.transaction((txn) async {
        _setAutomaticValues(txn);
      }).then((_) {});

      sqliteDB.query('Location').then((value) {
        var locations = value
            .map((data) => ModelLocation.db(data))
            .toList()
            .cast<ModelLocation>();
        state.addData('locations', locations);

        if (state.formAnswers.containsKey('h_05')) {
          print("Entro a la h_05");
          var found = state.locations
              .where(
                  (item) => item.location == state.formAnswers['h_05']!.other)
              .toList();
          print("found");
          print(found);
          if (found.isNotEmpty) {
            var location = found[0];
            state.addData(
              'locationValue',
              TextEditingValue(text: location.label),
            );
          }
        } else if (formId! < 0) {
          print("Esta vacio");
          state.addData('locationValue', TextEditingValue(text: dpa));
          print("valor formId");
          print(TextEditingValue(text: dpa));
        }
      });
    });
  }

  _setAutomaticValues(Transaction txn) async {
    if ((formId ?? 1) > 0) {
      return;
    }
    for (var questionId in ['h_01', 'h_02', 'h_03', 'h_04']) {
      var question = state.questions
          .where((question) => question.id == questionId)
          .toList();
      if (question.isNotEmpty) {
        var answer = question[0].answers[0];
        var answerId = answer.id;
        var value = '';
        switch (questionId) {
          case 'h_01':
            value = '${formHeader.longitude}';
            break;
          case 'h_02':
            value = '${formHeader.latitude}';
            break;
          case 'h_03':
            value = DateFormat('dd-MM-yyyy').format(formHeader.datetime);
            break;
          case 'h_04':
            value = DateFormat('HH:mm').format(formHeader.datetime);
            break;
        }
        await txn.insert(
          'FormAnswer',
          ModelFormAnswer(
            id: -1,
            header: formHeader.id,
            question: questionId,
            questionParent: 'hs_01',
            module: Module06Constants.moduleId,
            answer: answerId,
            code: code,
            other: value,
            complete: true,
          ).toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  handleShowMapLocation() async {
    UtilsHttp.checkConnectivity().then((isOnline) {
      _loadLocation();
      if (state.isOnline) {
        Navigator.of(context).pushNamed(FormsMapWidget.routeName, arguments: {
          'latitude': formHeader.latitude,
          'longitude': formHeader.longitude,
        }).then((value) {
          if (value != null) {
            var latLng = value as LatLng;
            _manualUpdateLocation(latLng.latitude, latLng.longitude);
          }
        });
      }
    });
  }

  _handleQuestionChange(
    String question,
    String parent,
    String module,
    int answer,
    dynamic value,
    int id,
  ) async {
    var formAnswer = FormUtils.saveFormAnswer(
      state: state,
      formId: formId!,
      questionId: question,
      parent: parent,
      module: module,
      answerId: answer,
      value: value,
      id: id,
    );

    var questionsToClean = [];

    FormUtils.manualListViewScroll(state.listViewController);
    FormUtils.removeAnswer(state, questionsToClean, formId!, code);

    switch (question) {
      case 'h_13':
        if (formAnswer.other == '1') {
          //_handleDialog(question)
          _handleUpateDialog(question);
          return;
        }

        /*else {
          //FormUtils.manualListViewScroll(state.listViewController);
          if (formAnswer.other == '1') {
            state.addData('showContinuar', true);
          }
        }*/
        break;
      case 'h_09_4':
        if (formAnswer.other == '1' || formAnswer.other == '2') {
          state.addData('showContinuar', true);
          return;
        }
        break;
      case 'h_09_1':
        if (formAnswer.other == '2') {
          _handleContactDialog(question);
          return;
        }
        break;
      case 'h_09_2':
        if (formAnswer.other == '1') {
          //_handleDialog(question);
          _handleUpateDialog(question);
          return;
        }
        break;
      case 'h_09_2':
        if (formAnswer.other == '2') {
          state.addData('showContinuar', true);
          return;
        }
        break;
      case 'h_09_3':
        if (formAnswer.other == '1' || formAnswer.other == '2') {
          _handleFinalSubmit();
          return;
        }
        break;
    }
  }

  _handleDialog(String question) {
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
                text: question == 'h_12'
                    ? localizations.formEmptyNoChild
                    : localizations.formEmptyHouse,
              ),
              const TextSpan(
                text: '\n',
              ),
              TextSpan(
                text: localizations.dialogConfirmQuestion,
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
          Container(
            width: 75,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                var doesntAllowTries = [
                  'h_12',
                  'h_13',
                  'h_14',
                ].contains(question);
                if (UtilsConstants.automaticSave) {
                  _handleNewLogic(
                    doesntAllowTries: doesntAllowTries,
                    question: question,
                  );
                } else {
                  _handleOldLogic(
                    doesntAllowTries: doesntAllowTries,
                    question: question,
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              child: Text(localizations.dialogConfirmYes),
            ),
          ),
          Container(
            width: 75,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: Text(localizations.dialogConfirmNo),
            ),
          ),
        ],
      ),
    );
  }

  handleSubmit() {
    if (state.saving) {
      return;
    }

    var isValid = _validateForm();

    if (isValid) {
      if (formId! < 0) {
        state.setFormAnswer(
          'h_01',
          ModelFormAnswer(
            id: -1,
            header: formId!,
            question: 'h_01',
            questionParent: 'hs_01',
            module: Module06Constants.moduleId,
            answer: state.questions
                .firstWhere((question) => question.id == 'h_01')
                .answers[0]
                .id,
            other: '${formHeader.latitude}',
            complete: true,
          ),
        );

        state.setFormAnswer(
          'h_02',
          ModelFormAnswer(
            id: -1,
            header: formId!,
            question: 'h_02',
            questionParent: 'hs_01',
            module: Module06Constants.moduleId,
            answer: state.questions
                .firstWhere((question) => question.id == 'h_02')
                .answers[0]
                .id,
            other: '${formHeader.longitude}',
            complete: true,
          ),
        );

        state.setFormAnswer(
          'h_03',
          ModelFormAnswer(
            id: -1,
            header: formId!,
            question: 'h_03',
            questionParent: 'hs_01',
            module: Module06Constants.moduleId,
            answer: state.questions
                .firstWhere((question) => question.id == 'h_03')
                .answers[0]
                .id,
            other: DateFormat('dd-MM-yyyy').format(formHeader.datetime),
            complete: true,
          ),
        );

        state.setFormAnswer(
          'h_04',
          ModelFormAnswer(
            id: -1,
            header: formId!,
            question: 'h_04',
            questionParent: 'hs_01',
            module: Module06Constants.moduleId,
            answer: state.questions
                .firstWhere((question) => question.id == 'h_04')
                .answers[0]
                .id,
            other: DateFormat('hh:mm aa').format(formHeader.datetime),
            complete: true,
          ),
        );
      }

      Navigator.of(context).pushReplacementNamed(
        FormHomeWidget.routeName,
        arguments: {
          'id': formId,
        },
      );
    }
  }

  bool _validateForm() {
    var containsHomePhone = false;
    var containsCellPhone = false;
    var auxq = state.questions.where((element) => element.visible).toList();
    for (var question in auxq) {
      switch (question.id) {
        case 'h_01':
        case 'h_02':
        case 'h_03':
        case 'h_04':
        //case 'h_05':
        case 'h_07':
        case 'h_15':
        case 'h_16_1':
        case 'r_05':
          continue;
        /*case 'h_07':
        case 'h_15':
        case 'h_16_1':
          if (!state.formAnswers.containsKey(question.id)) {
            continue;
          }
          break;*/
      }

      if (!state.formAnswers.containsKey(question.id)) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else {
        var value = state.formAnswers[question.id]?.other ?? '';
        if (value.isEmpty) {
          state.setFormErrors(
              question.id, localizations.fieldIsRequiredMessage);
        } else {
          if (question.id == 'h_15') {
            containsHomePhone = true;
            /*if (value.length != 9) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H15);
            }*/
          }
          if (question.id == 'h_16') {
            containsCellPhone = true;
            /*if (value.length != 10) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H16);
            }*/
          }
          if (question.id == 'h_17') {
            var isValid =
                RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$").hasMatch(value);
            if (!isValid) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H17);
            }
          }
        }
      }
    }

    for (var question in ['h_06', 'h_08', 'h_09']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }

    return true;

    /*return state.formErrors.values
        .where((item) => item != null)
        .join('')
        .isEmpty;*/
  }

  _loadLocation() async {
    var location = await currentLocation;
    if (state.isOnline) {
      formHeader.latitude = location['latitude'] ?? -1;
      formHeader.longitude = location['longitude'] ?? -1;
      formHeader.datetime = DateTime.now();

      try {
        var placemarks = await geocoding.placemarkFromCoordinates(
          location['latitude']!,
          location['longitude']!,
          localeIdentifier: 'es_EC',
        );
        if (placemarks.isNotEmpty) {
          var reverseAddress =
              '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].postalCode}';
          formHeader.reverseAddress = reverseAddress;
        }
      } catch (ex) {
        UtilsHttp.handleError(ex, location: 'Form House Location');
      }

      await sqliteDB.update(
        'FormHeader',
        formHeader.toDb(),
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formHeader.id, Module06Constants.moduleId],
      );
    }
  }

  _manualUpdateLocation(double latitude, double longitude) async {
    await checkConnectivity();
    if (state.isOnline) {
      var placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'es_EC',
      );

      if (placemarks.isNotEmpty) {
        var placemark = placemarks.first;
        var reverseAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.postalCode}';
        formHeader.reverseAddress = reverseAddress;
      }
    }

    formHeader.latitude = double.parse(latitude.toStringAsFixed(7));
    formHeader.longitude = double.parse(longitude.toStringAsFixed(7));

    await sqliteDB.update(
      'FormHeader',
      formHeader.toDb(),
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formHeader.id, Module06Constants.moduleId],
    );
  }

  _handleLocationSelected(ModelLocation location) async {
    state.addData('locationSelected', location.label);
    state.addData(
      'locationValue',
      TextEditingValue(
        text: location.label,
      ),
    );
    var data = ModelFormAnswer(
      id: -1,
      header: formId!,
      question: 'h_05',
      questionParent: 'hs_01',
      module: Module06Constants.moduleId,
      answer: state.questions
          .firstWhere((question) => question.id == 'h_05')
          .answers[0]
          .id,
      other: location.location,
      complete: false,
      code: code,
    );
    state.setFormAnswer('h_05', data);
    sqliteDB.update(
      'FormHeader',
      {'fh_dpa': location.location},
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formHeader.id, Module06Constants.moduleId],
    );

    await sqliteDB.insert(
      'FormAnswer',
      data.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state.setFormErrors('h_05', null);
  }

  _handleEmptyLocationSelected() async {
    if (state.formAnswers.containsKey('h_05')) {
      state.addData('locationSelected', '-1');
      state.removeFormAnswer('h_05');
      sqliteDB.update(
        'FormHeader',
        {'fh_dpa': null},
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formHeader.id, Module06Constants.moduleId],
      );
      sqliteDB.delete(
        'FormAnswer',
        where: 'fa_header = ? AND fa_question = ? AND fa_code = ?',
        whereArgs: [formId, 'h_05', code],
      );
      state.setFormErrors('h_05', localizations.fieldFormError_H05);
    }
  }

  _handleNewLogic({
    required bool doesntAllowTries,
    required String question,
  }) {
    if (doesntAllowTries) {
      sqliteDB.query(
        'Question',
        where: 'q_id in (?, ?) AND q_module = ?',
        whereArgs: [
          'r_02',
          'r_05',
          Module06Constants.moduleId,
        ],
      ).then((questionsDb) async {
        var questions =
            questionsDb.map((question) => ModelQuestion.db(question)).toList();
        var condition = question == 'h_12' ? 5 : 2;
        var questionR02 = questions.firstWhere((item) => item.id == 'r_02');
        var answerR02 =
            questionR02.answers.firstWhere((item) => item.order == condition);
        var questionR05 = questions.firstWhere((item) => item.id == 'r_05');
        var answerR05 = questionR05.answers.first;

        FormUtils.saveFormAnswer(
          state: state,
          formId: formId!,
          questionId: questionR02.id,
          parent: questionR02.parent,
          module: questionR02.module,
          answerId: answerR02.id,
          value: answerR02.order,
          id: state.formAnswers[questionR02.id]?.id ?? -1,
        );

        FormUtils.saveFormAnswer(
          state: state,
          formId: formId!,
          questionId: questionR05.id,
          parent: questionR05.parent,
          module: questionR05.module,
          answerId: answerR05.id,
          value: answerR02.label,
          id: state.formAnswers[questionR05.id]?.id ?? -1,
        );

        sqliteDB
            .update(
          'FormHeader',
          {'fh_complete': 1, 'fh_comments': ''},
          where: 'fh_id = ? AND fh_module = ?',
          whereArgs: [formId, Module06Constants.moduleId],
        )
            .then((_) {
          Navigator.of(context).pop();
          _handleFinalSubmit();
        });
      });
    } else {
      _handleOldLogic(doesntAllowTries: doesntAllowTries, question: question);
    }
  }

  _handleOldLogic({
    required bool doesntAllowTries,
    required String question,
  }) {
    if (formHeader.tryNumber == 3 || doesntAllowTries) {
      Navigator.of(context).pop();
      sqliteDB.update(
        'FormHeader',
        {
          'fh_complete': 1,
          'fh_tryNumber': formHeader.tryNumber + (doesntAllowTries ? 3 : 1),
        },
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formId, Module06Constants.moduleId],
      );
      Navigator.of(context).pushReplacementNamed(
        FormPeopleWidget.routeName,
        arguments: {
          'id': formId,
        },
      );
    } else {
      sqliteDB.update(
        'FormHeader',
        {
          'fh_tryNumber': formHeader.tryNumber + 1,
        },
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formId, Module06Constants.moduleId],
      );
      state.removeFormAnswer(question);
      sqliteDB.delete(
        'FormAnswer',
        where:
            'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formId, question, code, Module06Constants.moduleId],
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeWidget.routeName,
        (route) => false,
      );
    }
  }

  _handleFinalSubmit() async {
    state.saving = true;
    UtilsHttp.checkConnectivity().then((val) {
      FormUtils.submitForm(
        context,
        state,
        formId!,
        localizations,
        onCompleteOffline: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );
        },
        onCompleteOnline: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );
        },
        onError: () {
          UtilsToast.showWarning(localizations.fieldFormError_WAITING_ERROR);
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );
        },
        module: Module06Constants.moduleId,
      );
    });
  }

  Future<String> _handleConcentimientoDialog(String question) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
              children: [
                RichText(
                    text: TextSpan(
                        text: "Propósito del documento\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Levantamiento de información personal de mujeres gestantes y niños/as menores de 2 años, con la finalidad de realizar la caracterización primaria de la población objetivo a través de un conjunto de variables que determinan el acercamiento de los usuarios a los servicios de salud materno infantil, protección social, educación, entre otros y la generación de alertas de atención en el marco de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil mediante un sistema unificado a nivel interinstitucional.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text: "Descripción del Proceso\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "1. La Secretaría Técnica Ecuador Crece sin Desnutrición Infantil, a través formulario web de captación de población objetivo y de los diferentes mecanismos establecidos, realiza la captación y levantamiento de información de mujeres gestantes y niños/as menores de 2 años." +
                        '\n' +
                        "2. La información recopilada será revisada, sistematizada y validada por el personal de la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil." +
                        '\n' +
                        "3.La información que usted proporcione, en caso de ser necesario, se derivará a las instituciones públicas correspondientes que dentro de sus competencias puedan atender las necesidades específicas de cada caso, a fin de que se brinde la atención que corresponda, en el marco de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil y otras destinadas a la población objetivo que sean prestadas por las instituciones de la Función ejecutiva.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text:
                            "Derechos y opciones de quien remite la información\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Recuerde que su participación y la decisión de brindar la información requerida en los instrumentos que utiliza la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil para el levantamiento de información es voluntaria. Si usted no desea entregar información, no acepte este consentimiento informado; esto no ocasionará consecuencias negativas al respecto. Usted puede, en cualquier momento, revocar el consentimiento que ha dado, haciéndole conocer del particular a la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil a través del correo electrónico: tramites@infancia.gob.ec.El otorgamiento de datos erróneos o inexactos podría derivar en que no le puedan ser brindadas apropiadamente las atenciones de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil y las que sean prestadas por las demás instituciones de la Función Ejecutiva.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text:
                            "Finalidad del tratamiento de los datos personales\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Sus datos personales y/o los de su representado/a (en los casos en los que corresponda) serán tratados para efectuar las articulaciones en territorio, de conformidad con lo establecido en la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil; así como, articular prestaciones para la población objetivo con otras instituciones de la Función Ejecutiva.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text: "Base legal\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Artículos 8, 10, 12 y 33 de la Ley Orgánica de Protección de Datos Personales." +
                        '\n' +
                        "Artículos 26 y 28 del Código Orgánico Administrativo.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text:
                            "Identidad y datos de contacto del responsable del tratamiento de datos personales\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Dirección de domicilio legal de la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil: Av. Atahualpa OE1 109 y 10 de Agosto, Quito - Ecuador " +
                        '\n' +
                        "Número de teléfono: 593 23995600",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text: "Confidencialidad de los datos\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "Para la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil es muy importante mantener su privacidad, por lo que se tomarán las medidas necesarias, a fin de precautelar los datos de identidad, contactabilidad y demás información proporcionada en este instrumento. En ningún caso se compartirá la información recopilada utilizando sistemas de información y/o herramientas informáticas/redes sociales, que no se encuentren sujetos o cumplan con los parámetros establecidos en la política de seguridad de la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil. Se garantiza que la información obtenida, se manejará de forma estrictamente confidencial, con el fin de la generación de alertas de atención en el marco de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil y otras prestaciones a la población objetivo que brinden las instituciones de la Función Ejecutiva.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text: "Consentimiento informado" + '\n' + "DECLARO\n",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "● Que he leído la información del presente documento. " +
                        '\n' +
                        "● Que he comprendido lo expuesto en el presente documento." +
                        '\n' +
                        "● Que he comprendido de mis derechos como titular de mis datos personales y /o los de mi representado/a (en los casos que corresponda), conforme los parámetros que establece la Ley Orgánica de Protección de Datos Personales, los mismos que me hacen parte del presente documento." +
                        '\n' +
                        "● Que he comprendido de mis derechos como titular de mis datos personales y /o los de mi representado/a (en los casos que corresponda), conforme los parámetros que establece la Ley Orgánica de Protección de Datos Personales, los mismos que me hacen parte del presente documento." +
                        '\n' +
                        "● Que he comprendido de mis derechos como titular de mis datos personales y /o los de mi representado/a (en los casos que corresponda), conforme los parámetros que establece la Ley Orgánica de Protección de Datos Personales, los mismos que me hacen parte del presente documento." +
                        '\n' +
                        "● Que entiendo la finalidad del tratamiento de mis datos personales y/o los de mi representado/a." +
                        '\n' +
                        "● Que he comprendido la base legal que sustenta el tratamiento de mis datos personales." +
                        '\n' +
                        "● Que manifiesto mi voluntad libre, específica, informada e inequívoca de entregar información y autorizo el tratamiento de mis datos personales y/o los de mi representado/a (en los casos que corresponda), así como de la información que he brindado." +
                        '\n' +
                        "● Que tengo pleno conocimiento de que mis datos personales y/o los de mi representado (en los casos que corresponda) podrán ser transferidos a las instituciones que forman parte de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil y demás instituciones que otorguen prestaciones a la población objetivo." +
                        '\n',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
                RichText(
                    text: TextSpan(
                        text: "CONSIENTO",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                Text(
                    "● Que la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil realice el tratamiento de mis datos personales y/o los de mis representado/a (en los casos en los que corresponda) con el propósito de cumplir con la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil." +
                        '\n' +
                        "● Que la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil realice la transferencia de mis datos personales y/o los de mis representado/a (en los casos en los que corresponda) a las instituciones que forman parte de la Estrategia Nacional Ecuador Crece sin Desnutrición Infantil, que brinden prestaciones a la población objetivo, así como a Presidencia de la República a fin de que se generen acciones en beneficio de la población objetivo, las cuales estarán autorizadas a realizar el tratamiento respectivo, observando lo establecido en la normativa vigente." +
                        '\n' +
                        "● Que el personal de la Secretaría Técnica Ecuador Crece sin Desnutrición Infantil y/o el de las instituciones públicas a las cuales he consentido que le sea transferidos mis datos personales y/o los de mi representado/a (en los casos que corresponda), me contacten en el futuro en caso de que se estime oportuno añadir nuevos datos a los recogidos o realizar aclaraciones de manera oportuna." +
                        '\n' +
                        "● Que la información que proporciono sea utilizada para fines estadísticos, siempre que los datos sean anonimizados, seudoanonimizados y/o debidamente disociados.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ],
            )),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop("s"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: Text("Aceptar")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop("n"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text("Cancelar"))
            ],
          );
        });
  }

  Future<String> _handleUpateDialog(String question) async {
    final prefs = await SharedPreferences.getInstance();
    representantes = prefs.getString("representante")!;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
              children: [
                RichText(
                    text: TextSpan(
                        text: "",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                beneficiario == "1"
                    ? Text(
                        "Buenos/as (días/tardes) " +
                            state.data["nombrecompleto"] +
                            " , usted es beneficiario del Bono Infancia con Futuro. Yo soy " +
                            state.userInfo.info.fullName +
                            ", funcionario del Ministerio de Inclusión Económica y Social, quisiera hacerle unas preguntas sobre el Bono Infancia Futuro con el objetivo de mejorar el programa. Esta encuesta tomará no más de 10 minutos. ¿Acepta ser parte de esta encuesta?.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        ))
                    : Text(
                        "Buenos/as (días/tardes) " +
                            representantes! +
                            " , usted es beneficiario del Bono Infancia con Futuro. Yo soy " +
                            state.userInfo.info.fullName +
                            ", funcionario del Ministerio de Inclusión Económica y Social, quisiera hacerle unas preguntas sobre el Bono Infancia Futuro con el objetivo de mejorar el programa. Esta encuesta tomará no más de 10 minutos. ¿Acepta ser parte de esta encuesta?.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        )),
              ],
            )),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("s");
                    //state.addData('showContinuar', true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: Text("Sí")),
              TextButton(
                  onPressed: () => _handleDialog(question),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text("No"))
            ],
          );
        });
  }

  Future<String> _handleContactDialog(String question) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
              children: [
                RichText(
                    text: TextSpan(
                        text: "",
                        style: TextStyle(fontSize: 20, color: Colors.blue))),
                beneficiario == "1"
                    ? Text(
                        "Buenos/as (días/tardes) soy " +
                            state.userInfo.info.fullName +
                            ", funcionario del Ministerio de Inclusión Económica y Social, quisiera hacerle unas preguntas sobre el Bono Infancia Futuro. ¿Estoy hablando con " +
                            state.data["nombrecompleto"] +
                            "?",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        ))
                    : Text(
                        "Buenos/as (días/tardes) soy " +
                            state.userInfo.info.fullName +
                            ", funcionario del Ministerio de Inclusión Económica y Social, quisiera hacerle unas preguntas sobre el Bono Infancia Futuro. ¿Estoy hablando con " +
                            representantes! +
                            "?",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        )),
              ],
            )),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("s");
                    //state.addData('showContinuar', true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: Text("Aceptar")),
            ],
          );
        });
  }

  Future<ModelFormHeader> getFormHeader() async {
    var formHeaders = await sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module06Constants.moduleId],
    );
    return ModelFormHeader.db(formHeaders[0]);
  }

  Future updateFormHeader(ModelFormHeader formHeader) async {
    sqliteDB.update(
      'FormHeader',
      formHeader.toDb(),
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module06Constants.moduleId],
    );
  }
}
