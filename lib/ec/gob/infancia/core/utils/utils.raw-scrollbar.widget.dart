/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

class CustomRawScrollbar extends StatelessWidget {
  final ScrollController controller;
  final List<Widget> children;

  const CustomRawScrollbar(
      {Key? key, required this.controller, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbColor: UtilsColorPalette.secondary,
      thumbVisibility: true,
      radius: const Radius.circular(5),
      child: ListView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}
