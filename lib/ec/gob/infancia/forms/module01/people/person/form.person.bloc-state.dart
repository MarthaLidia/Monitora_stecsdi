/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module01.person;

class FormPersonBlocState extends FormBaseBlocState {
  bool get verified => data['verified'] ?? false;
  bool get alreadyExists => data['alreadyExists'] ?? false;
}
