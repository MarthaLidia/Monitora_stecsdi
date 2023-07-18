/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelFormAnswer extends UtilsRequestWrapper {
  int id;
  String creationUser;
  String creationDate;
  int header;
  String question;
  String questionParent;
  String module;
  int answer;
  int? code;
  String? other;
  bool complete;
  String updateMessage;
  String temp;

  ModelFormAnswer({
    required this.id,
    this.creationUser = '',
    this.creationDate = '',
    required this.header,
    required this.question,
    required this.questionParent,
    required this.module,
    required this.answer,
    this.code,
    this.other,
    required this.complete,
    this.updateMessage = '',
    this.temp='',
  });

  factory ModelFormAnswer.from(Map<String, dynamic> obj) => ModelFormAnswer(
        id: obj['id'],
        creationUser: obj['creationUser'] ?? '',
        creationDate: obj['creationDate'] ?? '',
        header: obj['header'] ?? -1,
        question: obj['question'],
        questionParent: obj['questionParent'],
        module: obj['module'],
        answer: obj['answer'],
        code: obj['code'],
        other: obj['other'] ?? '',
        complete: obj['complete'],
        updateMessage: obj['updateMessage'] ?? '',
        temp: obj["temp"]??''
      );

  factory ModelFormAnswer.db(Map<String, dynamic> obj) => ModelFormAnswer(
        id: obj['fa_id'] ?? -1,
        creationUser: obj['fa_creationUser'] ?? '',
        creationDate: obj['fa_creationDate'] ?? '',
        header: obj['fa_header'],
        question: obj['fa_question'],
        questionParent: obj['fa_questionParent'],
        module: obj['fa_module'],
        answer: obj['fa_answer'],
        code: obj['fa_code'],
        other: obj['fa_other'] ?? '',
        complete: (obj['fa_complete'] ?? 0) == 1 ? true : false,
        updateMessage: obj['fa_updateMessage'] ?? '',
        temp: obj['fa_temp']??''
      );

  Map<String, dynamic> toDb() => {
        'fa_id': id,
        'fa_creationUser': creationUser,
        'fa_creationDate': creationDate,
        'fa_header': header,
        'fa_question': question,
        'fa_questionParent': questionParent,
        'fa_module': module,
        'fa_answer': answer,
        'fa_code': code,
        'fa_other': other ?? '',
        'fa_complete': complete ? 1 : 0,
        'fa_updateMessage': updateMessage,
        'fa_temp':temp,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id == -1 ? null : id,
        'creationUser': creationUser.isEmpty ? null : creationUser,
        'creationDate': creationDate.isEmpty ? null : creationDate,
        'question': question,
        'module': module,
        'answer': answer,
        'code': code,
        'other': other,
        'complete': true,
        'temp':temp
      };

  @override
  toString() =>
      '''{ 'id': $id, 'header': $header, 'question': $question, 'module': $module, 'answer': $answer, 'code': $code, 'other': $other, complete: $complete, temp:$temp }''';
}
