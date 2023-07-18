/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-10-21
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.map;

class FormsMapState extends BaseState<FormsMapWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormsMapBloc, FormsMapBlocState>(
      creator: () => FormsMapBloc(
        context: context,
        latitude: widget.latitude,
        longitude: widget.longitude,
      ),
      builder: (context, state) => WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(localizations.appName),
            leading: IconButton(
              icon: const Icon(Icons.check),
              onPressed: context.read<FormsMapBloc>().handlePositionSelected,
            ),
          ),
          body: context.read<FormsMapBloc>().buildBody,
          floatingActionButton: context.read<FormsMapBloc>().buildChangeLayer,
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        ),
        onWillPop: () async {
          context.read<FormsMapBloc>().handlePositionSelected();
          return false;
        },
      ),
    );
  }
}
