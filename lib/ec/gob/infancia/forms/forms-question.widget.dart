/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms;

class FormQuestionWidget extends BaseStateless {
  final int id;
  final TextEditingController? textEditController;
  final ModelQuestion question;
  final void Function(String, String, String, int, dynamic, int) onChange;
  final bool isEnabled;
  final String selectedValue;
  final String? errorMessage;
  final bool alreadySaved;
  final bool readonly;
  final String updateMessage;
  final void Function(String)? onTabBtnNroDoc;
  final double? ajusteHemog;
  final double? altura;
  final int formId;
  final List<dynamic> hasFirma;
  final hasAudio;


  static const Color errorColor = Colors.redAccent;

  const FormQuestionWidget({
    Key? key,
    required this.id,
    required context,
    this.textEditController,
    required this.question,
    required this.onChange,
    this.isEnabled = true,
    this.selectedValue = '',
    this.errorMessage,
    this.alreadySaved = false,
    this.readonly = true,
    this.updateMessage = '',
    this.onTabBtnNroDoc,
    this.ajusteHemog,
    this.formId = 0,
    this.altura,
    this.hasFirma = const [""],
    this.hasAudio = false
  }) : super(
          key: key,
          context: context,
        );

  TextStyle? get textTheme {
    TextStyle? textTheme;
    switch (question.textTheme) {
      case 'headline1':
        textTheme = Theme.of(context).textTheme.headline1;
        break;
      case 'headline2':
        textTheme = Theme.of(context).textTheme.headline2;
        break;
      case 'headline3':
        textTheme = Theme.of(context).textTheme.headline3;
        break;
      case 'headline4':
        textTheme = Theme.of(context).textTheme.headline4;
        break;
      case 'headline5':
        textTheme = Theme.of(context).textTheme.headline5;
        break;
    }
    return textTheme;
  }

  Widget get buildField {
    switch (question.type) {
      case 'QT_TYPE_READONLY':
        return buildReadonly;
      case 'QT_TYPE_TXT_1':
      case 'QT_TYPE_TXT_2':
      case 'QT_TYPE_TXT_3':
      case 'QT_TYPE_TXT_4':
      case 'QT_TYPE_TXT_5':
      case 'QT_TYPE_TXT_6':
      if(question.id=='p_04' || question.id=='h_06_1'){
        return buildTextFieldButton;
      }
        return buildTextField;
      case 'QT_TYPE_DATE':
        return buildDateField;
      case 'QT_TYPE_CHKB':
        return buildCheckButton;
      case 'QT_TYPE_RADB':
        return buildRadioButton;
      case 'QT_TYPE_DROP':
        return buildDropdown;
      case 'QT_TYPE_RADB_BTN':
        return buildButtonSet;
      case 'QT_TYPE_BTN':
        return buildButton;
    }
    return errorMessage != null
        ? Container(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Text(
              errorMessage! == localizations.fieldIsRequiredMessage
                  ? localizations.fieldInputErrorRequired
                  : errorMessage!,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: errorColor,
                fontSize: 11,
              ),
            ),
          )
        : Container();
  }

  Widget get buildReadonly => Wrap(
        direction: Axis.horizontal,
        children: [
          for (var answer in question.answers)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 20,
                leading: const SizedBox(
                  height: 18,
                  width: 10,
                  child: Icon(
                    Icons.circle,
                    size: 10,
                  ),
                ),
                horizontalTitleGap: 0,
                title: Text(
                  answer.label,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      );

  Widget get buildTextField {
    var minLines = question.type == 'QT_TYPE_TXT_2' ? 3 : 1;
    var maxLines = question.type == 'QT_TYPE_TXT_2' ? 5 : 1;
    var maxLength = !!question.answers[0].label.isNotEmpty
        ? int.parse(question.answers[0].label)
        :null;

    var keyboardType =
        question.type == 'QT_TYPE_TXT_3' || question.type == 'QT_TYPE_TXT_4'
            ? const TextInputType.numberWithOptions()
            : question.type == 'QT_TYPE_TXT_5'
                ? TextInputType.phone
                : question.type == 'QT_TYPE_TXT_6'
                    ? TextInputType.emailAddress
                    : TextInputType.text;

    var funHelperText=() {
      if(textEditController!.value.text.length>0){
        if(ajusteHemog!=null ){
          var hem=double.parse(textEditController!.value.text);
          var comparar=hem-ajusteHemog!;
          if(comparar<0){
            UtilsToast.showDanger("El cálculo del tamizaje de hemoglobina es negativo, ingrese un nuevo valor.");

            return null;
          }
          String ajus = "|AJUSTE:";
          String newajust = ajus.replaceAll("|", "\n");
          String tami = "|TAMIZAJE HEMOGLOBINA:";
          String newtami = tami.replaceAll("|", "\n");
          return "ALTURA: "+" "+altura.toString()+" Metros "+newajust+" "+ajusteHemog.toString()+newtami+" "+(hem-ajusteHemog!).toString();
        }
      }
      return null;
    };
    var funHelperTextPreguntas=(){
      switch(question.id){
        case 'm_28_3':
        case 'n_05_10_3':
          return funHelperText();
        default:
          return null;
      }
    };

    return TextField(
      controller: textEditController,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        helperText: funHelperTextPreguntas(),
        helperStyle: TextStyle(  color: Colors.blueAccent, fontSize: 15,),
        errorText: errorMessage == localizations.fieldIsRequiredMessage
            ? localizations.fieldInputErrorRequired
            : errorMessage,
        errorMaxLines: 3,
      ),
      readOnly: alreadySaved && readonly,
    );
  }

  Widget get buildTextFieldButton {
    var minLines = question.type == 'QT_TYPE_TXT_2' ? 3 : 1;
    var maxLines = question.type == 'QT_TYPE_TXT_2' ? 5 : 1;
    var maxLength = !!question.answers[0].label.isNotEmpty
        ? int.parse(question.answers[0].label)
        :null;

    var keyboardType =
    question.type == 'QT_TYPE_TXT_3' || question.type == 'QT_TYPE_TXT_4'
        ? const TextInputType.numberWithOptions()
        : question.type == 'QT_TYPE_TXT_5'
        ? TextInputType.phone
        : question.type == 'QT_TYPE_TXT_6'
        ? TextInputType.emailAddress
        : TextInputType.text;

    return Row(
      children: <Widget>[
        Expanded(child: TextField(
          controller: textEditController,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            errorText: errorMessage == localizations.fieldIsRequiredMessage
                ? localizations.fieldInputErrorRequired
                : errorMessage,
            errorMaxLines: 3,
          ),
          readOnly: alreadySaved && readonly,
        )),
        Container(
          margin: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: (){
              if(onTabBtnNroDoc!=null){
                String s=textEditController==null?"":textEditController!.text;
                onTabBtnNroDoc!(s);
               }
              },
              child: const Icon(
                Icons.search,
                color: UtilsColorPalette.secondary,
                size: 30,
            ),
          ),
        )
      ],
    );
  }

  Widget get buildDateField {

    String fun({String text=""}){
      if(text.isEmpty){
        return "";
      }
      var splitt0=text.split("T");
      var splitt=text.split("-");
      var date;
      if(splitt0.length==2){
        var aux=splitt0[0].split("-");
        date=new DateTime(int.parse(aux[0]),int.parse(aux[1]),int.parse(aux[2]));
      }else{
        date=new DateTime(int.parse(splitt[2]),int.parse(splitt[1]),int.parse(splitt[0]));
      }
      var diff= DateTime.now().difference(date);
      var week=diff.inDays ~/7;
      var dias=diff.inDays-(week*7);
      print(dias);
      return "EDAD GESTACIONAL: "+week.toString()+" Semanas"+" "+dias.toString()+" días";
      //return "FUM: "+diff.inDays.toString()+" días";
    }

    return Column(
      children: [
        TextField(
          controller: textEditController,
          keyboardType: TextInputType.none,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            errorText: errorMessage == localizations.fieldIsRequiredMessage
                ? localizations.fieldInputErrorRequired
                : errorMessage,
          ),
          onTap: () {
            if (alreadySaved && readonly) {
              return;
            }
            var today = selectedValue.isEmpty
                ? DateTime.now()
                : DateTime.parse(selectedValue);
            UtilsDatetime.openCalendar(
              context: context,
              firstDate: DateTime(today.year - 110),
              initialDate: today,
              onPicked: (date) {
                if (date != null) {
                  textEditController?.text=DateFormat('dd-MM-yyyy').format(date);
                  FocusManager.instance.primaryFocus?.unfocus();
                  onChange(
                    question.id,
                    question.parent,
                    question.module,
                    question.answers[0].id,
                    date.toIso8601String(),
                    id,
                  );
                }
              },
            );
          },
          readOnly: alreadySaved && readonly,
        ),
        if(question.id=='m_18') Text(fun(text: textEditController!.value.text))
      ],
    );
  }

  Widget get buildCheckButton {
    var sizeWidth = MediaQuery.of(context).size.width;
    var isTwoOrTablet = question.answers.length == 2 || sizeWidth >= 768;
    var checkWidth = isTwoOrTablet ? (sizeWidth / 2) - 30 : sizeWidth;
    var optionsSelected = selectedValue.split('|');
    return Wrap(
      direction: Axis.horizontal,
      children: [
        for (var answer in question.answers)
          SizedBox(
            width: checkWidth,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: optionsSelected.contains('${answer.order}'),
              selected: optionsSelected.contains('${answer.order}'),
              activeColor: UtilsColorPalette.tertiary,
              title: Text(
                answer.label,
                style: Theme.of(context).textTheme.bodyText2!.merge(
                      TextStyle(
                        color: optionsSelected.contains('${answer.order}')
                            ? UtilsColorPalette.tertiary
                            : UtilsColorPalette.gray500,
                      ),
                    ),
              ),
              onChanged: (value) {
                if (alreadySaved && readonly) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                if (optionsSelected.contains('${answer.order}')) {
                  optionsSelected.remove('${answer.order}');
                } else {
                  optionsSelected.add('${answer.order}');
                }
                var stringsJoined = optionsSelected.join('|');
                if (stringsJoined == '|') {
                  stringsJoined = '';
                }
                onChange(
                  question.id,
                  question.parent,
                  question.module,
                  answer.id,
                  stringsJoined,
                  id,
                );
              },
              visualDensity: VisualDensity.compact,
            ),
          ),
        errorMessage != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: sizeWidth,
                child: Text(
                  errorMessage! == localizations.fieldIsRequiredMessage
                      ? localizations.fieldMultiSelectorErrorRequired
                      : errorMessage!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: errorColor,
                    fontSize: 11,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget get buildRadioButton {
    var sizeWidth = MediaQuery.of(context).size.width;
    var isTwoOrTablet = question.answers.length == 2 || sizeWidth >= 768;
    var radioWidth = isTwoOrTablet ? (sizeWidth / 2) - 30 : sizeWidth;
    return Wrap(
      direction: Axis.horizontal,
      children: [
        for (var answer in question.answers)
          SizedBox(
            width: radioWidth,
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              selected: '${answer.order}' == selectedValue,
              value: '${answer.order}',
              groupValue: selectedValue,
              activeColor: UtilsColorPalette.tertiary,
              title: Text(
                answer.label,
                style: Theme.of(context).textTheme.bodyText2!.merge(
                      TextStyle(
                        color: '${answer.order}' == selectedValue
                            ? UtilsColorPalette.tertiary
                            : UtilsColorPalette.gray500,
                      ),
                    ),
              ),
              onChanged: (value) {
                if (alreadySaved && readonly) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                onChange(
                  question.id,
                  question.parent,
                  question.module,
                  answer.id,
                  answer.order,
                  id,
                );
              },
              visualDensity: VisualDensity.compact,
            ),
          ),
        errorMessage != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: sizeWidth,
                child: Text(
                  errorMessage! == localizations.fieldIsRequiredMessage
                      ? localizations.fieldMultiSelectorErrorRequired
                      : errorMessage!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: errorColor,
                    fontSize: 11,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget get buildDropdown => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: question.answers
                    .map((item) => '${item.order}')
                    .contains(selectedValue)
                ? selectedValue
                : '',
            iconEnabledColor: UtilsColorPalette.secondary,
            isExpanded: true,
            items: [
              if (!alreadySaved || !readonly)
                DropdownMenuItem(
                  value: '',
                  enabled: false,
                  child: Text(
                    localizations.fieldDropdownPlaceholder,
                    style: const TextStyle(
                      color: UtilsColorPalette.gray400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (!alreadySaved || !readonly)
                for (var answer in question.answers)
                  DropdownMenuItem(
                    value: '${answer.order}',
                    child: Text(
                      answer.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              if (alreadySaved && readonly)
                for (var answer in question.answers)
                  if ('${answer.order}' == selectedValue)
                    DropdownMenuItem(
                      value: '${answer.order}',
                      enabled: false,
                      child: Text(
                        answer.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ],
            onChanged: (value) {
              if (alreadySaved && readonly) {
                return;
              }
              FocusManager.instance.primaryFocus?.unfocus();
              var answer = question.answers
                  .firstWhere((item) => '${item.order}' == value);
              onChange(
                question.id,
                question.parent,
                question.module,
                answer.id,
                value,
                id,
              );
            },
          ),
          errorMessage != null
              ? Container(
                  padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                  child: Text(
                    errorMessage! == localizations.fieldIsRequiredMessage
                        ? localizations.fieldMultiSelectorErrorRequired
                        : errorMessage!,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: errorColor,
                      fontSize: 11,
                    ),
                  ),
                )
              : Container(),
        ],
      );

  Widget get buildButtonSet => Column(
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var answer in question.answers)
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        selectedValue == '${answer.order}'
                            ? Colors.white
                            : UtilsColorPalette.primary,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        selectedValue == '${answer.order}'
                            ? UtilsColorPalette.primary
                            : Colors.white,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: selectedValue == '${answer.order}'
                                ? UtilsColorPalette.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (alreadySaved && readonly) {
                        return;
                      }
                      FocusManager.instance.primaryFocus?.unfocus();
                      onChange(
                        question.id,
                        question.parent,
                        question.module,
                        answer.id,
                        answer.order,
                        id,
                      );
                    },
                    child: Text(answer.label),
                  ),
                ),
              hasFirma.contains(question.id) ? Text("FIRMA ADJUNTA ✔",style: TextStyle(color: Colors.green)) : Container()
            ],
          ),
          errorMessage != null
              ? Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    errorMessage! == localizations.fieldIsRequiredMessage
                        ? localizations.fieldMultiSelectorErrorRequired
                        : errorMessage!,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: errorColor,
                      fontSize: 11,
                    ),
                  ),
                )
              : Container(),
        ],
      );

  Widget get buildButton {
    return Column(
      children: [
        Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var answer in question.answers)
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      selectedValue == '${answer.order}'
                          ? Colors.white
                          : UtilsColorPalette.reportColor02,
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      selectedValue == '${answer.order}'
                          ? UtilsColorPalette.reportColor02
                          : Colors.white,
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: selectedValue == '${answer.order}'
                              ? UtilsColorPalette.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    /*if((selectedValue == '${answer.order}')&&question.id=='h_09_1'){
                      return;
                    }
                    if (alreadySaved && readonly) {
                      return;
                    }
                    if((selectedValue == '${answer.order}')&&question.id=='h_13'){
                      return;
                    }*/
                    if (alreadySaved && readonly) {
                      return;
                    }

                    FocusManager.instance.primaryFocus?.unfocus();
                    onChange(
                      question.id,
                      question.parent,
                      question.module,
                      answer.id,
                      answer.order,
                      id,
                    );
                  },
                  child: Text(answer.label),
                ),
              ),
            hasFirma.contains(question.id) ? Text("FIRMA ADJUNTA ✔",style: TextStyle(color: Colors.green)) : Container(),
            hasAudio ? Text("AUDIO ADJUNTO ✔",style: TextStyle(color: Colors.green)) : Container()
          ],
        ),
        errorMessage != null
            ? Container(
          margin: const EdgeInsets.only(top: 10),
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Text(
            errorMessage! == localizations.fieldIsRequiredMessage
                ? localizations.fieldMultiSelectorErrorRequired
                : errorMessage!,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: errorColor,
              fontSize: 11,
            ),
          ),
        )
            : Container(),
      ],
    );
  }

  handleShowTooltip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 30,
        ),
        content: SingleChildScrollView(
          child: Text(
            question.description,
            style: const TextStyle(
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnabled || readonly) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style:
                        Theme.of(context).textTheme.bodyText2!.merge(textTheme),
                    children: [
                      if (alreadySaved && !readonly)
                        const TextSpan(
                          text: '* ',
                          style: TextStyle(color: errorColor),
                        ),
                      TextSpan(text: question.label),
                      if (alreadySaved && !readonly) const TextSpan(text: '\n'),
                      if (alreadySaved && !readonly)
                        TextSpan(
                          text: updateMessage.isNotEmpty
                              ? updateMessage
                              : localizations.fieldFormEditionRequired,
                          style: const TextStyle(color: errorColor),
                        ),
                    ],
                  ),
                ),
              ),
              question.description.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: GestureDetector(
                        onTap: handleShowTooltip,
                        child: const Icon(
                          Icons.help_outline,
                          color: UtilsColorPalette.secondary,
                          size: 30,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: buildField,
          ),
        ],
      ),
    );
  }
}
