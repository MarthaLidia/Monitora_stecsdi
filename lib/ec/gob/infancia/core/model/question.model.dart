/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelQuestion {
  final String id;
  final String module;
  final String parent;
  final int order;
  final String label;
  final String type;
  final bool visible;
  final String enabledBy;
  final String textTheme;
  final String description;
  final int children;
  List<ModelAnswerCategory> answers;

  ModelQuestion({
    required this.id,
    required this.module,
    required this.parent,
    required this.order,
    required this.label,
    required this.type,
    required this.visible,
    required this.enabledBy,
    required this.textTheme,
    required this.description,
    required this.children,
    required this.answers,
  });

  factory ModelQuestion.from(Map<String, dynamic> obj) => ModelQuestion(
        id: obj['id'],
        module: obj['module'],
        parent: obj['parent'] ?? '',
        order: obj['order'],
        label: obj['label'],
        type: obj['type'] ?? '',
        visible: obj['visible'],
        enabledBy: obj['enabledBy'] ?? '',
        textTheme: obj['textTheme'] ?? '',
        description: obj['description'] ?? '',
        children: obj['children'],
        answers: obj['answers'] == null
            ? []
            : obj['answers']
                .map((item) => ModelAnswerCategory.from(item))
                .toList()
                .cast<ModelAnswerCategory>(),
      );

  factory ModelQuestion.db(Map<String, dynamic> obj) {
    List<dynamic> answers = jsonDecode(obj['q_answers']);
    print(answers);
    return ModelQuestion(
      id: obj['q_id'],
      module: obj['q_module'],
      parent: obj['q_parent'],
      order: obj['q_order'],
      label: obj['q_label'],
      type: obj['q_type'],
      visible: obj['q_visible'] == 1 ? true : false,
      enabledBy: obj['q_enabledBy'],
      textTheme: obj['q_textTheme'],
      description: obj['q_description'],
      children: obj['q_children'],
      answers:
          answers.map((answer) => ModelAnswerCategory.from(answer)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'q_id': id,
        'q_module': module,
        'q_parent': parent,
        'q_order': order,
        'q_label': label,
        'q_type': type,
        'q_visible': visible ? 1 : 0,
        'q_enabledBy': enabledBy,
        'q_textTheme': textTheme,
        'q_description': description,
        'q_children': children,
        'q_answers': jsonEncode(answers),
      };

  List<Map<String, dynamic>> get enabledByValue {
    var values = <Map<String, dynamic>>[];
    var items = enabledBy.split(',');
    items=items.where((element) => element!="").toList();
    for (var item in items) {
      var itemMap = item.split('|');

       values.add({
        'key': itemMap[0],
        'value': itemMap[1],
      });
    }
    return values;
  }
  @override
  toString() {
    return '''{ 'id': $id, 'module': $module, 'parent': $parent, 'label': $label, 'type': $type }''';
  }
}
