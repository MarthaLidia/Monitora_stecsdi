/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module04.embarazo;

class FormEmbarazoWidget extends BaseStatefulWidget {
  static const routeName = 'embarazo_form__mod04';
  static const routeNameEdit = 'embarazo_form__edit__mod04';

  final int? formId;

  const FormEmbarazoWidget({
    Key? key,
    this.formId,
  }) : super(key: key);

  @override
  State<FormEmbarazoWidget> createState() => FormEmbarazoState();
}
