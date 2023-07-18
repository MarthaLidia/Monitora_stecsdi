/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.home;

class FormHomeBlocState extends FormBaseBlocState {
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

  int get quantityTab01 =>
      questions.where((item) => _evaluateCond(item, 'hs_02_a')).toList().length;

  int get quantityTab02 =>
      questions.where((item) => _evaluateCond(item, 'hs_02_b')).toList().length;

  int get quantityTab03 =>
      questions.where((item) => _evaluateCond(item, 'hs_02_c')).toList().length;

  int get quantityTab04 =>
      questions.where((item) => _evaluateCond(item, 'hs_02_d')).toList().length;

  int get quantityTabs {
    var qty = 0;
    if (quantityTab01 > 0) {
      qty++;
    }
    if (quantityTab02 > 0) {
      qty++;
    }
    if (quantityTab03 > 0) {
      qty++;
    }
    if (quantityTab04 > 0) {
      qty++;
    }
    return qty;
  }
}
