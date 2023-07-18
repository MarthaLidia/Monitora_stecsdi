/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.woman;

class FormWomanState extends BaseState<FormWomanWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormWomanBloc, FormWomanBlocState>(
      creator: () => FormWomanBloc(
        context: context,
        formId: widget.formId,
        code: widget.code,
      ),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        extendBody: false,
        body: context.read<FormWomanBloc>().buildTabInfo,
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<FormWomanBloc>().handleSubmit,
          child: const Icon(Icons.save_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
