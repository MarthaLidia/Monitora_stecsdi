/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.person;

class FormPersonBloc extends BaseBloc<FormPersonBlocState> {
  final int formId;
  final int code;
  late Map<String, dynamic> personInfo;

  FormPersonBloc({
    required context,
    required this.formId,
    required this.code,
  }) : super(context: context, creator: () => FormPersonBlocState());

  @override
  onLoad() async {
    state.loading = true;
    var username = (await prefs).getString('username');

    state.addData('formHeader', formId);
    var personDb = await sqliteDB.query(
      'FormPersonInfo',
      where: 'fpi_header = ? and fpi_code = ?',
      whereArgs: [formId, code],
    );
    personInfo = personDb[0];

    state.addData('saveIcon', true);
    state.addData('goToPage', 0);
    state.addData('gender', 1);
    state.addData('age', 5);

    var personFamily = await sqliteDB.query(
      'FormAnswer',
      where: 'fa_header = ? AND fa_question = ? AND fa_answer = ?',
      whereArgs: [formId, 'p_09', 250],
    );

    var hideFamilyBoss =
        personFamily.isEmpty || personFamily[0]['fa_code'] == code;

    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: formId,
      params: ['ps_01', Module01Constants.moduleId],
      code: code,
      action: (questionId) async {
        Map<String, dynamic> info = {};
        if (questionId == 'p_04') {
          state.setFormErrors('p_03', null);
          info['fpi_document'] = state.formAnswers[questionId]?.other ?? '';

          if (info['fpi_document'].length == 10) {
            var peopleDb = await sqliteDB.query(
              'FormPersonInfo',
              where: 'fpi_header = ? AND fpi_code <> ? AND fpi_document = ?',
              whereArgs: [formId, code, info['fpi_document']],
            );
            if (peopleDb.isNotEmpty) {
              state.setFormErrors(
                  'p_04', localizations.fieldFormError_PEOPLE_THERE);
              sqliteDB.update(
                'FormPersonInfo',
                {
                  'fpi_document': '',
                },
                where: 'fpi_header = ? and fpi_code = ?',
                whereArgs: [formId, code],
              );
              FormUtils.removeAnswer(
                  state, ['p_05', 'p_06', 'p_07', 'p_08'], formId, code);
              return;
            }
          }

          if (info['fpi_document'].length == 10) {
            _handleCheckAlreadySaved(info['fpi_document']).then((res) {
              state.addData('verified', true);
              state.addData('alreadyExists', res['exists']);
            }).catchError((error) {
              state.addData('verified', false);
              UtilsHttp.handleError(error, location: 'Form Person');
            }).whenComplete(() {
              _handleDocument(info, questionId);
              if (state.verified && state.alreadyExists) {
                state.setFormErrors(
                    'p_03', localizations.fieldFormError_H03_ALREADY_IN_DB);
              } else {
                state.setFormErrors('p_03', null);
              }
            });
          }
        }

        if (questionId == 'p_05') {
          sqliteDB.update(
            'FormPersonInfo',
            {
              'fpi_lastName': state.formAnswers[questionId]?.other ?? '',
            },
            where: 'fpi_header = ? and fpi_code = ?',
            whereArgs: [formId, code],
          );
        }

        if (questionId == 'p_06') {
          sqliteDB.update(
            'FormPersonInfo',
            {
              'fpi_name': state.formAnswers[questionId]?.other ?? '',
            },
            where: 'fpi_header = ? and fpi_code = ?',
            whereArgs: [formId, code],
          );
        }
      },
      hideFamilyBoss: !hideFamilyBoss,
    );

    _handleLoadForm();
  }

  _handleLoadForm() {
    state.loading = true;
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_code = ? AND fa_questionParent = ? AND fa_module = ?',
      whereArgs: [formId, code, 'ps_01', Module01Constants.moduleId],
    ).then((answersDb) {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
          if (item.question == 'p_07') {
            state.addData('gender', item.other!);
          } else if (state.questionsTextController[item.question] != null) {
            if (item.question == 'p_08' &&
                item.other != null &&
                item.other!.isNotEmpty) {
              var date = DateTime.parse(item.other!);
              state.questionsTextController['p_08']!.text =
                  DateFormat('dd-MM-yyyy').format(date);
            } else {
              state.questionsTextController[item.question]!.text =
                  '${item.other}';
            }
          }

          if (item.question == 'p_08') {
            if (state.formAnswers.containsKey('p_08')) {
              var date = DateTime.parse(state.formAnswers['p_08']!.other!);
              var age = UtilsDatetime.calculateAge(date);
              state.addData('age', age);
              _handleConditionFromDB();
            }
          }

          if (formId > 0) {
            state.addData('saveIcon', true);
            state.addData('goToPage', 0);
          } else {
            if (item.question == 'p_16' && item.other == '1') {
              state.addData('saveIcon', false);
              state.addData('goToPage', 1);
            } else if (item.question == 'p_16' && item.other == '2') {
              state.addData('saveIcon', false);
              state.addData('goToPage', 2);
            }
          }
        },
      );

      state.loading = false;

      sqliteDB.query(
        'FormAnswer',
        where: 'fa_header = ? AND fa_question IN (?) AND fa_module = ?',
        whereArgs: [formId, 'h_37', Module01Constants.moduleId],
      ).then((answersDb) {
        answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
          (item) {
            state.setFormAnswer(item.question, item);
          },
        );

        for (var question in state.questions) {
          if (question.id == 'p_01') {
            var answerId = question.answers[0].id;
            var coreQty = int.parse(state.formAnswers['h_37']!.other!);
            if (coreQty > 1) {
              question.answers = [
                for (var i = 0; i < coreQty; i++)
                  ModelAnswerCategory(
                      id: answerId, order: i + 1, label: '${i + 1}'),
              ];
            } else {
              question.answers = [];
              FormUtils.saveFormAnswer(
                state: state,
                formId: formId,
                questionId: 'p_01',
                parent: 'ps_01',
                module: Module01Constants.moduleId,
                answerId: answerId,
                code: code,
                value: '1',
                id: -1,
              );
            }
          } else if (question.id == 'p_02') {
            var answerId = question.answers[0].id;
            FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'p_02',
              parent: 'ps_01',
              module: Module01Constants.moduleId,
              answerId: answerId,
              code: code,
              value: '$code',
              id: -1,
            );
          }
        }
      });

      for (var question in state.questions) {
        if (question.id != 'p_16') {
          continue;
        }

        question.answers =
            question.answers.where((item) => item.order != 2).toList();
      }
    });

    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_code = ? AND fa_question = ? AND fa_module = ?',
      whereArgs: [formId, code, 'm_01', Module01Constants.moduleId],
    ).then((answersDb) {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);
        },
      );
    });
  }

  Widget get buildTabInfo => CustomRawScrollbar(
        controller: state.listViewController,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizations.formPeopleTitle,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          ...FormUtils.buildForm(
            state,
            questions: state.questions.where((item) => item.visible).toList(),
            enable: (ModelQuestion question) {
              if (question.id == 'p_01') {
                if (question.answers.isEmpty || question.answers.length == 1) {
                  return false;
                }
                return true;
              }
              if (question.id == 'p_16') {
                if ('${state.data['gender']}' == '1') {
                  return false;
                } else if (state.data['age'] >= 10) {
                  return true;
                }
                return false;
              }

              var isEnabled = true;
              if (question.enabledBy.isNotEmpty) {
                isEnabled = false;
                for (var item in question.enabledByValue) {
                  var otherValues =
                      state.formAnswers[item['key']]?.other?.split('|') ?? [];
                  if (item['key'] == 'p_08') {
                    if (!state.formAnswers.containsKey('p_08')) {
                      isEnabled = false;
                    } else {
                      var date =
                          DateTime.parse(state.formAnswers['p_08']!.other!);
                      var age = UtilsDatetime.calculateAge(date);
                      if (age >= 5) {
                        isEnabled = true;
                        break;
                      }
                    }
                  } else {
                    if (otherValues.contains(item['value'])) {
                      isEnabled = true;
                      break;
                    }
                  }
                }
              }
              return isEnabled;
            },
            handleChange: _handleQuestionChange,
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

    var questionsToClean = [];
    switch (formAnswer.question) {
      case 'p_03':
        if (formAnswer.other != '1' &&
            formAnswer.other != '2' &&
            formAnswer.other != '7' &&
            formAnswer.other != '8') {
          state.setFormErrors('p_03', null);
          state.addData('verified', false);
          questionsToClean.add('p_04');
        }
        break;
      case 'p_07':
        state.addData('gender', int.parse(state.formAnswers['p_07']!.other!));
        _handleConditionFromDB(forceChange: true);

        sqliteDB.update(
          'FormPersonInfo',
          {
            'fpi_gender': int.parse(state.formAnswers['p_07']!.other!),
          },
          where: 'fpi_header = ? and fpi_code = ?',
          whereArgs: [formId, code],
        );

        break;
      case 'p_08':
        if (formAnswer.other != null && formAnswer.other!.isNotEmpty) {
          var date = DateTime.parse(formAnswer.other!);
          state.questionsTextController[formAnswer.question]!.text =
              DateFormat('dd-MM-yyyy').format(date);

          var age = UtilsDatetime.calculateAge(date);
          state.addData('age', age);
        } else if (formAnswer.other == null || formAnswer.other!.isEmpty) {
          questionsToClean.addAll(['p_11', 'p_12', 'p_13']);
        }
        _handleConditionFromDB(forceChange: true);
        break;
      case 'p_09':
        if (formAnswer.other != '11') {
          questionsToClean.add('p_09_a');
        }
        break;
      case 'p_13':
        if (formAnswer.other == '1') {
          questionsToClean.add('p_14');
        }
        break;
      case 'p_16':
        if ((state.formAnswers['p_07']!.other ?? -1) == '2' &&
            (state.formAnswers['p_16']!.other ?? -1) == '1') {
          var id = state.formAnswers['m_01']?.id ?? -1;
          sqliteDB.query('Question',
              where: 'q_id = ? AND q_module = ?',
              whereArgs: ['m_01', Module01Constants.moduleId]).then((res) {
            var question = ModelQuestion.db(res[0]);
            var answerFromQuestion = question.answers
                .where((item) => '${item.order}' == '$value')
                .toList();
            var answer = FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'm_01',
              parent: 'ms_01',
              module: module,
              answerId: answerFromQuestion[0].id,
              code: code,
              value: value,
              id: id,
            );
            state.setFormAnswer('m_01', answer);
          });
        }
        break;
    }

    FormUtils.removeAnswer(state, questionsToClean, formId, code);

    if (formId > 0 ||
        formAnswer.question == 'p_16' && formAnswer.other == '3') {
      state.addData('saveIcon', true);
      state.addData('goToPage', 0);
    } else if (formAnswer.question == 'p_16' && formAnswer.other == '1') {
      state.addData('saveIcon', false);
      state.addData('goToPage', 1);
    } else if (formAnswer.question == 'p_16' && formAnswer.other == '2') {
      state.addData('saveIcon', false);
      state.addData('goToPage', 2);
    }
  }

  handleSubmit() {
    var isValid = _validateForm();
    if (isValid) {
      if (state.data['goToPage'] == 0) {
        _goBackAndUpdate();
        if (state.formHeader < 0) {
          sqliteDB.delete(
            'FormAnswer',
            where:
                'fa_header = ? AND fa_code = ? AND fa_questionParent in (?, ?, ?, ?, ?, ?, ?) AND fa_module = ?',
            whereArgs: [
              formId,
              code,
              'ms_01',
              'ms_02',
              'n',
              'ns_01',
              'ns_02',
              'ns_03',
              'ns_04',
              Module01Constants.moduleId,
            ],
          );
        }
      } else {
        String route;

        if (state.data['goToPage'] == 1) {
          route = FormWomanWidget.routeName;
        } else {
          route = FormChildWidget.routeName;
        }

        sqliteDB.update(
          'FormPersonInfo',
          {'fpi_ready': 0},
          where: 'fpi_header = ? and fpi_code = ?',
          whereArgs: [formId, code],
        );

        Navigator.of(context).pushNamed(
          route,
          arguments: {'id': formId, 'code': code},
        ).then((saved) {
          if (saved != null) {
            _goBackAndUpdate();
          }
        });
      }
    } else {
      UtilsToast.showWarning(localizations.fieldAllRequired);
    }
  }

  _goBackAndUpdate() {
    sqliteDB.update(
      'FormPersonInfo',
      {'fpi_ready': 1},
      where: 'fpi_header = ? and fpi_code = ?',
      whereArgs: [formId, code],
    );
    Navigator.of(context).pop();
  }

  bool _validateForm() {
    for (var question in state.questions) {
      if (question.id == 'p_02') {
        state.setFormErrors(question.id, null);
        continue;
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

          if (question.id == 'p_04' || question.id == 'p_14') {
            isEnabled = false;
            if (otherValues.contains(item['value'])) {
              isEnabled = true;
              break;
            }
          } else if (item['key'] == 'p_08') {
            if (!state.formAnswers.containsKey('p_08')) {
              isEnabled = false;
            } else {
              var date = DateTime.parse(state.formAnswers['p_08']!.other!);
              var age = UtilsDatetime.calculateAge(date);
              if (age < 5) {
                isEnabled = false;
              }
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
    if (state.verified && state.alreadyExists) {
      state.setFormErrors(
          'p_03', localizations.fieldFormError_H03_ALREADY_IN_DB);
    } else {
      state.setFormErrors('p_03', null);
    }

    var doc = state.formAnswers['p_04']?.other ?? '';
    if (doc.isNotEmpty) {
      if (state.formErrors['p_04'] !=
          localizations.fieldFormError_PEOPLE_THERE) {
        if (state.formAnswers['p_03']?.other == '1') {
          FormUtils.validateDocument(
              state, doc, 'p_04', localizations.fieldFormError_DOCUMENT);
        } else {
          state.setFormErrors('p_04', null);
        }
      }
    }

    for (var question in ['p_05', 'p_06']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      } else {
        var valid = RegExp(r"^[a-zA-Z áéíóúñÁÉÍÓÚÑ]+$").hasMatch(value);
        if (!valid) {
          state.setFormErrors(question, localizations.fieldFormError_NAME);
        }
      }
    }
  }

  _handleConditionFromDB({bool forceChange = false}) {
    if (state.data['gender'] == 2 && state.data['age'] >= 10) {
      return;
    }

    if (!forceChange) {
      return;
    }

    if (formId > 0 || state.data['age'] > 2) {
      state.addData('saveIcon', true);
      state.addData('goToPage', 0);
      if (formId < 0) {
        _adjustConditionQuestion('3');
      }
    } else {
      state.addData('saveIcon', false);
      state.addData('goToPage', 2);
      _adjustConditionQuestion('2');
    }
  }

  _adjustConditionQuestion(String option) {
    var p16 = state.formAnswers['p_16'];
    if (p16 != null) {
      p16.other = option;
      state.setFormAnswer('p_16', p16);
    } else {
      var question16 = state.questions.where((item) => item.id == 'p_16').first;
      p16 = ModelFormAnswer(
        id: -1,
        header: formId,
        question: question16.id,
        questionParent: question16.parent,
        module: question16.module,
        answer: question16.answers[1].id,
        code: code,
        other: option,
        complete: false,
      );
      state.setFormAnswer('p_16', p16);
    }

    FormUtils.saveFormAnswer(
      state: state,
      formId: formId,
      questionId: p16.question,
      parent: p16.questionParent,
      module: p16.module,
      answerId: p16.answer,
      code: code,
      value: option,
      id: -1,
    );
  }

  Future<Map<String, dynamic>> _handleCheckAlreadySaved(String document) {
    return UtilsHttp.get<Map<String, dynamic>>(
      url: 'v2/registry/form/checkDocuments',
      queryParams: {
        'document': document,
      },
    );
  }

  _handleDocument(Map<String, dynamic> info, String questionId) {
    if (info['fpi_document'].length == 10 &&
        state.formAnswers['p_03']?.other == '1') {
      var isValidDocument = FormUtils.validateDocument(
        state,
        info['fpi_document'],
        'p_04',
        localizations.fieldFormError_DOCUMENT,
      );

      if (isValidDocument) {
        sqliteDB.query(
          'PeopleData',
          where: 'document = ?',
          whereArgs: [info['fpi_document']],
        ).then((value) async {
          if (value.isNotEmpty) {
            var person = value.first;

            FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'p_05',
              parent: 'ps_01',
              module: Module01Constants.moduleId,
              answerId: state.questions
                  .where((item) => item.id == 'p_05')
                  .toList()[0]
                  .answers[0]
                  .id,
              code: code,
              value: person['lastName'],
              id: -1,
            );
            state.questionsTextController['p_05']!.text =
                '${person['lastName']}';
            info['fpi_lastName'] = person['lastName'];

            FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'p_06',
              parent: 'ps_01',
              module: Module01Constants.moduleId,
              answerId: state.questions
                  .where((item) => item.id == 'p_06')
                  .toList()[0]
                  .answers[0]
                  .id,
              code: code,
              value: person['name'],
              id: -1,
            );
            state.questionsTextController['p_06']!.text = '${person['name']}';
            info['fpi_name'] = person['name'];

            FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'p_07',
              parent: 'ps_01',
              module: Module01Constants.moduleId,
              answerId: state.questions
                  .where((item) => item.id == 'p_07')
                  .toList()[0]
                  .answers[0]
                  .id,
              code: code,
              value: person['gender'],
              id: -1,
            );
            info['fpi_gender'] = person['gender'];
            state.addData('gender', person['gender'] ?? 1);

            FormUtils.saveFormAnswer(
              state: state,
              formId: formId,
              questionId: 'p_08',
              parent: 'ps_01',
              module: Module01Constants.moduleId,
              answerId: state.questions
                  .where((item) => item.id == 'p_08')
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
              state.questionsTextController['p_08']!.text = dateLabel;
              var age = UtilsDatetime.calculateAge(date);
              state.addData('age', age);
            }

            sqliteDB.update(
              'FormPersonInfo',
              info,
              where: 'fpi_header = ? and fpi_code = ?',
              whereArgs: [formId, code],
            );

            _handleConditionFromDB();
          } else {
            sqliteDB.update(
              'FormPersonInfo',
              {
                'fpi_document': state.formAnswers[questionId]?.other ?? '',
              },
              where: 'fpi_header = ? and fpi_code = ?',
              whereArgs: [formId, code],
            );
          }
        });
      }
    } else {
      sqliteDB.update(
        'FormPersonInfo',
        {
          'fpi_document': state.formAnswers[questionId]?.other ?? '',
        },
        where: 'fpi_header = ? and fpi_code = ?',
        whereArgs: [formId, code],
      );
    }
  }
}