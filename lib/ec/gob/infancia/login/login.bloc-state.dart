/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-13
/// @Updated: 2022-01-27

part of ec.gob.infancia.ecuadorsincero.login;

class LoginBlocState extends BaseBlocState {
  TextEditingController? get userController => data['userController'];
  TextEditingController? get passController => data['passController'];
}
