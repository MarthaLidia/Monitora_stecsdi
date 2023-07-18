/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.people;

class FormPeopleBloc extends BaseBloc<FormPeopleBlocState> {
  final int formId;
  bool isInit = false;
  late ModelFormHeader formHeader;
  late dynamic rsConditions;
  late int totalPeople = 0;
  late String celular;

  FormPeopleBloc({
    required context,
    required this.formId,
  }) : super(context: context, creator: () => FormPeopleBlocState());

  @override
  onLoad() async {
    final prefs = await SharedPreferences.getInstance();
    state.addData("firma_base64", [""]);
    state.loading = true;
    var username = (await prefs).getString('username');
    celular=prefs.getString("celular01")!;
    _textEConPhone.text=celular;

    var formHeaders = await sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, Module06Constants.moduleId],
    );
    formHeader = ModelFormHeader.db(formHeaders[0]);
    isInit = true;
    state.addData('showControl', false);
    state.addData('allHasRs', false);
    _loadRsInfo();

    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: formId,
      params: ['r', Module06Constants.moduleId],
      action: (questionId) {
        if (questionId == 'r_05') {
          formHeader.comments = '${state.formAnswers['r_05']?.other}';
          sqliteDB.update(
            'FormHeader',
            formHeader.toDb(),
            where: 'fh_id = ? AND fh_module = ?',
            whereArgs: [formId, Module06Constants.moduleId],
          );
        }
      },
    );

    _handleLoadForm();
  }

  _handleLoadForm() {
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_questionParent = ? AND fa_code = ? AND fa_module = ?',
      whereArgs: [formId, 'r', 0, Module06Constants.moduleId],
    ).then((answersDb) async {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
          if (state.questionsTextController[item.question] != null) {
            state.questionsTextController[item.question]!.text =
                '${item.other}';
          }
        },
      );

      sqliteDB.query(
        'FormAnswer',
        where: 'fa_header = ? AND fa_question = ? AND fa_module = ?',
        whereArgs: [formId, 'h_36', Module06Constants.moduleId],
      ).then((answersDb) {
        if (answersDb.isEmpty) {
          return;
        }
        totalPeople =
            int.parse(ModelFormAnswer.db(answersDb.first).other ?? '0');
      });

      sqliteDB.query(
        'FormAnswer',
        where: 'fa_header = ? AND fa_question IN (?, ?, ?) AND fa_module = ?',
        whereArgs: [formId, 'h_10', 'h_11', 'h_12', Module06Constants.moduleId],
      ).then((answersDb) {
        var allAnswers = answersDb
            .map((item) => '${item['fa_question']}:${item['fa_other']}')
            .join('|');
        var questions = state.questions;
        for (var question in questions) {
          if (question.id != 'r_02') {
            continue;
          } else {
            var answers = <ModelAnswerCategory>[];
            for (var answer in question.answers) {
              if (answer.order == 3 && allAnswers.contains('h_11:2')) {
                answers.add(answer);
              } else if (answer.order == 4 && allAnswers.contains('h_10:2')) {
                answers.add(answer);
              } else if (answer.order == 5 && allAnswers.contains('h_12:2')) {
                answers.add(answer);
              } else if (answer.order == 1 || answer.order == 2) {
                answers.add(answer);
              }
            }
            question.answers = answers;
            break;
          }
        }
        state.addData('questions', questions);
      });
    });

    _loadPeopleInfo();
  }

  _loadPeopleInfo() {
    state.loading = true;
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
      whereArgs: [formId, 'h_36', 0, Module06Constants.moduleId],
    ).then((answersDb) async {
      if (answersDb.isEmpty) {
        return;
      }

      var answer = ModelFormAnswer.db(answersDb.first);
      var peopleQty = int.parse('${answer.other}');
      state.addData('peopleQty', peopleQty);

      var peopleDb = await sqliteDB.query(
        'FormPersonInfo',
        where: 'fpi_header = ?',
        whereArgs: [formId],
      );
      var maxCode =
          peopleDb.isEmpty ? 0 : int.parse('${peopleDb.last['fpi_code'] ?? 0}');

      if (peopleQty > peopleDb.length) {
        var people = [...peopleDb];

        for (var counter = 0;
            counter < peopleQty - peopleDb.length;
            counter++) {
          dynamic personInfo = {
            'fpi_header': formId,
            'fpi_code': ++maxCode,
            'fpi_ready': 0,
          };
          people.add(personInfo);
          sqliteDB.insert(
            'FormPersonInfo',
            personInfo,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        state.addData('peopleInfo', people);
      } else {
        totalPeople = peopleDb.length;
        await sqliteDB.update(
          'FormAnswer',
          {'fa_other': '$totalPeople'},
          where:
              'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
          whereArgs: [formId, 'h_36', 0, Module06Constants.moduleId],
        );
        state.addData('peopleInfo', peopleDb);
      }

      state.loading = false;
    });
  }

  Widget get buildTabInfo => CustomRawScrollbar(
        controller: state.listViewController,
        children: [
          Container(
            //padding: const EdgeInsets.all(20),
            /*child: Text(
              "Información personal población objetivo.",
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),*/
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: UtilsColorPalette.secondary, width: 1),
              ),
            ),
          ),
          for (var person in state.peopleInfo)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: UtilsColorPalette.secondary, width: 1),
                ),
              ),
              child: ListTile(
                leading: person['fpi_ready'] == 1
                    ? const Icon(
                        Icons.check_circle_outline_rounded,
                        color: UtilsColorPalette.tertiary,
                      )
                    : const Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                      ),
                horizontalTitleGap: 0,
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2,
                    children: [
                      TextSpan(
                        text: '${person['fpi_code']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '. '),
                      TextSpan(text: person['fpi_lastName'] ?? 'Incompleto'),
                      TextSpan(
                        text: person['fpi_name'] != null
                            ? ' ${person['fpi_name']}'
                            : '',
                      ),
                      TextSpan(
                        text: person['fpi_document'] != null
                            ? ' - ${person['fpi_document']}'
                            : '',
                      ),
                    ],
                  ),
                ),
                trailing: isInit && !formHeader.complete && totalPeople > 1
                    ? GestureDetector(
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onTap: () {
                          _handleRemovePerson(person['fpi_code']);
                        },
                      )
                    : null,
                onTap: () {
                  if (isInit && !formHeader.complete) {
                    _goToPersonForm(person['fpi_code']);
                  }
                },
              ),
            ),
          /*isInit && !formHeader.complete && totalPeople < 30
              ? GestureDetector(
                  onTap: _handleAddPerson,
                  child: const Icon(
                    Icons.add,
                    color: UtilsColorPalette.tertiary,
                    size: 75,
                  ),
                )
              : Container(),*/
          isInit && !formHeader.complete && totalPeople >= 30
              ? Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(localizations.fieldFormError_H36_LIST),
                )
              : Container(),
          isInit && !formHeader.complete
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: UtilsColorPalette.secondary, width: 1),
                    ),
                  ),
                )
              : Container(),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizations.formSummaryTitle,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          ...FormUtils.buildForm(
            state,
            questions: state.questions.where((item) => item.visible).toList(),
            enable: (ModelQuestion question) {
              if (question.id == 'r_02') {
                return (state.data['showControl'] ?? false);
              }

              if (question.id == 'r_06') {
                return _verifyRsQuestion();
              }

              var isEnabled = true;
              if (question.enabledBy.isNotEmpty) {
                isEnabled = false;
                for (var item in question.enabledByValue) {
                  var otherValues =
                      state.formAnswers[item['key']]?.other?.split('|') ?? [];
                  if (otherValues.contains(item['value'])) {
                    isEnabled = true;
                    break;
                  }
                }
              }
              return isEnabled;
            },
            handleChange: _handleQuestionChange,
          ),
          Container(
            height: 20,
          ),
        ],
      );

  _goToPersonForm(int code) {
    Navigator.of(context).pushNamed(
      FormPersonWidget.routeName,
      arguments: {'id': formId, 'code': code},
    ).then((_) {
      _loadPeopleInfo();
      _loadRsInfo();
    });
  }

  _handleQuestionChange(
    String question,
    String parent,
    String module,
    int answer,
    dynamic value,
    int id,
  ){
    FormUtils.saveFormAnswer(
      state: state,
      formId: formId,
      questionId: question,
      parent: parent,
      module: module,
      answerId: answer,
      value: value,
      id: id,
    );
  }

  handleSubmit() async {
    var isValid = _validateForm();
    if (isValid) {
      await sqliteDB.update(
        'FormHeader',
        {
          'fh_complete': 1,
        },
        where: 'fh_id = ? AND fh_module = ?',
        whereArgs: [formId, Module06Constants.moduleId],
      );
      UtilsHttp.checkConnectivity().then((_) {
        FormUtils.submitForm(context, state, formId, localizations,
            onCompleteOffline: () {
              OpenDialog();
          /*Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );*/
        }, onCompleteOnline: () {
              OpenDialog();
          /*Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );*/
        }, onError: () {
          UtilsToast.showWarning(localizations.fieldFormError_WAITING_ERROR);
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeWidget.routeName,
            (route) => false,
          );
        }, module: Module06Constants.moduleId);
      });
    } else {
      UtilsToast.showWarning(localizations.fieldPeopleRequired);
    }
  }

  bool _validateForm() {
    var auxq1=state.questions.where((el)=>el.visible).toList();
    print(auxq1);
    for (var question in auxq1 ) {
      switch (question.id) {
        case 'r_05':
          continue;
      }
      if (question.id == 'r_01') {
        state.setFormErrors(question.id, null);
        continue;
      } else if (question.id == 'r_06' && !formHeader.rsRequest) {
        state.setFormErrors(question.id, null);
        continue;
      }

      if (!state.formAnswers.containsKey(question.id)) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else if (state.formAnswers[question.id]!.other!.isEmpty) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      }
    }

    _validateSpecificFields();

    var errors = state.formErrors.values.where((item) => item != null);
    var notReady = state.peopleInfo.where((info) => info['fpi_ready'] == 0);

    if (errors.length == 1 && notReady.isEmpty) {
      state.addData('showControl', true);
    }

    return errors.join('').isEmpty && notReady.isEmpty;
  }

  _handleRemovePerson(int code) async {
    if (totalPeople > 1) {
      await sqliteDB.delete(
        'FormPersonInfo',
        where: 'fpi_header = ? AND fpi_code = ?',
        whereArgs: [formId, code],
      );

      await sqliteDB.delete(
        'FormAnswer',
        where: 'fa_header = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formId, code, Module06Constants.moduleId],
      );

      await sqliteDB.update(
        'FormAnswer',
        {'fa_other': '${--totalPeople}'},
        where:
            'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formId, 'h_36', 0, Module06Constants.moduleId],
      );

      _loadPeopleInfo();
    }
  }

  _handleAddPerson() async {
    if (totalPeople < 30) {
      await sqliteDB.update(
        'FormAnswer',
        {'fa_other': '${++totalPeople}'},
        where:
            'fa_header = ? AND fa_question = ? AND fa_code = ? AND fa_module = ?',
        whereArgs: [formId, 'h_36', 0, Module06Constants.moduleId],
      );
      _loadPeopleInfo();
    }
  }

  _validateSpecificFields() {
    for (var question in ['r_03', 'r_04']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }
  }

  _loadRsInfo() {
    sqliteDB.query(
      'FormRsInfo',
      where: 'frsi_header = ?',
      whereArgs: [formId],
    ).then((res) {
      if (res.isNotEmpty) {
        rsConditions = res.first;
      } else {
        rsConditions = null;
      }
    });

    var whereArgs = state.peopleInfo
        .map((info) => (info['fpi_document'] ?? '').length == 10
            ? info['fpi_document']
            : '-1')
        .toList()
        .cast<String>();
    var whereInfo = whereArgs.map((_) => '?').join(',');
    if (whereArgs.isNotEmpty) {
      sqliteDB.query(
        'RsData',
        where: 'document in ($whereInfo)',
        whereArgs: [whereArgs],
      ).then((rsData) {
        if (rsData.isNotEmpty && totalPeople == rsData.length) {
          state.addData('allHasRs', true);
        } else {
          state.addData('allHasRs', false);
        }
      });
    }
  }

  _verifyRsQuestion() {
    if (state.data['allHasRs'] || rsConditions == null) {
      return false;
    }

    if (rsConditions['frsi_salary'] == 1 || rsConditions['frsi_food'] == 1) {
      return true;
    }

    var hasDeficit = true;
    if (rsConditions['frsi_deficit01'] == 'A') {
      if (rsConditions['frsi_deficit02'] == 'A') {
        hasDeficit = rsConditions['frsi_deficit03'] == 'C';
      } else if (rsConditions['frsi_deficit02'] == 'B') {
        hasDeficit = rsConditions['frsi_deficit03'] != 'A';
      }
    }

    if (hasDeficit &&
        rsConditions['frsi_water'] == 1 &&
        rsConditions['frsi_hygiene'] == 1 &&
        rsConditions['frsi_light'] == 1) {
      return true;
    }
    return false;
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

  _handleTakeFirma(XFile picture,String questionId) async {
    print("Question Id");
    print(questionId);
    ModelFormHeader formHeader = await getFormHeader();
    Uint8List imagebytes = await picture.readAsBytes();
    String base64img = base64Encode(imagebytes);
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
  void _sendWhatsAppMessage(String celulars) async {
    if(!BigInt.parse(celulars).isValidInt){
      UtilsToast.showDanger("Revise que el número esté bien ingresado.");
      return;
    }
    if(celulars.length>10||celulars.length<10){
      UtilsToast.showDanger("Revise que el número esté bien ingresado.");
      return;
    }
    //var whatsappUrl = "whatsapp://send?phone=${_countryCodeController.text + _phoneController.text}" +"&text=${Uri.encodeComponent(_messageController.text)}";

    celulars=celulars.toString().substring(1);
    print(celulars);


    String phoneNumber = "593"+celulars; // Reemplaza con el número de teléfono deseado
    //String phoneNumber = "0939613851";
    String message = "El Bono Infancia Futuro es un programa integral para la prevención de la desnutrición crónica infantil. Como Beneficiaria, tiene una transferencia mensual de USD 50 y pagos adicionales si va a los controles de embarazo, a los controles de niño sano en los centros del Ministerio de Salud Pública e inscribe el nacimiento de su hijo/a en el Registro Civil, además de acceder a los servicios de consejería familiar por parte del Ministerio de Inclusión Económica y Social. Por favor, contáctese con el 1800-002-002 para que pueda acceder a este programa."; // Reemplaza con el mensaje deseado
    String url = "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}";
    final Uri uri=Uri.parse(url);
    //UtilsToast.showSuccess(url);
    print("url");
    print(url);

    /*if (await canLaunch(url)) {
      await launch(url);
    }*/
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      UtilsToast.showSuccess("no se pudo abrir");
      throw 'No se pudo abrir $url';
    }
    print("url2");
    print(url);

  }
  TextEditingController _textEConPhone = TextEditingController();
  Future OpenDialog([dynamic callback])=>showDialog(
    context:context,
    builder: (context) =>AlertDialog(
      title:Text('Este es tu número de teléfono? caso contrario puedes cambiarlo. '),
      content: TextField(
        controller: _textEConPhone,
        autofocus: true,
        decoration: InputDecoration(hintText: "número"),
      ),
      actions: [
        TextButton(onPressed: (){

          _sendWhatsAppMessage(_textEConPhone.value.text);
          Future.delayed(Duration.zero, () {
            callback( Navigator.of(context).pushNamedAndRemoveUntil(
              HomeWidget.routeName,
                  (route) => false,
            ));
          });


          //Navigator.of(context).pop();
        }, child: Text('Enviar'))
      ],
    ),
  );
}
