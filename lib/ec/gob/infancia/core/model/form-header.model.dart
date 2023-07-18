/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated: 2022-05-17

part of ec.gob.infancia.ecuadorsincero.core;

class ModelFormHeader extends UtilsRequestWrapper {
  int id;
  String creationUser;
  String creationDate;
  String module;
  String moduleName;
  double latitude;
  double longitude;
  DateTime datetime;
  bool complete;
  bool rsRequest;
  String comments;
  String username;
  String userFullName;
  int tryNumber;
  List<ModelFormAnswer>? answers;
  String reverseAddress;
  String? address;
  bool? isReady;
  String? code;
  String dpa;
  String updateMessage;
  String version;
  String firmaBase64;
  String audioCi;

  ModelFormHeader({
    required this.id,
    this.creationUser = '',
    this.creationDate = '',
    required this.module,
    required this.moduleName,
    required this.latitude,
    required this.longitude,
    required this.datetime,
    required this.complete,
    required this.rsRequest,
    required this.comments,
    required this.username,
    required this.userFullName,
    required this.tryNumber,
    this.answers,
    required this.reverseAddress,
    this.address,
    this.isReady,
    this.code,
    this.dpa = '',
    this.updateMessage = '',
    required this.version,
    this.firmaBase64='',
    this.audioCi='',
  });

  factory ModelFormHeader.from(Map<String, dynamic> obj) {
    var items = obj['answers']
        .map((item) => ModelFormAnswer.from(item))
        .toList()
        .cast<ModelFormAnswer>();
    return ModelFormHeader(
      id: obj['id']??0,
      creationUser: obj['creationUser'],
      creationDate: obj['creationDate'],
      module: obj['module'],
      moduleName: obj['moduleName'],
      latitude: obj['latitude'],
      longitude: obj['longitude'],
      datetime: DateTime.parse(obj['datetime']),
      complete: obj['complete'] ?? false,
      rsRequest: obj['rsRequest'] ?? false,
      comments: obj['comments'] ?? '',
      username: obj['username'],
      userFullName: obj['userFullName'],
      tryNumber: obj['tryNumber'],
      answers: items,
      reverseAddress: obj['reverseAddress'] ?? '',
      address: obj['address'] ?? '',
      code: obj['code'] ?? '',
      updateMessage: obj['updateMessage'] ?? '',
      version: obj['version'] ?? '',
      firmaBase64: obj['firma_base64'] ?? '',
      audioCi:obj['audio_ci'] ?? '',
    );
  }

  factory ModelFormHeader.db(Map<String, dynamic> obj) => ModelFormHeader(
        id: obj['fh_id'],
        creationUser: obj['fh_creationUser'] ?? '',
        creationDate: obj['fh_creationDate'] ?? '',
        module: obj['fh_module'],
        moduleName: obj['fh_moduleName'],
        latitude: obj['fh_latitude'],
        longitude: obj['fh_longitude'],
        datetime: DateTime.parse(obj['fh_datetime']),
        complete: obj['fh_complete'] == 1 ? true : false,
        rsRequest: obj['fh_rsRequest'] == 1 ? true : false,
        comments: obj['fh_comments'],
        username: obj['fh_username'],
        userFullName: obj['fh_userFullName'],
        tryNumber: obj['fh_tryNumber'],
        reverseAddress: obj['fh_reverseAddress'],
        address: obj['fh_address'],
        isReady: obj['fh_ready'] == null
            ? false
            : obj['fh_ready'] == 1
                ? true
                : false,
        code: obj['fh_code'],
        dpa: obj['fh_dpa'] ?? '',
        updateMessage: obj['fh_updateMessage'] ?? '',
        version: '',
        firmaBase64: obj['fh_firma_base64']?? '',
        audioCi: obj['fh_audio_ci']?? '',
      );

  Map<String, dynamic> toDb() => {
        'fh_id': id,
        'fh_creationUser': creationUser,
        'fh_creationDate': creationDate,
        'fh_module': module,
        'fh_moduleName': moduleName,
        'fh_latitude': latitude,
        'fh_longitude': longitude,
        'fh_datetime': datetime.toIso8601String(),
        'fh_complete': complete ? 1 : 0,
        'fh_rsRequest': rsRequest ? 1 : 0,
        'fh_comments': comments,
        'fh_username': username,
        'fh_userFullName': userFullName,
        'fh_tryNumber': tryNumber,
        'fh_reverseAddress': reverseAddress,
        'fh_address': address,
        'fh_ready': (isReady ?? false) ? 1 : 0,
        'fh_code': code,
        'fh_dpa': dpa,
        'fh_updateMessage': updateMessage,
        'fh_firma_base64':firmaBase64,
        'fh_audio_ci':audioCi,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id <= 0 ? null : id,
        'creationUser': creationUser.isEmpty ? null : creationUser,
        'creationDate': creationDate.isEmpty ? null : creationDate,
        'module': module,
        'latitude': latitude,
        'longitude': longitude,
        'datetime': datetime.toIso8601String(),
        'complete': complete,
        'rsRequest': rsRequest,
        'comments': comments,
        'username': username,
        'tryNumber': tryNumber,
        'answers': answers ?? [],
        'reverseAddress': reverseAddress,
        'address': address,
        'code': code,
        'app': true,
        'version': version,
        'firmaBase64':firmaBase64,
        'audioCi':audioCi,
      };

  String get finalAddress {
    if ((address ?? '').isEmpty) {
      return reverseAddress;
    }
    return address!;
  }

  @override
  toString() =>
      '''{ 'id': $id, 'module': $module, 'latitude': $latitude, 'longitude': $longitude }''';
}
