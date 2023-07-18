/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.utils;

class BlocProviderWidget<B extends BaseBloc<S>, S extends BaseBlocState>
    extends BaseStatefulWidget {
  final ItemCreator<B> creator;
  final Widget Function(BuildContext, S) builder;

  const BlocProviderWidget({
    Key? key,
    required this.creator,
    required this.builder,
  }) : super(key: key);

  @override
  BlocProviderState<B, S> createState() => BlocProviderState<B, S>();
}

class BlocProviderState<B extends BaseBloc<S>, S extends BaseBlocState>
    extends BaseState<BlocProviderWidget<B, S>> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: (_) => widget.creator(),
      child: BlocBuilder<B, S>(
        builder: (context, state) => StreamBuilder(
          stream: state.loadingStream,
          builder: (context, loading) => StreamBuilder(
            stream: state.dataStream,
            builder: (context, data) => widget.builder(context, state),
          ),
        ),
      ),
    );
  }
}
