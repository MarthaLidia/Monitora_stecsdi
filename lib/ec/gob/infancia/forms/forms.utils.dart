/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-27
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms;

/// Clase utilitarios para la gestión de los formularios.
class FormUtils {
  /// Setea el estado según el usuario.
  static void setUserFromDb(dynamic state, String? username) async {
    var userDb = await sqliteDB.query(
      'User',
      where: 'u_username = ?',
      whereArgs: [username],
    );
    var user = ModelUser.db(userDb[0]);
    state.addData('userInfo', user);
    state.addData('formAnswers', <String, ModelFormAnswer>{});
    state.addData('listViewController', ScrollController());
    state.addData('listView01Controller', ScrollController());
    state.addData('listView02Controller', ScrollController());
    state.addData('listView03Controller', ScrollController());
    state.addData('listView04Controller', ScrollController());
    state.addData('showContinuar', false);
  }

  /// Configura las preguntas.
  static void setQuestions({
    required dynamic state,
    required int formId,
    int code = 0,
    String where = 'q_parent = ? AND q_module = ?',
    required List<dynamic> params,
    required void Function(String) action,
    bool hideFamilyBoss = false,
  }) async {
    print("Where");
    print(where);
    print(params);
    var questionsDb = await sqliteDB.query(
      'Question',
      where: where,
      whereArgs: params,
    );
    print(questionsDb);
    var questions =
        questionsDb.map((question) => ModelQuestion.db(question)).toList();
    print("Qustion");
    print(questions);
    if (hideFamilyBoss) {
      for (var question in questions) {
        if (question.id == 'p_09') {
          question.answers =
              question.answers.where((answer) => answer.order != 1).toList();
          break;
        }
      }
    }
    state.addData('questions', questions);
    state.addData('questionsTextController', <String, TextEditingController>{});
    state.addData('formErrors', <String, String?>{});
    for (var question in questions) {
      switch (question.type) {
        case 'QT_TYPE_TXT_1':
        case 'QT_TYPE_TXT_2':
        case 'QT_TYPE_TXT_3':
        case 'QT_TYPE_TXT_4':
        case 'QT_TYPE_TXT_5':
        case 'QT_TYPE_TXT_6':
          var controller = TextEditingController();
          controller.addListener(() {
            String temp="";
            if (!(state.formAnswers[question.id]?.complete ?? false)) {
              var value=controller.text;
              if(state.data["ajuste_hemog"]!=null){
                switch(question.id){
                  case"m_28_3":
                  case"n_05_10_3":
                    if(state.data["ajuste_hemog"]>=0){
                      var aux=double.parse(value)-state.data["ajuste_hemog"];
                      temp=value;
                      value=aux.toString();
                    }
                    break;
                }
              }
              saveFormAnswer(
                id: state.formAnswers[question.id]?.id ?? -1,
                state: state,
                formId: formId,
                questionId: question.id,
                parent: question.parent,
                module: question.module,
                answerId: question.answers[0].id,
                code: code,
                value: value,
                action: action,
                temp: temp,
              );
            }
          });
          state.setQuestionsTextController(question.id, controller);
          break;
        case 'QT_TYPE_DATE':
          var controller = TextEditingController();
          state.setQuestionsTextController(question.id, controller);
          break;
      }
    }
  }

  /// Configura las respuestas de los formularios.
  static ModelFormAnswer saveFormAnswer({
    required int id,
    required dynamic state,
    required int formId,
    required String questionId,
    required String module,
    required String parent,
    required int answerId,
    int code = 0,
    required dynamic value,
    void Function(String)? action,
    temp=""
  }) {
    switch(questionId){
      case 'h_07':
      case 'h_15':
      case 'h_16_1':
      case'm_28_1':
      case'm_28_2':
      case'm_28_3':
      case'm_28_5':
      case'm_28_6':
      case'n_05_10_1':
      case'n_05_10_2':
      case'n_05_10_3':
      case'n_05_10_5':
      case'n_05_10_6':
        break;
      default:

        if ('$value'.isEmpty || value == null) {
          state.setFormErrors(questionId, 'REQUIRED_DEFAULT_MESSAGE');
        } else if (state.formErrors[questionId] != 'REQUIRED_DEFAULT_MESSAGE' ||
            '$value'.isNotEmpty) {
          state.setFormErrors(questionId, null);
        }
    }


    var updateMessage = state.formAnswers[questionId]?.updateMessage ?? '';
    var formAnswer = ModelFormAnswer(
      id: id,
      header: formId,
      question: questionId,
      questionParent: parent,
      module: module,
      answer: answerId,
      code: code,
      other: '$value',
      complete: false,
      updateMessage: updateMessage,
      temp: temp
    );

    sqliteDB.insert(
      'FormAnswer',
      formAnswer.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state.setFormAnswer(questionId, formAnswer);

    if (action != null) {
      action(questionId);
    }
    return formAnswer;
  }

  /// Construcción del bloque del formulario - pregunta.
  static List<Widget> buildForm(
    dynamic state, {
    required List<ModelQuestion> questions,
    bool Function(ModelQuestion)? enable,
    required Function(String, String, String, int, dynamic, int) handleChange,
    Function(String)? handleTabBtnNroDoc}) {
    var shown47=true;
    return [
      for (var question in questions)
        StatefulBuilder(
          builder: (context, setState) {
            var isEnabled = true;
            if (enable != null) {
              isEnabled = enable(question);
            } else {
              isEnabled = true;
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
            }
            TextEditingController? tc16;
            TextEditingController? tc161;

            for (var question in questions){
              if(question.id=='h_16'){
                tc16=state.questionsTextController[question.id];
              }
              if(question.id=='h_16_1'){
                tc161=state.questionsTextController[question.id];
                print(tc161);
              }
            }
            /*if(tc16!=null&&tc161!=null){
              if(tc16.text.isEmpty||tc16.text.isEmpty){
                shown47=true;
              }else if(tc16.text.isNotEmpty&&tc16.text.isNotEmpty){
                shown47=false;
              }
            }
            if(question.id=="n_47"){
              print("n_47");
              print(shown47);
              isEnabled=shown47;
            }*/

            var alreadySaved = state.formHeader > 0;
            var isReadonly = state.formAnswers[question.id]?.complete ?? false;
            return Column(
              children: [
                if (!alreadySaved || _verifyUpdateCondition(question, state))

                  FormQuestionWidget(
                    context: context,
                    id: state.formAnswers[question.id]?.id ?? -1,
                    question: question,
                    onChange: handleChange,
                    isEnabled: isEnabled,
                    selectedValue: state.formAnswers[question.id]?.other ?? '',
                    textEditController:
                        state.questionsTextController[question.id],
                    errorMessage: state.formErrors[question.id],
                    alreadySaved: alreadySaved &&
                        (state.formAnswers[question.id]?.id ?? -1) > 0,
                    readonly: isReadonly,
                    updateMessage:
                    state.formAnswers[question.id]?.updateMessage ?? '',
                    onTabBtnNroDoc:handleTabBtnNroDoc,
                      hasFirma: state.data["firma_base64"]??[""],
                      hasAudio: state.data["audio_ci"] ?? false,
                    ajusteHemog:state.data["ajuste_hemog"]==null?null:state.data["ajuste_hemog"].toDouble(), altura:state.data["altura"]
                  ),
              ],
            );
          },
        ),
    ];
  }

  /// Manualmente gestiona la acción de scroll.
  static void manualListViewScroll(ScrollController? listViewController) {
    var duration = 250;
    Future.delayed(Duration(milliseconds: duration)).then((_) {
      if (listViewController != null) {
        listViewController.animateTo(
          listViewController.position.maxScrollExtent,
          duration: Duration(milliseconds: duration * 2),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Algoritmo de validación de la cédula con el digito verificador. Algoritmo
  /// base 10.
  static bool validateDocument(
    dynamic state,
    String document,
    String question,
    String docMessage,
  ) {
    if (document.length == 10) {
      var total = 0;
      for (var i = 0; i < 9; i++) {
        var digit = int.parse(document[i]);
        var value = digit * (i % 2 == 0 ? 2 : 1);
        total += value;
        if (value >= 10) {
          total -= 9;
        }
      }
      var upper = (int.parse('${total / 10}'[0]) + 1) * 10;
      var lastDigit = document[9] == '0' ? '10' : document[9];
      var valid = '${upper - total}' == lastDigit;
      if (!valid) {
        state.setFormErrors(question, docMessage);
      } else {
        state.setFormErrors(question, null);
        return true;
      }
    } else {
      state.setFormErrors(question, docMessage);
    }
    return false;
  }

  /// Elimina las respuestas de forma local.
  static void removeAnswer(
    dynamic state,
    List<dynamic> questions,
    int formId,
    int code,
  ) {
    for (var question in questions) {
      state.removeFormAnswer(question);
      state.setFormErrors(question, null);
      if (state.questionsTextController.containsKey(question)) {
        state.questionsTextController[question]!.text = '';
      }
      sqliteDB.delete(
        'FormAnswer',
        where: 'fa_header = ? AND fa_question = ? AND fa_code = ?',
        whereArgs: [formId, question, code],
      );
    }
  }

  /// Ejecuta el submit final del formulario.
  static void submitForm(
    BuildContext context,
    dynamic state,
    int formId,
    AppLocalizations localizations, {
    Function()? onCompleteOffline,
    Function()? onCompleteOnline,
    required Function() onError,
    required String module,
  }) {
    print("FormsUtilsXXX");
    print(module);
    sqliteDB.query(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [formId, module],
    ).then((headerDb) async {

      print(headerDb);
      if (!state.isOnline) {
        UtilsToast.showWarning(localizations.fieldFormError_WAITING);
        if (onCompleteOffline != null) {
          onCompleteOffline();
        }
        return;
      } else {
        state.addData('saving', true);
        state.addData('formId', -1);
        state.addData('formCode', -1);

        showDialog(
          context: context,
          barrierDismissible: !state.data['saving'],
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              if (state.data['saving']) {
                var headerReq = ModelFormHeader.db(headerDb.first);
                log(headerReq.audioCi);
                sqliteDB.query(
                  'FormAnswer',
                  where: 'fa_header = ?',
                  whereArgs: [formId],
                ).then((answersDb) {
                  var answers = answersDb
                      .map((item) => ModelFormAnswer.db(item))
                      .toList();
                  headerReq.answers = answers;
                  headerReq.version = state.versionCode;

                  UtilsHttp.post<int, ModelFormHeader>(
                    url: 'v1/registry/form',
                    body: headerReq,
                  ).then((res) async {
                    print("RES6");
                    print(res);
                    await sqliteDB.delete(
                      'FormAnswer',
                      where: 'fa_header = ?',
                      whereArgs: [formId],
                    );
                    await sqliteDB.delete(
                      'FormHeader',
                      where: 'fh_id = ?',
                      whereArgs: [formId],
                    );
                    await sqliteDB.delete(
                      'FormPersonInfo',
                      where: 'fpi_header = ?',
                      whereArgs: [formId],
                    );
                    UtilsToast.showSuccess(
                        '${localizations.formSuccessMessage01} $res ${localizations.formSuccessMessage02}');
                    setState(() {
                      state.addData('formId', res);
                      state.addData('saving', false);
                      state.addData('formCode', headerReq.code);
                    });
                  }).catchError((res) {
                    Navigator.of(context).pop(false);
                  }).catchError((error) {
                    if (kDebugMode) {
                      print('[ERROR] Form Utils: $error');
                    }
                  });
                });
              }

              return AlertDialog(
                title: Column(
                  children: [
                    state.data['saving']
                        ? SizedBox(
                            height: 125,
                            width: 125,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              child: const CircularProgressIndicator.adaptive(),
                            ),
                          )
                        : Container(),
                    state.data['saving']
                        ? Container()
                        : const Icon(
                            Icons.check_circle_outline,
                            size: 85,
                            color: Colors.green,
                          ),
                    state.data['saving']
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              bottom: 20,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  TextSpan(
                                    text: localizations.formSuccessMessage01,
                                  ),
                                  TextSpan(
                                    text: '${state.data['formId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: localizations.formSuccessMessage02,
                                  ),
                                  TextSpan(
                                    text: '${state.data['formCode']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: localizations.formSuccessMessage03,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    state.data['saving']
                        ? Container()
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                UtilsColorPalette.secondary,
                              ),
                            ),
                            child: Text(localizations.fieldContinueButton),
                          ),
                  ],
                ),
              );
            },
          ),
        ).then((res) {
          if (res == null || res) {
            if (onCompleteOnline != null) {
              onCompleteOnline();
            }
          } else if (res != null && !res) {
            onError();
          }
        });
      }
    });
  }

  static bool _verifyUpdateCondition(
    ModelQuestion question,
    dynamic state,
  ) {
    var condition = true;
    var subCondition = false;
    var subQuestions = [];
    switch (question.id) {
      case 'ns_01':
      case 'ns_02':
      case 'ns_03':
      case 'ns_04':
        var questions = state.formAnswers.entries
            .where((item) =>
                item.value.questionParent == question.id &&
                !item.value.complete)
            .toList();
        condition = questions.length > 0;
        break;
      case 'h_40':
        subQuestions = [
          'h_40_1',
          'h_40_2',
          'h_40_3',
          'h_40_4_1',
          'h_40_4_2',
          'h_40_4_3',
          'h_40_4_4',
          'h_40_5_1',
          'h_40_5_2',
          'h_40_6_1',
        ];
        break;
      case 'h_40_4':
        subQuestions = ['h_40_4_1', 'h_40_4_2', 'h_40_4_3', 'h_40_4_4'];
        break;
      case 'h_40_5':
        subQuestions = ['h_40_5_1', 'h_40_5_2'];
        break;
      case 'h_40_6':
        subQuestions = ['h_40_6_1'];
        break;
      case 'h_48':
        var prevQuestion = state.formAnswers.entries
            .where((item) => item.value.question == 'h_47')
            .toList();
        if (prevQuestion.isNotEmpty && prevQuestion[0]?.value?.other == '1') {
          subCondition = true;
        }
        subQuestions = [
          'h_48a',
          'h_48b',
          'h_48c',
          'h_48d',
          'h_48e',
          'h_48f',
          'h_48g',
        ];
        break;
      case 'ms_02_a':
        subQuestions = [
          'm_06',
          'm_07',
          'm_08',
          'm_09',
          'm_10',
          'm_11',
          'm_12',
          'm_13',
        ];
        break;
      case 'ms_02_b':
        subQuestions = ['m_14', 'm_15'];
        break;
      case 'ms_02_c':
        subQuestions = ['m_16', 'm_17'];
        break;
      case 'ns_02_a':
        subQuestions = [
          'n_06',
          'n_07',
          'n_08',
          'n_09',
          'n_10',
          'n_11',
          'n_12',
          'n_13',
        ];
        break;
      case 'ns_02_b':
        subQuestions = [
          'n_14',
          'n_15',
          'n_16',
          'n_17',
          'n_18',
          'n_19',
          'n_20',
        ];
        break;
      case 'ns_04_a':
        subQuestions = ['n_35', 'n_36', 'n_37', 'n_38', 'n_39', 'n_40'];
        break;
      case 'ns_04_b':
        subQuestions = ['n_41', 'n_42', 'n_43', 'n_44', 'n_45', 'n_46'];
        break;
    }
    if (subQuestions.isNotEmpty) {
      var questions = state.formAnswers.entries
          .where((item) =>
              subQuestions.contains(item.value.question) &&
              !item.value.complete)
          .toList();
      condition = questions.length > 0;
    }
    return condition || subCondition;
  }
}
