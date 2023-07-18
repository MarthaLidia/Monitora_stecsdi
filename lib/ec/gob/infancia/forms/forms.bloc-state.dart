/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms;

abstract class FormBaseBlocState extends BaseBlocState {
  ModelUser get userInfo => data['userInfo'];

  List<Map<String, dynamic>> get peopleInfo => data['peopleInfo'] ?? [];

  List<ModelQuestion> get questions =>
      data['questions']?.cast<ModelQuestion>() ?? [];

  Map<String, TextEditingController> get questionsTextController =>
      data['questionsTextController'] ?? <String, TextEditingController>{};

  Map<String, ModelFormAnswer> get formAnswers =>
      data['formAnswers'] ?? <String, ModelFormAnswer>{};

  Map<String, String?> get formErrors =>
      data['formErrors'] ?? <String, String?>{};

  setQuestionsTextController(String key, TextEditingController item) {
    var items = <String, TextEditingController>{};
    if (data.containsKey('questionsTextController')) {
      items.addAll(data['questionsTextController']);
    }
    items[key] = item;
    addData('questionsTextController', items);
  }

  setFormAnswer(String key, ModelFormAnswer item) {
    var items = <String, ModelFormAnswer>{};
    if (data.containsKey('formAnswers')) {
      items.addAll(data['formAnswers']);
    }
    items[key] = item;
    addData('formAnswers', items);
  }

  removeFormAnswer(String key) {
    var items = <String, ModelFormAnswer>{};
    if (data.containsKey('formAnswers')) {
      items.addAll(data['formAnswers']);
    }
    items.remove(key);
    addData('formAnswers', items);
  }

  setFormErrors(String key, String? value) {
    var items = <String, String?>{};
    if (data.containsKey('formErrors')) {
      items.addAll(data['formErrors']);
    }
    items[key] = value;
    addData('formErrors', items);
  }

  ScrollController get listViewController =>
      data['listViewController'] ?? ScrollController();

  ScrollController get listView01Controller =>
      data['listView01Controller'] ?? ScrollController();

  ScrollController get listView02Controller =>
      data['listView02Controller'] ?? ScrollController();

  ScrollController get listView03Controller =>
      data['listView03Controller'] ?? ScrollController();

  ScrollController get listView04Controller =>
      data['listView04Controller'] ?? ScrollController();

  int get formHeader => data['formHeader'] ?? -1;

  List<ModelAnswerValidation> get formValidations =>
      data['formValidations'].cast<ModelAnswerValidation>() ?? [];
}
