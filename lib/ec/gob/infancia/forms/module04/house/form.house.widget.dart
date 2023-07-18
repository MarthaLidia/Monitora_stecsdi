/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module04.house;

class FormHouseWidget extends BaseStatefulWidget {
  static const routeName = 'house_form__mod04';
  static const routeNameEdit = 'house_form__edit__mod04';

  final int? formId;

  const FormHouseWidget({
    Key? key,
    this.formId,
  }) : super(key: key);

  @override
  State<FormHouseWidget> createState() => FormHouseState();
}
