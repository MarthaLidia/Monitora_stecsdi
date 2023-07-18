/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module03.home;

class FormHomeWidget extends BaseStatefulWidget {
  static const routeName = 'home_form__mod03';

  final int formId;

  const FormHomeWidget({
    Key? key,
    required this.formId,
  }) : super(key: key);

  @override
  State<FormHomeWidget> createState() => FormHomeState();
}
