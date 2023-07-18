part of ec.gob.infancia.ecuadorsincero.forms.module04.child;

class FormChildWidget extends BaseStatefulWidget {
  static const routeName = 'child_form__mod04';
  static const routeNameEdit = 'child_form__edit__mod04';

  final int? formId;

  const FormChildWidget({
    Key? key,
    this.formId,
  }) : super(key: key);

  @override
  State<FormChildWidget> createState() => FormChildState();
}
