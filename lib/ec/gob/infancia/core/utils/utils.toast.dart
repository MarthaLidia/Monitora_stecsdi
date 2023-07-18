/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-12
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

class UtilsToast {
  static showDanger(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.redAccent,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static showWarning(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.orangeAccent,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static showSuccess(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.greenAccent,
      toastLength: Toast.LENGTH_LONG,
    );
  }
}
