/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2022-07-11

part of ec.gob.infancia.ecuadorsincero.forms.module06.house;

class FormHouseBlocState extends FormBaseBlocState {
  List<ModelLocation> get locations =>
      data['locations']?.cast<ModelLocation>() ?? [];

  TextEditingValue? get locationValue => data['locationValue'];


  bool get _showAutocomplete {
    var isReadonly = formAnswers['h_05']?.complete ?? false;
    var alreadySaved = formHeader > 0;
    return (!isReadonly && alreadySaved) || !alreadySaved;
  }
}
