/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module02.people;

class FormPeopleWidget extends BaseStatefulWidget {
  static const routeName = 'people_form__mod02';

  final int formId;

  const FormPeopleWidget({
    Key? key,
    required this.formId,
  }) : super(key: key);

  @override
  State<FormPeopleWidget> createState() => FormPeopleState();
}
