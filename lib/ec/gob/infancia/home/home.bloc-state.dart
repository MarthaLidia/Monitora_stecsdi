/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.home;

class HomeBlocState extends BaseBlocState {
  ModelUser get userInfo => data['userInfo'] ?? ModelUser.empty();

  List<ModelFormHeader> get forms {
    if (data['forms'] == null) {
      return [];
    }
    List<ModelFormHeader> forms = data['forms'].cast<ModelFormHeader>();
    var saved = forms.where((item) => item.id > 0).toList();
    saved.sort((a, b) => a.id - b.id);
    var notSaved = forms.where((item) => item.id <= 0);
    return [
      ...saved,
      ...notSaved,
    ];
  }

  bool get syncApp => data['syncApp'] != null && data['syncApp'];

  bool get syncOnline => data['syncOnline'] != null && data['syncOnline'];

  bool get syncZones => data['syncZones'] != null && data['syncZones'];

  List<dynamic> get cities => data['cities'] ?? [];

  List<dynamic> get locations => data['locations'] ?? [];

  bool get syncPeople => data['syncPeople'] != null && data['syncPeople'];

  List<dynamic> get peopleData => data['peopleData'] ?? [];

  bool get syncRs => data['syncRs'] != null && data['syncRs'];

  List<dynamic> get rsData => data['rsData'] ?? [];

  Map<String, bool> get zoneSelection =>
      data['zoneSelection'] ?? <String, bool>{};

  Map<String, bool?> get parentSelection =>
      data['parentSelection'] ?? <String, bool?>{};

  void addZoneSelection(String key, bool value, String parent) {
    var zones = zoneSelection;
    zones[key] = value;
    addData('zoneSelection', zones);

    bool? parentValue = false;
    var counter = 0;
    var parents = locations.where((item) => item['parent'] == parent);
    for (var location in parents) {
      if (zones[location['code']] != null && zones[location['code']]!) {
        parentValue = null;
        counter++;
      }
    }
    if (counter == parents.length) {
      parentValue = true;
    }

    var parentsSelection = parentSelection;
    parentsSelection[parent] = parentValue;
    addData('parentSelection', parentsSelection);
  }

  void addParentSelection(String parent, bool value) {
    var zones = zoneSelection;
    var parentsSelection = parentSelection;

    var parents = locations.where((item) => item['parent'] == parent);
    for (var location in parents) {
      zones[location['code']] = value;
    }
    parentsSelection[parent] = value;

    addData('zoneSelection', zones);
    addData('parentSelection', parentsSelection);
  }

  void addPeopleData(List<dynamic> data) {
    var current = [...peopleData];
    current.addAll(data);
    addData('peopleData', current);
  }

  void addRsData(List<dynamic> data) {
    var current = [...rsData];
    current.addAll(data);
    addData('rsData', current);
  }

  bool get syncDpa => data['syncDpa'] != null && data['syncDpa'];
}
