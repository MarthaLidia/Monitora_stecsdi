/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module02.woman;

class FormWomanBloc extends BaseBloc<FormWomanBlocState> {
  final int formId;
  final int code;

  FormWomanBloc({
    required context,
    required this.formId,
    required this.code,
  }) : super(context: context, creator: () => FormWomanBlocState());

  @override
  onLoad() async {
    state.loading = true;
    var username = (await prefs).getString('username');

    FormUtils.setUserFromDb(state, username);
    FormUtils.setQuestions(
      state: state,
      formId: formId,
      where: 'q_parent in (?, ?) AND q_module = ?',
      params: ['ms_01', 'ms_02', Module02Constants.moduleId],
      code: code,
      action: (questionId) {},
    );

    _handleLoadForm();
  }

  _handleLoadForm() {
    state.loading = true;
    sqliteDB.query(
      'FormAnswer',
      where:
          'fa_header = ? AND fa_code = ? AND fa_questionParent in (?, ?) AND fa_module = ?',
      whereArgs: [formId, code, 'ms_01', 'ms_02', Module02Constants.moduleId],
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

  Widget get buildTabInfo => CustomRawScrollbar(
        controller: state.listViewController,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              localizations.formWomanTitle,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
          ...FormUtils.buildForm(
            state,
            questions: state.questions.where((item) => item.visible).toList(),
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
    if (formAnswer.question == 'm_01' && formAnswer.other != '2') {
      questionsToClean.addAll(['m_02', 'm_03', 'm_04', 'm_05']);
    } else if (formAnswer.question == 'm_03' && formAnswer.other != '2') {
      questionsToClean.addAll(['m_04', 'm_05']);
    } else if (formAnswer.question == 'm_04' && formAnswer.other != '8') {
      questionsToClean.addAll(['m_05']);
    } else if (formAnswer.question == 'm_06') {
      questionsToClean.addAll([
        'm_07',
        'm_08',
        'm_09',
        'm_10',
        'm_11',
        'm_12',
      ]);
    } else if (formAnswer.question == 'm_09' && formAnswer.other != '4') {
      questionsToClean.addAll(['m_10']);
    } else if (formAnswer.question == 'm_11' && formAnswer.other != '8') {
      questionsToClean.addAll(['m_12']);
    }

    FormUtils.removeAnswer(state, questionsToClean, formId, code);
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
      if (question.id == 'ms_02_a' ||
          question.id == 'ms_02_b' ||
          question.id == 'ms_02_c') {
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
          if (!otherValues.contains(item['value'])) {
            isEnabled = false;
            break;
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
    var m02 = state.formAnswers['m_02']?.other ?? '';
    if (m02.isNotEmpty) {
      try {
        int.parse(state.formAnswers['m_02']!.other!);
      } catch (_) {
        state.setFormErrors('m_02',
            '${localizations.fieldFormError_NUMBER_INVALID}${localizations.fieldFormError_NUMBER_INT}');
      }
    }

    for (var question in ['m_05', 'm_07', 'm_10', 'm_12']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }
  }
}
