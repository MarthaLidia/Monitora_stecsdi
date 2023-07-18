/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.people;

class FormPeopleBlocState extends FormBaseBlocState {
  bool _evaluateCond(ModelQuestion item, String parent) {
    var isEnabled = true;
    if (item.enabledBy.isNotEmpty) {
      isEnabled = false;
      for (var item in item.enabledByValue) {
        var otherValues = formAnswers[item['key']]?.other?.split('|') ?? [];
        if (otherValues.contains(item['value'])) {
          isEnabled = true;
          break;
        }
      }
    }

    var isReadonly = formAnswers[item.id]?.complete ?? false;
    var alreadySaved = formHeader > 0;
    var condition = (alreadySaved &&
            item.type.isNotEmpty &&
            item.type != 'QT_TYPE_READONLY') ||
        !alreadySaved;

    return isEnabled &&
        !isReadonly &&
        condition &&
        item.parent == parent &&
        item.visible &&
        item.type.isNotEmpty;
  }

  int get quantity =>
      questions.where((item) => _evaluateCond(item, 'r')).toList().length;

  bool get jumpToQuesitons => data['jumpToQuesitons'] ?? false;
}
