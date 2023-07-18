/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.people;

class FormPeopleState extends BaseState<FormPeopleWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormPeopleBloc, FormPeopleBlocState>(
      creator: () => FormPeopleBloc(context: context, formId: widget.formId),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        extendBody: false,
        body: context.read<FormPeopleBloc>().buildTabInfo,
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<FormPeopleBloc>().handleSubmit,
          child: const Icon(Icons.save_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}
