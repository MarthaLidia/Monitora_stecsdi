/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.person;

class FormPersonState extends BaseState<FormPersonWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormPersonBloc, FormPersonBlocState>(
      creator: () => FormPersonBloc(
        context: context,
        formId: widget.formId,
        code: widget.code,
      ),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        extendBody: false,
        body: context.read<FormPersonBloc>().buildTabInfo,
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<FormPersonBloc>().handleSubmit,
          child: Icon(
            state.data['saveIcon'] != null && state.data['saveIcon']
                ? Icons.save_outlined
                : Icons.chevron_right_rounded,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
