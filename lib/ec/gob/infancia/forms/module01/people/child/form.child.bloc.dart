/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.child;

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
    state.loading = true;
    var username = (await prefs).getString('username');

    state.addData('formHeader', formId);
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
        Module01Constants.moduleId
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
        Module01Constants.moduleId,
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
              state.questionsTextController[item.question]!.text =
                  '${item.other}';
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
  ) {
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
    if (formAnswer.question == 'n_01') {
      questions = ['n_02', 'n_02_a', 'n_02_b', 'n_05_a', 'n_05_b'];
    } else if (formAnswer.question == 'n_02_a' ||
        formAnswer.question == 'n_02_b') {
      FormUtils.saveFormAnswer(
        state: state,
        formId: formId,
        questionId: 'n_02',
        parent: parent,
        module: module,
        answerId: answer,
        code: code,
        value: value,
        id: id,
      );
      questions = ['n_03', 'n_04', 'n_05_a', 'n_05_b'];
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

    _handleRestrictionException(formAnswer.question);
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
    for (var question in state.questions) {
      switch (question.id) {
        case 'n_02_a':
        case 'n_02_b':
        case 'n_05':
        case 'n_05_a':
        case 'n_05_b':
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

      _handleRestrictionException(question.id);
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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
                module: Module01Constants.moduleId,
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

  _handleRestrictionException(String question) {
    if (question == 'n_17' || question == 'n_20') {
      if (state.formAnswers.containsKey('n_17') &&
          state.formAnswers.containsKey('n_20')) {
        var qty = int.parse(state.formAnswers['n_17']?.other ?? '0');
        if (qty == 6) {
          qty = 5;
        }
        var selectedQty =
            (state.formAnswers['n_20']?.other ?? '').split('|').length - 1;
        if (qty != selectedQty) {
          state.setFormErrors('n_20', localizations.fieldFormError_FOOD_MATCH);
        }
      }
    }
  }
}
