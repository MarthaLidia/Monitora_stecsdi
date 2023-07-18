/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-10-21
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.map;

class FormsMapBloc extends BaseBloc<FormsMapBlocState> {
  final double latitude;
  final double longitude;

  FormsMapBloc({
    required context,
    required this.latitude,
    required this.longitude,
  }) : super(context: context, creator: () => FormsMapBlocState());

  @override
  onLoad() async {
    state.loading = true;
    var latLng = LatLng(latitude, longitude);
    state.addData('latLng', latLng);
    state.loading = false;
  }

  handleCameraMove(CameraPosition position) {
    var latLng = LatLng(position.target.latitude, position.target.longitude);
    state.addData('latLng', latLng);
  }

  handlePositionSelected() {
    Navigator.of(context).pop(state.latLng);
  }
}
