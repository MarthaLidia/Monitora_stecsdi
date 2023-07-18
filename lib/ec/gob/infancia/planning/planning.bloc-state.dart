/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.planning;

class PlanningBlocState extends BaseBlocState {
  final Completer<GoogleMapController> _mapController = Completer();

  PlanningBlocState() : super() {
    Set<Marker> markers = {};
    addData('markers', markers);
    addData('mapType', MapType.normal);
  }

  List<ModelFormHeader> get forms =>
      data['forms']?.cast<ModelFormHeader>() ?? [];

  MapType? get mapType => data['mapType'];
}
