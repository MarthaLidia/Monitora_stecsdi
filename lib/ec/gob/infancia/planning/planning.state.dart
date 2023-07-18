/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.planning;

class PlanningState extends BaseState<PlanningWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<PlanningBloc, PlanningBlocState>(
      creator: () => PlanningBloc(context: context),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        body: Container(
          child: state.loading
              ? Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator.adaptive(),
                )
              : GoogleMap(
                  mapType: state.mapType ?? MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      state.data['latitude'],
                      state.data['longitude'],
                    ),
                    zoom: 18,
                  ),
                  onMapCreated: (mapController) {
                    context.read<PlanningBloc>().onMapCreated(mapController);
                  },
                  myLocationEnabled: true,
                  markers: state.data['markers'],
                  padding: const EdgeInsets.only(
                    top: 45,
                  ),
                  trafficEnabled: true,
                ),
        ),
        floatingActionButton: context.read<PlanningBloc>().buildAddFormButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
