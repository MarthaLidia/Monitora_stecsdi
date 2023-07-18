/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.person;

class FormPersonWidget extends BaseStatefulWidget {
  static const routeName = 'people_person_form';

  final int formId;
  final int code;

  const FormPersonWidget({
    Key? key,
    required this.formId,
    required this.code,
  }) : super(key: key);

  @override
  State<FormPersonWidget> createState() => FormPersonState();
}
