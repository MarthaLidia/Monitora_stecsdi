/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-13
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.login;

class LoginWidget extends BaseStatefulWidget {
  static const routeName = 'login';

  const LoginWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => LoginState();
}
