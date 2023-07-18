/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2021-05-17

part of ec.gob.infancia.ecuadorsincero.forms.module01.house;

class FormHouseBloc extends BaseBloc<FormHouseBlocState> {
  late int? formId;
  late ModelFormHeader formHeader;
  int code = 0;
  final ScrollController _autocompleteController = ScrollController();

  FormHouseBloc({
    required context,
    this.formId,
  }) : super(context: context, creator: () => FormHouseBlocState());

  @override
  onLoad() async {
    state.loading = true;
    var username = (await prefs).getString('username');

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
      params: ['hs_01', Module01Constants.moduleId],
      action: (questionId) {
        if (questionId == 'h_06' || questionId == 'h_07') {
          formHeader.address =
              '${state.formAnswers['h_06']?.other} ${state.formAnswers['h_07']?.other}';
          sqliteDB.update(
            'FormHeader',
            formHeader.toDb(),
            where: 'fh_id = ? AND fh_module = ?',
            whereArgs: [formHeader.id, Module01Constants.moduleId],
          );
        }
        if (questionId == 'h_15' &&
            state.questionsTextController['h_15']!.text.isNotEmpty) {
          state.setFormErrors('h_16', null);
          if (state.questionsTextController['h_15']!.text.length != 9) {
            state.setFormErrors('h_15', localizations.fieldFormError_H15);
          }
        } else if (questionId == 'h_16' &&
            state.questionsTextController['h_16']!.text.isNotEmpty) {
          state.setFormErrors('h_15', null);
          if (state.questionsTextController['h_16']!.text.length != 10) {
            state.setFormErrors('h_16', localizations.fieldFormError_H16);
          }
        } else if (questionId == 'h_17') {
          state.setFormErrors('h_17', null);
          if ((state.questionsTextController['h_17']?.text ?? '').isEmpty) {
            FormUtils.removeAnswer(state, ['h_17'], formId!, code);
          }
        }
      },
    );

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
      _handleEditForm();
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
        module: Module01Constants.moduleId,
        moduleName: Module01Constants.moduleName,
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

  _handleEditForm() {
    print("ENTRO AL MODULO 1");
    sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module01Constants.moduleId],
    ).then((dbData) async {
      formHeader = ModelFormHeader.db(dbData[0]);

      var answersDb = await sqliteDB.query(
        'FormAnswer',
        where:
            'fa_header = ? AND fa_questionParent = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formHeader.id, 'hs_01', code, Module01Constants.moduleId],
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
          var found = state.locations
              .where(
                  (item) => item.location == state.formAnswers['h_05']!.other)
              .toList();
          if (found.isNotEmpty) {
            var location = found[0];
            state.addData(
              'locationValue',
              TextEditingValue(text: location.label),
            );
          }
        } else if (formId! < 0) {
          state.addData('locationValue', TextEditingValue.empty);
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
            module: Module01Constants.moduleId,
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
    if (formAnswer.question == 'h_10') {
      questionsToClean = [
        'h_11',
        'h_12',
        'h_13',
        'h_14',
        'h_15',
        'h_16',
        'h_17',
      ];
    } else if (formAnswer.question == 'h_11') {
      questionsToClean = [
        'h_12',
        'h_13',
        'h_14',
        'h_15',
        'h_16',
        'h_17',
      ];
    } else if (formAnswer.question == 'h_12') {
      questionsToClean = [
        'h_13',
        'h_14',
        'h_15',
        'h_16',
        'h_17',
      ];
    } else if (formAnswer.question == 'h_13') {
      questionsToClean = [
        'h_14',
        'h_15',
        'h_16',
        'h_17',
      ];
    } else if (formAnswer.question == 'h_14') {
      questionsToClean = [
        'h_15',
        'h_16',
        'h_17',
      ];
    } else {
      return;
    }

    FormUtils.manualListViewScroll(state.listViewController);
    FormUtils.removeAnswer(state, questionsToClean, formId!, code);

    switch (question) {
      case 'h_10':
      case 'h_11':
      case 'h_12':
      case 'h_13':
      case 'h_14':
        if (formAnswer.other == '2') {
          _handleDialog(question);
          return;
        } else {
          FormUtils.manualListViewScroll(state.listViewController);
          if (question == 'h_14') {
            state.addData('showContinuar', true);
          }
        }
        break;
      case 'h_15':
      case 'h_16':
        state.setFormErrors('h_15', null);
        state.setFormErrors('h_16', null);
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
            module: Module01Constants.moduleId,
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
            module: Module01Constants.moduleId,
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
            module: Module01Constants.moduleId,
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
            module: Module01Constants.moduleId,
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
    for (var question in state.questions) {
      switch (question.id) {
        case 'h_01':
        case 'h_02':
        case 'h_03':
        case 'h_04':
        case 'h_05':
          continue;
        case 'h_17':
          if (!state.formAnswers.containsKey(question.id)) {
            continue;
          }
          break;
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
            if (value.length != 9) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H15);
            }
          }
          if (question.id == 'h_16') {
            containsCellPhone = true;
            if (value.length != 10) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H16);
            }
          }
          if (question.id == 'h_17') {
            var isValid = RegExp(
                    r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                .hasMatch(value);
            if (!isValid) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H17);
            }
          }
        }
      }
    }

    if (!state.formAnswers.containsKey('h_05')) {
      state.setFormErrors('h_05', localizations.fieldFormError_H05);
    }

    for (var question in ['h_06', 'h_07', 'h_08', 'h_09']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }

    if (!containsHomePhone && !containsCellPhone) {
      state.setFormErrors('h_15', localizations.fieldFormError_H15_H16);
      state.setFormErrors('h_16', localizations.fieldFormError_H15_H16);
    }
    if (containsHomePhone &&
        state.formErrors['h_16'] == localizations.fieldIsRequiredMessage) {
      state.setFormErrors('h_16', null);
    }
    if (containsCellPhone &&
        state.formErrors['h_15'] == localizations.fieldIsRequiredMessage) {
      state.setFormErrors('h_15', null);
    }

    return state.formErrors.values
        .where((item) => item != null)
        .join('')
        .isEmpty;
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
        whereArgs: [formHeader.id, Module01Constants.moduleId],
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
      whereArgs: [formHeader.id, Module01Constants.moduleId],
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
      module: Module01Constants.moduleId,
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
      whereArgs: [formHeader.id, Module01Constants.moduleId],
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
        whereArgs: [formHeader.id, Module01Constants.moduleId],
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
          Module01Constants.moduleId,
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
          whereArgs: [formId, Module01Constants.moduleId],
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
        whereArgs: [formId, Module01Constants.moduleId],
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
        whereArgs: [formId, Module01Constants.moduleId],
      );
      state.removeFormAnswer(question);
      sqliteDB.delete(
        'FormAnswer',
        where:
            'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formId, question, code, Module01Constants.moduleId],
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
        module: Module01Constants.moduleId,
      );
    });
  }

}
