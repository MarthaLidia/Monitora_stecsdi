/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module03.child;

class FormChildWidget extends BaseStatefulWidget {
  static const routeName = 'people_child_form__mod03';

  final int formId;
  final int code;

  const FormChildWidget({
    Key? key,
    required this.formId,
    required this.code,
  }) : super(key: key);

  @override
  State<FormChildWidget> createState() => FormChildState();
}
