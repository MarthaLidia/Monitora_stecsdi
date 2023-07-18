/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.child;

class FormChildState extends BaseState<FormChildWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormChildBloc, FormChildBlocState>(
      creator: () => FormChildBloc(
        context: context,
        formId: widget.formId,
        code: widget.code,
      ),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        extendBody: false,
        body: context.read<FormChildBloc>().buildTabInfo,
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<FormChildBloc>().handleSubmit,
          child: const Icon(Icons.save_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
