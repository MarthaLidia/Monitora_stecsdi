/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-11
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelAnswerValidation {
  final int id;
  final String module;
  final String conditionQuestion;
  final String conditionAnswer;
  final String restrictionQuestion;
  final String restrictionAnswer;
  final String message;

  ModelAnswerValidation({
    required this.id,
    required this.module,
    required this.conditionQuestion,
    required this.conditionAnswer,
    required this.restrictionQuestion,
    required this.restrictionAnswer,
    required this.message,
  });

  factory ModelAnswerValidation.from(Map<String, dynamic> obj) =>
      ModelAnswerValidation(
        id: obj['id'],
        module: obj['module'],
        conditionQuestion: obj['conditionQuestion'],
        conditionAnswer: obj['conditionAnswer'],
        restrictionQuestion: obj['restrictionQuestion'],
        restrictionAnswer: obj['restrictionAnswer'] ?? '',
        message: obj['message'],
      );

  factory ModelAnswerValidation.db(Map<String, dynamic> obj) =>
      ModelAnswerValidation(
        id: obj['av_id'],
        module: obj['av_module'],
        conditionQuestion: obj['av_conditionQuestion'],
        conditionAnswer: obj['av_conditionAnswer'],
        restrictionQuestion: obj['av_restrictionQuestion'],
        restrictionAnswer: obj['av_restrictionAnswer'],
        message: obj['av_message'],
      );

  Map<String, dynamic> toDb() => {
        'av_id': id,
        'av_module': module,
        'av_conditionQuestion': conditionQuestion,
        'av_conditionAnswer': conditionAnswer,
        'av_restrictionQuestion': restrictionQuestion,
        'av_restrictionAnswer': restrictionAnswer,
        'av_message': message,
      };

  @override
  toString() {
    return '''{ 'id': $id, 'module': $module, 'conditionQuestion': $conditionQuestion, 'conditionAnswer': $conditionAnswer, 'restrictionQuestion': $restrictionQuestion, 'restrictionAnswer': $restrictionAnswer }''';
  }
}
