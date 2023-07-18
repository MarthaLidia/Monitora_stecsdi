/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelReportFormByUser {
  int id;
  String username;
  String code;
  DateTime datetime;
  String dpa;
  bool status;

  ModelReportFormByUser({
    required this.id,
    required this.username,
    required this.code,
    required this.datetime,
    required this.dpa,
    required this.status,
  });

  factory ModelReportFormByUser.from(Map<String, dynamic> obj,
      {List<ModelLocation>? locations}) {
    var dpa = obj['dpa'] ?? '';
    if (locations != null && locations.isNotEmpty) {
      var found = locations.where((item) => item.location == dpa);
      if (found.isNotEmpty) {
        dpa = found.first.label;
      }
    }
    return ModelReportFormByUser(
      id: obj['id'],
      username: obj['username'],
      code: obj['code'],
      datetime: DateTime.parse(obj['datetime']),
      dpa: dpa,
      status: obj['status'],
    );
  }

  factory ModelReportFormByUser.db(Map<String, dynamic> obj,
      {List<ModelLocation>? locations}) {
    var dpa = obj['fh_dpa'] ?? '';
    if (locations != null && locations.isNotEmpty) {
      var found = locations.where((item) => item.location == dpa);
      if (found.isNotEmpty) {
        dpa = found.first.label;
      }
    }
    return ModelReportFormByUser(
      id: obj['fh_id'],
      username: obj['fh_username'],
      code: obj['fh_code'],
      datetime: DateTime.parse(obj['fh_datetime']),
      dpa: dpa,
      status: obj['fh_complete'] == 1 ? true : false,
    );
  }
}
