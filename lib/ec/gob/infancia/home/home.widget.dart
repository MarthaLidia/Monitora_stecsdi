/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.home;

class HomeWidget extends BaseStatefulWidget {
  static const routeName = 'home';

  const HomeWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeWidget> createState() => HomeState();
}
