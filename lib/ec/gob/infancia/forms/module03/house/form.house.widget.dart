/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module03.house;

class FormHouseWidget extends BaseStatefulWidget {
  static const routeName = 'house_form_mod3';
  static const routeNameEdit = 'house_form__edit_mod3';

  final int? formId;

  const FormHouseWidget({
    Key? key,
    this.formId,
  }) : super(key: key);

  @override
  State<FormHouseWidget> createState() => FormHouseState();
}
