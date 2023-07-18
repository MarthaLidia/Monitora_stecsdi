/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.reports.formsbyuser;

class ReportsFormsByUserWidget extends BaseStatefulWidget {
  static const routeName = 'report_form';

  const ReportsFormsByUserWidget({Key? key}) : super(key: key);

  @override
  State<ReportsFormsByUserWidget> createState() => ReportsFormsByUserState();
}
