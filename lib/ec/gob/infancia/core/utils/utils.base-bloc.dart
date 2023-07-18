/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2022-05-17

part of ec.gob.infancia.ecuadorsincero.utils;

abstract class BaseBlocState {
  bool _loading = false;
  Map<String, dynamic> _data = {};

  final StreamController<bool> _loadingController = StreamController<bool>();
  final StreamController<Map<String, dynamic>> _dataController =
      StreamController<Map<String, dynamic>>();

  BaseBlocState();

  bool get loading => _loading;
  bool get saving => _data['saving'] ?? false;
  Map<String, dynamic> get data => _data;

  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  set loading(bool loading) {
    _loading = loading;
    _loadingController.add(_loading);
  }

  set saving(bool value) {
    addData('saving', value);
  }

  set data(Map<String, dynamic> data) {
    _data = data;
    _dataController.add(_data);
  }

  bool get isOnline => data['isOnline'] ?? false;

  addData(String key, dynamic value) {
    _data[key] = value;
    _dataController.add(_data);
  }

  @mustCallSuper
  dispose() {
    _loadingController.close();
    _dataController.close();
  }

  get versionCode => data['versionCode'] ?? '';
}

abstract class BaseBloc<T extends BaseBlocState> extends Cubit<T> {
  ItemCreator<T> creator;
  BuildContext context;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  BaseBloc({required this.context, required this.creator}) : super(creator()) {
    onLoad();
    checkConnectivity();
    state.addData('versionCode', '...');
    PackageInfo.fromPlatform().then((packageInfo) {
      state.addData(
          'versionCode', '${packageInfo.version} (${packageInfo.buildNumber})');
    });
  }

  AppLocalizations get localizations => AppLocalizations.of(context)!;

  onLoad();

  /// Obtiene la ubicación actual del GPS. En el caso de tener deshabilitado o
  /// no haber dado los permisos anteriormente, la aplicación mostrará el
  /// dialogo por defecto del dispositivo móvil.
  Future<Map<String, double?>> get currentLocation async {
    var status = await Location.instance.hasPermission();
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.deniedForever) {
      await Location.instance.requestPermission();
      return await currentLocation;
    }

    var enabled = await Location.instance.serviceEnabled();
    if (!enabled) {
      await Location.instance.requestService();
      return await currentLocation;
    }

    var location = await Location.instance.getLocation();

    state.data.addAll({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'altitude': location.altitude,
    });
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'altitude': location.altitude,
    };
  }

  /// Verifica si el dispositivo móvil tiene una conexión a internet para las
  /// funcionalidades online como el mapa y sincronizar la app.
  Future<void> checkConnectivity() async {
    state.addData('isOnline', false);
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        state.addData('isOnline', true);
      }
    } on SocketException catch (err) {
      if (kDebugMode) {
        print('[ERROR]: $err');
      }
    }
  }

  double get width => MediaQuery.of(context).size.width;
}
