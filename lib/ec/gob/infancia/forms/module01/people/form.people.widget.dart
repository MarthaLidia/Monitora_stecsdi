/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.people;

class FormPeopleWidget extends BaseStatefulWidget {
  static const routeName = 'people_form';

  final int formId;

  const FormPeopleWidget({
    Key? key,
    required this.formId,
  }) : super(key: key);

  @override
  State<FormPeopleWidget> createState() => FormPeopleState();
}
