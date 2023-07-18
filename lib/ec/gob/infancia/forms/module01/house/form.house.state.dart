/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.house;

class FormHouseState extends BaseState<FormHouseWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormHouseBloc, FormHouseBlocState>(
      creator: () => FormHouseBloc(context: context, formId: widget.formId),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        body: state.loading
            ? Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Text(
                      localizations.formHomeTitle,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Expanded(
                    child: CustomRawScrollbar(
                      controller: state.listViewController,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: Text(
                            localizations.formHomeSection01,
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        state.isOnline
                            ? GestureDetector(
                                onTap: context
                                    .read<FormHouseBloc>()
                                    .handleShowMapLocation,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        localizations.formHomeLocation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: UtilsColorPalette.secondary,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        ...context.read<FormHouseBloc>().buildReadonlyInfo,
                        ...context.read<FormHouseBloc>().buildFormData,
                        Container(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton:
            state.data['showContinuar'] != null && state.data['showContinuar']
                ? FloatingActionButton(
                    onPressed: context.read<FormHouseBloc>().handleSubmit,
                    child: const Icon(Icons.chevron_right_rounded),
                  )
                : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
