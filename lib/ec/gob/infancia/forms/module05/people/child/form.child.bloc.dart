/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module05.child;

class FormChildBloc extends BaseBloc<FormChildBlocState> {
  final int formId;
  final int code;

  FormChildBloc({
    required context,
    required this.formId,
    required this.code,
  }) : super(context: context, creator: () => FormChildBlocState());

  @override
  onLoad() async {
    state.addData("firma_base64", [""]);
    var location=await currentLocation;
    var altura=location["altitude"]!;
    var ajusteH=await _ajusteHemoglobina();
    state.data["ajuste_hemog"]=ajusteH;
    state.data["altura"]=altura;
    state.loading = true;
    var username = (await prefs).getString('username');

    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: formId,
      where: 'q_parent in (?, ?, ?, ?, ?) AND q_module = ?',
      params: [
        'n',
        'ns_01',
        'ns_02',
        'ns_03',
        'ns_04',
        Module05Constants.moduleId
      ],
      code: code,
      action: (questionId) {
        if (questionId == 'n_24') {
          _handleCarePerson();
        } else if (questionId == 'n_38') {
          _handleMotherPerson();
        } else if (questionId == 'n_44') {
          _handleFatherPerson();
        }
      },
    );

    var peopleDb = await sqliteDB.query(
      'FormPersonInfo',
      where: 'fpi_header = ? AND fpi_code <> ?',
      whereArgs: [formId, code],
    );

    for (var question in state.questions) {
      if (question.id == 'n_22') {
        var answerId = question.answers[0].id;
        question.answers = peopleDb
            .map((person) => ModelAnswerCategory(
                id: answerId,
                order: int.parse('${person['fpi_code']}'),
                label:
                    '${person['fpi_lastName'] ?? ''} ${person['fpi_name'] ?? ''}'))
            .toList();
      }

      if (question.id == 'n_36') {
        var answerId = question.answers[0].id;
        question.answers = peopleDb
            .where((person) => person['fpi_gender'] == 2)
            .map((person) => ModelAnswerCategory(
                id: answerId,
                order: int.parse('${person['fpi_code']}'),
                label:
                    '${person['fpi_lastName'] ?? ''} ${person['fpi_name'] ?? ''}'))
            .toList();
      }

      if (question.id == 'n_42') {
        var answerId = question.answers[0].id;
        question.answers = peopleDb
            .where((person) => person['fpi_gender'] == 1)
            .map((person) => ModelAnswerCategory(
                id: answerId,
                order: int.parse('${person['fpi_code']}'),
                label:
                    '${person['fpi_lastName'] ?? ''} ${person['fpi_name'] ?? ''}'))
            .toList();
      }
    }

    _handleLoadForm();
  }

  _handleLoadForm() {
    state.loading = true;
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_code = ? AND fa_questionParent in (?, ?, ?, ?, ?) AND fa_module = ?',
      whereArgs: [
        formId,
        code,
        'n',
        'ns_01',
        'ns_02',
        'ns_03',
        'ns_04',
        Module05Constants.moduleId,
      ],
    ).then((answersDb) {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
          if (state.questionsTextController[item.question] != null) {
            if (item.question == 'n_28' &&
                item.other != null &&
                item.other!.isNotEmpty) {
              var date = DateTime.parse(item.other!);
              state.questionsTextController['n_28']!.text =
                  DateFormat('dd-MM-yyyy').format(date);
            } else {
              switch(item.question){
                case"n_05_10_3":
                  state.questionsTextController[item.question]!.text =
                  '${item.temp}';
                  break;
                default:
                  state.questionsTextController[item.question]!.text =
                  '${item.other}';
                  break;
              }
            }
          }
        },
      );
      state.loading = false;
    });
  }

  Widget get buildTabInfo => CustomRawScrollbar(
        controller: state.listViewController,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizations.formChildTitle,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          ...FormUtils.buildForm(
            state,
            questions: state.questions.where((item) => item.visible).toList(),
            handleChange: _handleQuestionChange,
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
          ),
        ],
      );

  _handleQuestionChange(
    String question,
    String parent,
    String module,
    int answer,
    dynamic value,
    int id,
  ) async {
    if (question == 'n_05_10_4' || question=='n_05_10_5' || question=='n_05_10_6') {
      print("camara");
      await availableCameras().then((value) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CameraPage(
                cameras: value,
                onSaveImage: _handleTakeFirma,
                questionId: question,
              ))));
    }
    var formAnswer = FormUtils.saveFormAnswer(
      state: state,
      formId: formId,
      questionId: question,
      parent: parent,
      module: module,
      answerId: answer,
      code: code,
      value: value,
      id: id,
    );

    var questions = [];
    if (formAnswer.question == 'n_02') {
      questions = ['n_03', 'n_04', 'n_05'];
    } else if (formAnswer.question == 'n_06') {
      questions = ['n_07', 'n_08', 'n_09', 'n_10', 'n_11', 'n_12'];
    } else if (formAnswer.question == 'n_18') {
      questions = ['n_19'];
    } else if (formAnswer.question == 'n_06') {
      questions = ['n_07', 'n_08', 'n_09', 'n_10', 'n_11', 'n_12'];
    } else if (formAnswer.question == 'n_21') {
      questions = [
        'n_22',
        'n_23',
        'n_24',
        'n_25',
        'n_26',
        'n_27',
        'n_28',
        'n_29',
        'n_30',
        'n_31',
        'n_32',
        'n_33',
      ];
    } else if (formAnswer.question == 'n_28') {
      if (formAnswer.other != null && formAnswer.other!.isNotEmpty) {
        var date = DateTime.parse(formAnswer.other!);
        state.questionsTextController[formAnswer.question]!.text =
            DateFormat('dd-MM-yyyy').format(date);
      }
    } else if (formAnswer.question == 'n_32') {
      questions = ['n_33'];
    } else if (formAnswer.question == 'n_35') {
      questions = ['n_36', 'n_37', 'n_38', 'n_39', 'n_40'];
      state.setFormErrors('ns_04', null);
    } else if (formAnswer.question == 'n_41') {
      questions = ['n_42', 'n_43', 'n_44', 'n_45', 'n_46'];
      state.setFormErrors('ns_04', null);

      FormUtils.manualListViewScroll(state.listViewController);
    } else {
      return;
    }

    FormUtils.removeAnswer(state, questions, formId, code);
  }

  handleSubmit() {
    var isValid = _validateForm();
    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      UtilsToast.showWarning(localizations.fieldAllRequired);
    }
  }

  bool _validateForm() {
    var auxq=state.questions.where((element) => element.visible).toList();
    for (var question in auxq) {
      switch(question.id){
        case'n_05_1_2':
        case'n_05_10':
        case'n_05_10_1':
        case'n_05_10_2':
        case'n_05_10_3':
        case'n_05_10_5':
        case'n_05_10_6':
          continue;
      }
      switch (question.id) {
        case 'n_05':
        case 'ns_01':
        case 'ns_02':
        case 'ns_02_a':
        case 'ns_02_b':
        case 'ns_03':
        case 'ns_03_a':
        case 'ns_04':
        case 'ns_04_a':
        case 'n_35':
        case 'n_36':
        case 'n_37':
        case 'n_38':
        case 'n_39':
        case 'n_40':
        case 'ns_04_b':
        case 'n_41':
        case 'n_42':
        case 'n_43':
        case 'n_44':
        case 'n_45':
        case 'n_46':
          state.setFormErrors(question.id, null);
          continue;
      }

      if (state.formAnswers['n_21']?.other == '2' &&
          state.formAnswers['n_23']?.other == '1') {
        var doc = state.formAnswers['n_24']?.other ?? '';
        FormUtils.validateDocument(
            state, doc, 'n_24', localizations.fieldFormError_DOCUMENT);
      }

      if (state.formAnswers['n_35']?.other == '2' &&
          state.formAnswers['n_37']?.other == '1') {
        print("RESPUEST");
        print(state.formAnswers['n_35']);
        var doc = state.formAnswers['n_38']?.other ?? '';
        FormUtils.validateDocument(
            state, doc, 'n_38', localizations.fieldFormError_DOCUMENT);
      }

      if (state.formAnswers['n_41']?.other == '2' &&
          state.formAnswers['n_43']?.other == '1') {
        var doc = state.formAnswers['n_44']?.other ?? '';
        FormUtils.validateDocument(
            state, doc, 'n_44', localizations.fieldFormError_DOCUMENT);
      }

      if (!state.formAnswers.containsKey(question.id)) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else if (state.formAnswers[question.id]!.other!.isEmpty) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      }

      if (question.enabledBy.isNotEmpty) {
        var isEnabled = true;
        for (var item in question.enabledByValue) {
          var otherValues =
              state.formAnswers[item['key']]?.other?.split('|') ?? [];
          if (question.id == 'n_03' ||
              question.id == 'n_04' ||
              question.id == 'n_22' ||
              question.id == 'n_30' ||
              question.id == 'n_36' ||
              question.id == 'n_42') {
            isEnabled = false;
            if (otherValues.contains(item['value'])) {
              isEnabled = true;
              break;
            }
          } else {
            if (!otherValues.contains(item['value'])) {
              isEnabled = false;
              break;
            }
          }
        }

        if (isEnabled) {
          if (!state.formAnswers.containsKey(question.id)) {
            state.setFormErrors(
                question.id, localizations.fieldIsRequiredMessage);
          } else if (state.formAnswers[question.id]!.other!.isEmpty) {
            state.setFormErrors(
                question.id, localizations.fieldIsRequiredMessage);
          }
        } else {
          state.setFormErrors(question.id, null);
        }
      }
    }

    _validateSpecificFields();

    return state.formErrors.values
        .where((item) => item != null)
        .join('')
        .isEmpty;
  }

  _validateSpecificFields() {
    var n15 = state.formAnswers['n_15']?.other ?? '';
    if (n15.isNotEmpty) {
      try {
        var value = int.parse(state.formAnswers['n_15']!.other!);
        if (value > 24) {
          state.setFormErrors('n_15', localizations.fieldFormError_M02);
        }
      } catch (_) {
        state.setFormErrors('n_15',
            '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
      }
    }

    for (var question in ['n_07', 'n_10', 'n_12', 'n_19']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }

    var questions = <String>[];
    if (state.formAnswers['n_21']?.other == '2') {
      questions.add('n_25');
      questions.add('n_26');
    }

    if (state.formAnswers['n_35']?.other == '2') {
      questions.add('n_39');
      questions.add('n_40');
    }

    if (state.formAnswers['n_41']?.other == '2') {
      questions.add('n_45');
      questions.add('n_46');
    }

    for (var question in questions) {
      var value = state.questionsTextController[question]!.text;
      if ((question == 'n_39' ||
              question == 'n_40' ||
              question == 'n_45' ||
              question == 'n_46') &&
          value.isEmpty) {
        continue;
      }
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      } else {
        var valid = RegExp(r"^[a-zA-Z áéíóúÁÉÍÓÚ]+$").hasMatch(value);
        if (!valid) {
          state.setFormErrors(question, localizations.fieldFormError_NAME);
        }
      }
    }
  }

  _handleCarePerson() {
    if ((state.formAnswers['n_23']?.other ?? -1) == '1') {
      var doc = state.formAnswers['n_24']?.other ?? '';
      if (doc.length == 10) {
        var isValidDocument = FormUtils.validateDocument(
          state,
          doc,
          'n_24',
          localizations.fieldFormError_DOCUMENT,
        );
        if (isValidDocument) {
          sqliteDB.query(
            'PeopleData',
            where: 'document = ?',
            whereArgs: [doc],
          ).then((value) {
            if (value.isNotEmpty) {
              var person = value.first;
              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_25',
                parent: 'ns_03',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_25')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['lastName'],
                id: -1,
              );
              state.questionsTextController['n_25']!.text =
                  '${person['lastName']}';

              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_26',
                parent: 'ns_03',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_26')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['name'],
                id: -1,
              );
              state.questionsTextController['n_26']!.text = '${person['name']}';

              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_27',
                parent: 'ns_03',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_27')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['gender'],
                id: -1,
              );

              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_28',
                parent: 'ns_03',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_28')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['birthDate'],
                id: -1,
              );
              if (person['birthDate'] != null &&
                  '${person['birthDate']}'.isNotEmpty) {
                var date = DateTime.parse('${person['birthDate']}');
                var dateLabel = DateFormat('dd-MM-yyyy').format(date);
                state.questionsTextController['n_28']!.text = dateLabel;
              }
            }
          });
        }
      }
    }
  }

  _handleMotherPerson() {
    if ((state.formAnswers['n_37']?.other ?? -1) == '1') {
      String doc = state.formAnswers['n_38']?.other ?? '';
      if (doc.length == 10) {
        var isValidDocument = FormUtils.validateDocument(
            state, doc, 'n_38', localizations.fieldFormError_DOCUMENT);
        if (isValidDocument) {
          sqliteDB.query(
            'PeopleData',
            where: 'document = ?',
            whereArgs: [doc],
          ).then((value) {
            if (value.isNotEmpty) {
              var person = value.first;
              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_39',
                parent: 'ps_01',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_39')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['lastName'],
                id: -1,
              );
              state.questionsTextController['n_39']!.text =
                  '${person['lastName']}';

              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_40',
                parent: 'ps_01',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_40')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['name'],
                id: -1,
              );
              state.questionsTextController['n_40']!.text = '${person['name']}';
            }
          });
        }
      }
    }
  }

  _handleFatherPerson() {
    if ((state.formAnswers['n_43']?.other ?? -1) == '1') {
      String doc = state.formAnswers['n_44']?.other ?? '';
      if (doc.length == 10) {
        var isValidDocument = FormUtils.validateDocument(
            state, doc, 'n_44', localizations.fieldFormError_DOCUMENT);
        if (isValidDocument) {
          sqliteDB.query(
            'PeopleData',
            where: 'document = ?',
            whereArgs: [doc],
          ).then((value) {
            if (value.isNotEmpty) {
              var person = value.first;
              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_45',
                parent: 'ps_01',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_45')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['lastName'],
                id: -1,
              );
              state.questionsTextController['n_45']!.text =
                  '${person['lastName']}';

              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'n_46',
                parent: 'ps_01',
                module: Module05Constants.moduleId,
                answerId: state.questions
                    .where((item) => item.id == 'n_46')
                    .toList()[0]
                    .answers[0]
                    .id,
                code: code,
                value: person['name'],
                id: -1,
              );
              state.questionsTextController['n_46']!.text = '${person['name']}';
            }
          });
        }
      }
    }
  }

  _ajusteHemoglobina() async{
    var location=await currentLocation;
    var altura=location["altitude"]!;
    if(altura<1000){
      return 0;
    }else if(altura>=1000 && altura<=1499 ){
      return 0.2;
    }else if(altura>=1500 && altura<=1999 ){
      return 0.5;
    }else if(altura>=2000 && altura<=2499 ){
      return 0.8;
    }else if(altura>=2500 && altura<=2999 ){
      return 1.3;
    }else if(altura>=3000 && altura<=3499 ){
      return 1.9;
    }else if(altura>=3500 && altura<=3999 ){
      return 2.7;
    }else if(altura>=4000 && altura<=4499 ){
      return 3.5;
    }else if(altura>=4500 && altura<=4999){
      return 4.5;
    }
    return 0;
  }
  Future<ModelFormHeader> getFormHeader() async {
    var formHeaders = await sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module05Constants.moduleId],
    );
    print("FormHeader");
    print(formHeaders[0]);
    return ModelFormHeader.db(formHeaders[0]);
  }

  Future updateFormHeader(ModelFormHeader formHeader) async {
    sqliteDB.update(
      'FormHeader',
      formHeader.toDb(),
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module05Constants.moduleId],
    );
  }
  _handleTakeFirma(XFile picture,String questionId) async {
    print("Question Id");
    print(questionId);
    print(formId);
    ModelFormHeader formHeader = await getFormHeader();
    Uint8List imagebytes = await picture.readAsBytes();
    img.Image image = img.decodeImage(imagebytes)!;
    img.Image compressedImage = img.copyResize(image, width: image.width, height: image.height, interpolation: img.Interpolation.linear);
    compressedImage = img.copyResize(compressedImage, width: compressedImage.width, height: compressedImage.height, interpolation: img.Interpolation.linear);
    String base64img = base64.encode(img.encodeJpg(compressedImage, quality: 50));
    //String base64img = base64Encode(imagebytes);
    if(formHeader.firmaBase64.isEmpty){
      formHeader.firmaBase64 = base64img;
    }else{
      formHeader.firmaBase64 = formHeader.firmaBase64+","+base64img;
    }
    await updateFormHeader(formHeader);
    List<String> temp=state.data["firma_base64"];
    if(!temp.contains(questionId)){
      temp.add(questionId);
    }
    state.addData("firma_base64", temp);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
