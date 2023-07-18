/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.woman;

class FormWomanWidget extends BaseStatefulWidget {
  static const routeName = 'people_woman_form__mod06';

  final int formId;
  final int code;

  const FormWomanWidget({
    Key? key,
    required this.formId,
    required this.code,
  }) : super(key: key);

  @override
  State<FormWomanWidget> createState() => FormWomanState();
}
