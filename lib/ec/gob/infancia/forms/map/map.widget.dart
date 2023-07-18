/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-10-21
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.map;

class FormsMapWidget extends BaseStatefulWidget {
  static const routeName = 'forms.map';

  final double latitude;
  final double longitude;

  const FormsMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<FormsMapWidget> createState() => FormsMapState();
}
