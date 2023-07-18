/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module05.woman;

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
      where: 'q_parent in (?, ?) AND q_module = ?',
      params: ['ms_01', 'ms_02', Module05Constants.moduleId],
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
      whereArgs: [formId, code, 'ms_01', 'ms_02', Module05Constants.moduleId],
    ).then((answersDb) {
      answersDb.map((item) => ModelFormAnswer.db(item)).toList().forEach(
        (item) {
          state.setFormAnswer(item.question, item);

          if (state.questionsTextController[item.question] != null) {
            switch(item.question){
              case"m_28_3":
              state.questionsTextController[item.question]!.text =
              '${item.temp}';
                break;
              default:
                state.questionsTextController[item.question]!.text =
                '${item.other}';
                break;
            }

          }
        },
      );
      //var question=state.questions.where((element) => element.id=='h_02_1').first;
      print("Question001");
      print(state.questions);
      //print(question);
     /*try{
       print("Question001");
       print(question);
       FormUtils.saveFormAnswer(
           state: state,
           formId: formId,
           questionId: question.id,
           parent: question.parent,
           module: question.module,
           answerId: question.answers[0].id,
           code: code,
           value: altura,
           id: state.formAnswers[question.id]?.id ?? -1
       );
     }catch(err){

     }*/
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
    int id
  ) async {
    if (question == 'm_28_4' || question=='m_28_5' || question=='m_28_6') {
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
      id: id
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
    var auxq=state.questions.where((element) => element.visible).toList();
    for (var question in auxq) {
      switch(question.id){
        case'm_12_1':
        case'm_20':
        case'm_22':
        case'm_27':
        case'm_28':
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

          continue;
      }
      if (question.id == 'ms_02_a' ||
          question.id == 'ms_02_b' ||
          question.id == 'ms_02_c') {
        state.setFormErrors(question.id, null);
        continue;
      }

      if (!state.formAnswers.containsKey(question.id)) {
        print("error 1 ${question.id}");
        state.setFormErrors(question.id, localizations.fieldIsRequiredMessage);
      } else if (state.formAnswers[question.id]!.other!.isEmpty) {
        print("error 2 ${question.id}");
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
            print("error 3 ${question.id}");
            state.setFormErrors(
                question.id, localizations.fieldIsRequiredMessage);
          } else if (state.formAnswers[question.id]!.other!.isEmpty) {
            print("error 4 ${question.id}");
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

    /*for (var question in ['m_05', 'm_07', 'm_10', 'm_12']) {
      var value = state.questionsTextController[question]!.text;
      if (value.isNotEmpty && value.length < 3) {
        state.setFormErrors(question, localizations.fieldFormError_OTHER);
      }
    }*/
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
   // String base64img = "xy";//base64Encode(imagebytes);
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
