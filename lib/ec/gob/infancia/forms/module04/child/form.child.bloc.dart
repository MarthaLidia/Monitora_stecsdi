part of ec.gob.infancia.ecuadorsincero.forms.module04.child;

class FormChildBloc extends BaseBloc<FormChildBlocState> {
  late int? formId;
  late ModelFormHeader formHeader;
  int code = 0;

  FormChildBloc({
    required context,
    this.formId,
  }) : super(context: context, creator: () => FormChildBlocState());

  @override
  onLoad() async {
    state.loading = true;
    var username = (await prefs).getString('username');

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
      params: ['hs_01', Module04Constants.moduleId],
      action: (questionId) {
        /*if (questionId == 'h_06' || questionId == 'h_07') {
          formHeader.address =
              '${state.formAnswers['h_06']?.other} ${state.formAnswers['h_07']?.other}';
          sqliteDB.update(
            'FormHeader',
            formHeader.toDb(),
            where: 'fh_id = ? AND fh_module = ?',
            whereArgs: [formHeader.id, Module04Constants.moduleId],
          );
        }*/
        /*if (questionId == 'h_15' &&
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
        }*/
      },
    );

    if (formId == null) {
      formId = id;
      _handleNewForm();
    } else {
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

    formHeader = ModelFormHeader(
      id: formId!,
      module: Module04Constants.moduleId,
      moduleName: Module04Constants.moduleName,
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
      code: DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      version: state.versionCode,
    );

    sqliteDB
        .insert(
      'FormHeader',
      formHeader.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )
        .then((value) => state.loading = false);

    sqliteDB.insert(
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

    _setAutomaticValues();
  }

  _handleEditForm() {
    print("FormHeader");
    print([formId, Module04Constants.moduleId]);
    sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module04Constants.moduleId],
    ).then((dbData) async {
      formHeader = ModelFormHeader.db(dbData[0]);

      var answersDb = await sqliteDB.query(
        'FormAnswer',
        where:
        'fa_header = ? AND fa_questionParent = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formHeader.id, 'hs_01', code, Module04Constants.moduleId],
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

      _setAutomaticValues();
    });
  }

  _setAutomaticValues() {
    for (var questionId in ['h_01', 'h_02', 'h_03', 'h_04']) {
      var answer = state.questions
          .firstWhere((question) => question.id == questionId)
          .answers[0];
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
      sqliteDB.insert(
        'FormAnswer',
        ModelFormAnswer(
          id: -1,
          header: formHeader.id,
          question: questionId,
          questionParent: 'hs_01',
          module: Module04Constants.moduleId,
          answer: answerId,
          code: code,
          other: value,
          complete: true,
        ).toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  handleShowMapLocation() async {
    UtilsHttp.checkConnectivity().then((_) {
      _loadLocation();
      if (state.isOnline) {
        utilShowMapLocation(
          context,
          formHeader.latitude,
          formHeader.longitude,
          markedId: '${formHeader.id}',
          onUpdatePosition: _manualUpdateLocation,
        );
      }
    });
  }

  List<Widget> get buildReadonlyInfo => [
    buildLabelValueInfo(
        localizations.fieldLatitudeLabel, formHeader.latitude),
    buildLabelValueInfo(
        localizations.fieldLongitudeLabel, formHeader.longitude),
    buildLabelValueInfo(
        localizations.fieldReverseAddressLabel, formHeader.reverseAddress),
    buildLabelValueInfo(localizations.fieldDateLabel,
        DateFormat('dd-MM-yyyy').format(formHeader.datetime)),
    buildLabelValueInfo(localizations.fieldTimeLabel,
        DateFormat('hh:mm aa').format(formHeader.datetime)),
    (formHeader.code ?? '').isNotEmpty
        ? buildLabelValueInfo(localizations.fieldFormCode, formHeader.code)
        : Container(),
    Container(
      margin: const EdgeInsets.only(top: 5, bottom: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: UtilsColorPalette.secondary,
          ),
        ),
      ),
    ),
  ];

  Widget buildLabelValueInfo(String label, dynamic value) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText2,
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ': '),
          TextSpan(text: '$value'),
        ],
      ),
    ),
  );

  List<Widget> get buildFormData => [
    ...FormUtils.buildForm(
      state,
      questions:
      state.questions.where((question) => question.visible).toList(),
      handleChange: _handleQuestionChange,
    ),
    (formHeader.code ?? '').isNotEmpty
        ? buildLabelValueInfo(localizations.fieldFormCode, formHeader.code)
        : Container(),
  ];

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
                text: localizations.formEmptyHouse,
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
                if (formHeader.tryNumber == 3 || doesntAllowTries) {
                  Navigator.of(context).pop();
                  sqliteDB.update(
                    'FormHeader',
                    {
                      'fh_complete': 1,
                      'fh_tryNumber':
                      formHeader.tryNumber + (doesntAllowTries ? 3 : 1),
                    },
                    where: 'fh_id = ? AND fh_module = ?',
                    whereArgs: [formId, Module04Constants.moduleId],
                  );
                  /*Navigator.of(context).pushReplacementNamed(
                    FormPeopleWidget.routeName,
                    arguments: {
                      'id': formId,
                    },
                  );*/
                } else {
                  sqliteDB.update(
                    'FormHeader',
                    {
                      'fh_tryNumber': formHeader.tryNumber + 1,
                    },
                    where: 'fh_id = ? AND fh_module = ?',
                    whereArgs: [formId, Module04Constants.moduleId],
                  );
                  state.removeFormAnswer(question);
                  sqliteDB.delete(
                    'FormAnswer',
                    where:
                    'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
                    whereArgs: [
                      formId,
                      question,
                      code,
                      Module04Constants.moduleId
                    ],
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    HomeWidget.routeName,
                        (route) => false,
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
    var isValid = _validateForm();

    if (isValid) {
      state.setFormAnswer(
        'h_01',
        ModelFormAnswer(
          id: -1,
          header: formId!,
          question: 'h_01',
          questionParent: 'hs_01',
          module: Module04Constants.moduleId,
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
          module: Module04Constants.moduleId,
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
          module: Module04Constants.moduleId,
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
          module: Module04Constants.moduleId,
          answer: state.questions
              .firstWhere((question) => question.id == 'h_04')
              .answers[0]
              .id,
          other: DateFormat('hh:mm aa').format(formHeader.datetime),
          complete: true,
        ),
      );

      /*Navigator.of(context).pushReplacementNamed(
        FormHomeWidget.routeName,
        arguments: {
          'id': formId,
        },
      );*/
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
        case 'h_16_1':
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
                r"^[a-zA-Z0-9.]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                .hasMatch(value);
            if (!isValid) {
              state.setFormErrors(
                  question.id, localizations.fieldFormError_H17);
            }
          }
        }
      }
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
      var placemarks = await geocoding.placemarkFromCoordinates(
        location['latitude']!,
        location['longitude']!,
        localeIdentifier: 'es_EC',
      );
      var reverseAddress =
          '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].postalCode}';

      formHeader.latitude = location['latitude'] ?? -1;
      formHeader.longitude = location['longitude'] ?? -1;
      formHeader.datetime = DateTime.now();
      formHeader.reverseAddress = reverseAddress;

      await sqliteDB.update(
        'FormHeader',
        formHeader.toDb(),
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formHeader.id, Module04Constants.moduleId],
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
      whereArgs: [formHeader.id, Module04Constants.moduleId],
    );
  }
}
