/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-20
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelUserInfo {
  final int id;
  final bool status;
  final String user;
  final DateTime date;
  final String documentTypeId;
  final String documentTypeName;
  final String document;
  final String fullName;

  ModelUserInfo({
    required this.id,
    required this.status,
    required this.user,
    required this.date,
    required this.documentTypeId,
    required this.documentTypeName,
    required this.document,
    required this.fullName,
  });

  factory ModelUserInfo.from(Map<String, dynamic> obj) => ModelUserInfo(
        id: obj['id'],
        status: obj['status'],
        user: obj['user'],
        date: DateTime.parse(obj['date']),
        documentTypeId: obj['documentTypeId'],
        documentTypeName: obj['documentTypeName'],
        document: obj['document'],
        fullName: obj['fullName'],
      );

  factory ModelUserInfo.db(Map<String, dynamic> obj) => ModelUserInfo(
        id: obj['u_id'],
        status: obj['u_status'] == 1 ? true : false,
        user: obj['u_user'],
        date: DateTime.parse(obj['u_date']),
        documentTypeId: obj['u_documentTypeId'],
        documentTypeName: obj['u_documentTypeName'],
        document: obj['u_document'],
        fullName: obj['u_fullName'],
      );

  factory ModelUserInfo.empty() => ModelUserInfo(
        id: -1,
        status: false,
        user: '',
        date: DateTime.now(),
        documentTypeId: '',
        documentTypeName: '',
        document: '',
        fullName: '',
      );

  @override
  toString() {
    return '''{ 'fullName': $fullName, 'document': $document  }''';
  }
}
