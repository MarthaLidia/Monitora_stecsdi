/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.reports.formsbyuser;

class ReportsFormsByUserBlocState extends BaseBlocState {
  final ScrollController scrollController = ScrollController();

  final TextEditingController dateFromController = TextEditingController();

  final TextEditingController dateToController = TextEditingController();

  DateTime? get dateFrom => data['dateFrom'];

  DateTime? get dateTo => data['dateTo'];

  List<ModelReportFormByUser> get onlineData =>
      data['onlineData']?.cast<ModelReportFormByUser>() ?? [];

  List<ModelReportFormByUser> get offlineData =>
      data['offlineData']?.cast<ModelReportFormByUser>() ?? [];

  List<ModelReportFormByUser> get allData {
    var data = [
      ...onlineData,
      ...offlineData,
    ];
    data.sort((a, b) => b.id - a.id);
    return data;
  }

  List<ModelLocation> get locations =>
      data['locations']?.cast<ModelLocation>() ?? [];

  int get notSyncQty => offlineData.length;
  int get syncQty => onlineData.length;
  int get validQty => onlineData.where((item) => item.status).length;
  int get notValidQty => onlineData.where((item) => !item.status).length;

  int get totalQty => notSyncQty + syncQty;

  double get notSyncPercent => (notSyncQty / totalQty);
  double get validPercent => (validQty / totalQty);
  double get notValidPercent => (notValidQty / totalQty);
}
