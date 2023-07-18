/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-27
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

/// Utilitario que muestra un mini-mapa en un modal.
void utilShowMapLocation(
  BuildContext context,
  double latitude,
  double longitude, {
  String? markedId,
  bool showMarkers = true,
  Function(double, double)? onUpdatePosition,
}) {
  var latLng = LatLng(
    latitude,
    longitude,
  );
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          height: 350,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: latLng,
              zoom: 17,
            ),
            markers: showMarkers && markedId != null
                ? {
                    Marker(
                      draggable: true,
                      markerId: MarkerId(markedId),
                      position: latLng,
                    ),
                  }
                : {},
            onCameraMove: (position) {
              setState(() {
                latLng = LatLng(
                  position.target.latitude,
                  position.target.longitude,
                );
              });
            },
          ),
        ),
      ),
    ),
  ).then((_) {
    if (onUpdatePosition != null) {
      onUpdatePosition(latLng.latitude, latLng.longitude);
    }
  });
}
