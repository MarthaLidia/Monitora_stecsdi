/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.planning;

class PlanningWidget extends BaseStatefulWidget {
  static const routeName = 'plan';

  const PlanningWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PlanningWidget> createState() => PlanningState();
}
