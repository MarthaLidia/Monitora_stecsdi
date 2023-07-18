/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.home;

class FormHomeBloc extends BaseBloc<FormHomeBlocState> {
  final int formId;
  late ModelFormHeader formHeader;
  int code = 0;
  late int indentificador;
  late String nombres;
  late String celular;
  late String representante;



  FormHomeBloc({
    required context,
    required this.formId,
  }) : super(context: context, creator: () => FormHomeBlocState());

  @override
  onLoad() async {
    state.loading = true;
    final prefs = await SharedPreferences.getInstance();
    print("IDENTIFICADOR");
    //print(prefs.getInt("identificador"));
    indentificador=prefs.getInt("identificador")!;
    representante=prefs.getString("representante")!;
    celular=prefs.getString("celular01")!;
    _textEConPhone.text=celular;
    var username = (await prefs).getString('username');

    var telef1=(await prefs).getString('telefono1');
    var telef2=(await prefs).getString('telefono2');
    var direc=(await prefs).getString('Direccion');
    var refern=(await prefs).getString('Referencia');

    state.questionsTextController["h_02_1"]?.text=telef1??"";
    state.questionsTextController["h_02_2"]?.text=telef2??"";
    state.questionsTextController["h_02_3"]?.text=direc??"";
    state.questionsTextController["h_02_4"]?.text=refern??"";



    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: formId,
      where: 'q_parent in (?, ?, ?, ?) and q_module = ?',
      params: [
        'hs_02_a',
        'hs_02_b',
        'hs_02_c',
        'hs_02_d',
        Module06Constants.moduleId],
      action: (questionId) {
        if (questionId == 'h_36' || questionId == 'h_39') {
          var h39Other = state.formAnswers['h_39']?.other ?? '0';
          var salary = double.parse(h39Other.isEmpty ? '0' : h39Other);

          var h36Other = state.formAnswers['h_36']?.other ?? '1';
          var people = double.parse(h36Other.isEmpty ? '1' : h36Other);

          var perCapita = salary / people;
          var value = 0;
          if (perCapita > 0 && perCapita <= 84) {
            value = 1;
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_salary': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
      },
    );

    _handleLoadForm();
  }

  _handleLoadForm() {
    state.loading = true;
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_code = ? AND fa_questionParent in (?, ?, ?, ?) AND fa_module = ?',
      whereArgs: [
        formId,
        0,
        'hs_02_a',
        'hs_02_b',
        'hs_02_c',
        'hs_02_d',
        Module06Constants.moduleId,
      ],
    ).then((answersDb) {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
          if (state.questionsTextController[item.question] != null) {
            state.questionsTextController[item.question]!.text =
                '${item.other}';
          }
        },
      );

      state.loading = false;
    });
  }

  Widget buildTabInfo(
    String headline,
    String parent,
    ScrollController listController,
  ) =>
      CustomRawScrollbar(
        controller: listController,
        children: [
          Container(
            //padding: const EdgeInsets.all(20),
            child: Text(
              //headline,
              "Información beneficiarios",
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          ...FormUtils.buildForm(
            state,
            questions: _filtrarQuestions(parent),
            handleChange: _handleQuestionChange,
            handleTabBtnNroDoc: _handleTabBtnNroDoc,
          ),
        ],
      );

  _filtrarQuestions(parent){
    print("IDENTIFICADOR");
    print(indentificador);
    dynamic listafitrada=[];
    dynamic listapreguntas=state.questions.where((item) => item.parent == parent && item.visible)
        .toList();
    if(indentificador=="1"){
      listafitrada=listapreguntas.where((pretunta){
        if(pretunta.id=='h_18_7'){
          return false;
        }
        return true;
      }).toList();
    }else{
      listafitrada=listapreguntas.where((pretunta){
        if(pretunta.id=='h_18_8'){
          return false;
        }
        return true;
      }).toList();
    }
    return listafitrada;
  }
  _handleQuestionChange(
    String question,
    String parent,
    String module,
    int answer,
    dynamic value,
    int id,
  ) {
    var formAnswer = FormUtils.saveFormAnswer(
      state: state,
      formId: formId,
      questionId: question,
      parent: parent,
      module: module,
      answerId: answer,
      value: value,
      id: id,
    );

    String? answerComparator;
    var nextQuestion = <String>[];
    switch (question) {
      case 'h_18':
        answerComparator = '7';
        nextQuestion = ['h_19'];
        break;
      case 'h_18_1':
        if (formAnswer.other == '2') {
          _handleDialog(question);
          return;
        }
        break;
       /*case 'h_18_4':
        if (formAnswer.other == '2') {
          _handleDialog1(question);
          return;
        }
        break;*/
      case 'h_20':
        answerComparator = '7';
        nextQuestion = ['h_21'];
        break;
        case 'h_22':
        case 'h_23':
        if (state.formAnswers.containsKey('h_22') &&
            state.formAnswers.containsKey('h_23')) {
          var value = '';
          var optionSelected = int.parse(state.formAnswers['h_22']!.other!);
          var conditionSelected = state.formAnswers['h_23']!.other;
          if (conditionSelected == '1') {
            if (optionSelected < 5) {
              value = 'A';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '2') {
            if (optionSelected == 1) {
              value = 'A';
            } else if (optionSelected < 5) {
              value = 'B';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '3') {
            if (optionSelected == 1) {
              value = 'B';
            } else {
              value = 'C';
            }
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_deficit01': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_24':
      case 'h_25':
        if (state.formAnswers.containsKey('h_24') &&
            state.formAnswers.containsKey('h_25')) {
          var value = '';
          var optionSelected = int.parse(state.formAnswers['h_24']!.other!);
          var conditionSelected = state.formAnswers['h_25']!.other;
          if (conditionSelected == '1') {
            if (optionSelected < 4) {
              value = 'A';
            } else if (optionSelected < 7) {
              value = 'B';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '2') {
            if (optionSelected < 3) {
              value = 'A';
            } else if (optionSelected < 7) {
              value = 'B';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '3') {
            if (optionSelected < 3) {
              value = 'B';
            } else {
              value = 'C';
            }
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_deficit02': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_26':
      case 'h_27':
        if (state.formAnswers.containsKey('h_26') &&
            state.formAnswers.containsKey('h_27')) {
          var value = '';
          var optionSelected = int.parse(state.formAnswers['h_26']!.other!);
          var conditionSelected = state.formAnswers['h_27']!.other;
          if (conditionSelected == '1') {
            if (optionSelected < 6) {
              value = 'A';
            } else if (optionSelected < 7) {
              value = 'B';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '2') {
            if (optionSelected < 4) {
              value = 'A';
            } else if (optionSelected < 6) {
              value = 'B';
            } else {
              value = 'C';
            }
          } else if (conditionSelected == '3') {
            if (optionSelected < 4) {
              value = 'B';
            } else {
              value = 'C';
            }
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_deficit03': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_29':
        if (state.formAnswers.containsKey('h_29')) {
          var value = 1;
          if (state.formAnswers['h_29']!.other == '1') {
            value = 0;
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_water': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        answerComparator = '8';
        nextQuestion = ['h_30'];
        break;
      case 'h_31':
        answerComparator = '12';
        nextQuestion = ['h_32'];
        break;
      case 'h_35':
        if (state.formAnswers.containsKey('h_35')) {
          var value = 0;
          var optionSelected = int.parse(state.formAnswers['h_35']!.other!);
          if (optionSelected > 1) {
            value = 1;
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_hygiene': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_41':
        if (state.formAnswers.containsKey('h_41')) {
          var value = 1;
          if (state.formAnswers['h_41']!.other == '6') {
            value = 0;
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_food': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_43':
        if (state.formAnswers.containsKey('h_43')) {
          var value = 1;
          if (state.formAnswers['h_43']!.other == '1') {
            value = 0;
          }
          sqliteDB.update(
            'FormRsInfo',
            {
              'frsi_light': value,
            },
            where: 'frsi_header = ?',
            whereArgs: [formId],
          );
        }
        break;
      case 'h_47':
        answerComparator = '1';
        nextQuestion = [
          'h_48a',
          'h_48b',
          'h_48c',
          'h_48d',
          'h_48e',
          'h_48f',
          'h_48g',
        ];
        break;
      case 'h_50':
        answerComparator = '7';
        nextQuestion = ['h_51'];
        break;
      case 'h_56':
        answerComparator = '5';
        nextQuestion = ['h_57'];
        break;
      case 'h_58':
        answerComparator = '4';
        nextQuestion = ['h_59'];
        break;
    }

    if (answerComparator != null && formAnswer.other != answerComparator) {
      state.setFormErrors(question, null);
    }

    FormUtils.removeAnswer(state, nextQuestion, formId, 0);

    switch (question) {
      case 'h_51':
        if (formAnswer.other == '7') {
          FormUtils.manualListViewScroll(state.listView02Controller);
        }
        break;
      case 'h_60':
        if (formAnswer.other == '4') {
          FormUtils.manualListViewScroll(state.listView04Controller);
        }
        break;
    }
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
            callback();
          });


          //Navigator.of(context).pop();
        }, child: Text('Enviar'))
      ],
    ),
  );



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
                text: question == 'h_18_1'
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
                //OpenDialog();
               // Navigator.of(context).pop();
                var doesntAllowTries = [
                  'h_18_1',
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
                //OpenDialog();
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
  _handleDialog1(String question) {
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
                text: question == 'h_18_4'
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
                  'h_18_4',
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
                //OpenDialog();
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
          OpenDialog((){
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeWidget.routeName,
                  (route) => false,
            );
          });

        },
        onCompleteOnline: () {
          OpenDialog((){
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeWidget.routeName,
                  (route) => false,
            );
          });

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

  handleSubmit() {
    var isValid = _validateForm();
    if (isValid) {
      Navigator.of(context).pushReplacementNamed(
        FormPeopleWidget.routeName,
        arguments: {
          'id': formId,
        },
      );
    } else {
      UtilsToast.showWarning(localizations.fieldAllRequired);
    }
  }

  bool _validateForm() {
    var auxq=state.questions.where((el)=>el.visible).toList();
    print(auxq);
    for (var question in auxq ) {
      String? condition;
      var ids = <String>[];
      switch (question.id) {
        case 'h_18':
          condition = '7';
          ids.add('h_19');
          break;
        case 'h_20':
          condition = '7';
          ids.add('h_21');
          break;
        case 'h_29':
          condition = '8';
          ids.add('h_30');
          break;
        case 'h_31':
          condition = '12';
          ids.add('h_32');
          break;
        case 'h_47':
          condition = '1';
          ids.addAll([
            'h_48a',
            'h_48b',
            'h_48c',
            'h_48d',
            'h_48e',
            'h_48f',
            'h_48g',
          ]);
          break;
        case 'h_50':
          condition = '7';
          ids.add('h_51');
          break;
        case 'h_56':
          condition = '5';
          ids.add('h_57');
          break;
        case 'h_58':
          condition = '4';
          ids.add('h_59');
          break;
      }

      if (condition != null) {
        if (!state.formAnswers.containsKey(question.id)) {
          state.setFormErrors(
              question.id, localizations.fieldIsRequiredMessage);
        } else {
          if (state.formAnswers[question.id]!.other!.isEmpty) {
            state.setFormErrors(
                question.id, localizations.fieldIsRequiredMessage);
          } else if (state.formAnswers[question.id]!.other == condition) {
            for (var id in ids) {
              if (!state.formAnswers.containsKey(id)) {
                state.setFormErrors(id, localizations.fieldIsRequiredMessage);
              } else if (state.formAnswers[id]!.other!.isEmpty) {
                state.setFormErrors(id, localizations.fieldIsRequiredMessage);
              }
            }
          } else {
            for (var id in ids) {
              state.setFormErrors(id, null);
            }
          }
        }
      } else if (!state.formAnswers.containsKey(question.id)) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else if (state.formAnswers[question.id]!.other!.isEmpty) {
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else {
        state.setFormErrors(question.id, null);
      }
    }

    for (var question in state.questions) {
      switch (question.id) {
        case 'h_40':
        case 'h_40_4':
        case 'h_40_5':
        case 'h_40_6':
        case 'h_45_OLD':
        case 'h_48':
          state.setFormErrors(question.id, null);
          break;
        case 'h_19':
        case 'h_21':
        case 'h_30':
        case 'h_32':
        case 'h_48a':
        case 'h_48b':
        case 'h_48c':
        case 'h_48d':
        case 'h_48e':
        case 'h_48f':
        case 'h_48g':
        case 'h_51':
        case 'h_57':
        case 'h_59':
          var showError = false;
          print("11111");
          print(question.enabledByValue);
          for (var item in question.enabledByValue) {
            print("item");
            print(item);
            var otherValues =
                state.formAnswers[item['key']]?.other?.split('|') ?? [];
            print(otherValues);
            if (otherValues.contains(item['value'])) {
              showError = true;
              break;
            }
          }
          if (showError &&
              (!state.formAnswers.containsKey(question.id) ||
                  state.formAnswers[question.id]!.other!.isEmpty)) {
            state.setFormErrors(
                question.id, localizations.fieldIsRequiredMessage);
          } else {
            state.setFormErrors(question.id, null);
          }
          break;
      }
    }

    _validateSpecificFields();

    return true;

  }

  _validateSpecificFields() {
    var h28 = state.questionsTextController['h_28']!.text;
    if (h28.isNotEmpty) {
      try {
        var value = int.parse(h28);
        if (value < 0 || value > 25) {
          state.setFormErrors('h_28', localizations.fieldFormError_H28);
        } else {
          state.setFormErrors('h_28', null);
        }
      } catch (_) {
        state.setFormErrors('h_28',
            '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
      }
    }

    for (var question in ['h_21', 'h_30','h_57', 'h_59']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }

    for (var question in ['h_36', 'h_37', 'h_38']) {
      var valueText = state.questionsTextController[question]!.text;
      try {
        var value = int.parse(valueText);
        if (value < 1 || value > 30) {
          state.setFormErrors(question, localizations.fieldFormError_H36_H37);
        } else {
          state.setFormErrors(question, null);
        }
      } catch (_) {
        state.setFormErrors(question,
            '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
      }
    }

    var h36 = state.questionsTextController['h_36']!.text;
    int? value36;
    var h37 = state.questionsTextController['h_37']!.text;
    int? value37;
    var h38 = state.questionsTextController['h_38']!.text;
    int? value38;

    try {
      value36 = int.parse(h36);
    } catch (_) {
      state.setFormErrors('h_36',
          '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
    }

    try {
      value37 = int.parse(h37);
    } catch (_) {
      state.setFormErrors('h_37',
          '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
    }

    try {
      value38 = int.parse(h38);
    } catch (_) {
      state.setFormErrors('h_38',
          '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
    }

    if (value37 != null && value36 != null) {
      if (value37 > value36) {
        state.setFormErrors('h_37', localizations.fieldFormError_H37);
      }
    }

    if (value38 != null && value37 != null) {
      if (value38 > value37) {
        state.setFormErrors('h_38', localizations.fieldFormError_H38);
      }
    }
  }

  _handleTabBtnNroDoc(String cedula){
    print("CEDULA");
    state.loading=true;
    state.questionsTextController["h_06_1"]?.text="";

    state.loading=true;
    getCaptacionPerson(cedula ?? "")
        .then((value){
      state.loading=false;
      if(value!=null){
        if(value.isEmpty){
          UtilsToast.showWarning("No se encontraron datos de la cédula ingresada.");
        }
      }
    })
        .catchError((onError){
      state.loading=false;
      UtilsToast.showDanger("No se pudo obtener los datos solicitados.");
    });
  }

  Future<dynamic> getCaptacionPerson(cedula) async {
    print("CEDULA");
    try{
      var uri =Uri.https(
          "seguimientodev.infancia.gob.ec",
          "/api/beneficiariom/$cedula"
      );
      var response=await http.get(uri);
      print("Uri:");
      print(uri);
      if(response.statusCode==200){
        var body=json.decode(utf8.decoder.convert(response.bodyBytes));
        print("CAPTADOS");
        print(body);
        return body;
      }
      return {};
    }catch(err){
      print(err);
      print("[ERROR] ${err.toString()}");
    }
  }
}
