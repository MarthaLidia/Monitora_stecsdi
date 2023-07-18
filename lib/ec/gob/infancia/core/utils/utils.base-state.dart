/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2021-05-17

part of ec.gob.infancia.ecuadorsincero.utils;

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({
    Key? key,
  }) : super(key: key);
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  BaseState() : super();

  AppLocalizations get localizations => AppLocalizations.of(context)!;

  double get width => MediaQuery.of(context).size.width;
}

abstract class BaseStateless extends StatelessWidget {
  final BuildContext context;

  const BaseStateless({
    Key? key,
    required this.context,
  }) : super(key: key);

  AppLocalizations get localizations => AppLocalizations.of(context)!;
}
