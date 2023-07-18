/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-10-21
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.map;

class FormsMapBlocState extends BaseBlocState {
  FormsMapBlocState() {
    addData('mapType', MapType.satellite);
  }

  LatLng? get latLng => data['latLng'];

  MapType? get mapType => data['mapType'];
}
