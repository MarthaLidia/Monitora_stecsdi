/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-10-21
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.map;

extension FormsMapView on FormsMapBloc {
  Widget get buildBody => Column(
       children: [
          Expanded(
            child: state.latLng != null
                ? GoogleMap(
                    mapType: state.mapType ?? MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: state.latLng!,
                      zoom: 17,
                    ),
                    markers: {
                      if (state.latLng != null)
                        Marker(
                          draggable: true,
                          markerId: const MarkerId('fullscreen_marker'),
                          position: state.latLng!,
                        ),
                    },
                    onCameraMove: handleCameraMove,
                  )
                : Container(),
          ),
        ],
      );

  Widget get buildChangeLayer => FloatingActionButton(
        heroTag: null,
        onPressed: () {
          if (state.mapType == MapType.normal) {
            state.addData('mapType', MapType.hybrid);
          } else {
            state.addData('mapType', MapType.normal);
          }
        },
        child: const Icon(Icons.layers),
      );
}
