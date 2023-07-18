/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module02.home;

class FormHomeState extends BaseState<FormHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<FormHomeBloc, FormHomeBlocState>(
      creator: () => FormHomeBloc(context: context, formId: widget.formId),
      builder: (context, state) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(localizations.appName),
          ),
          extendBody: false,
          body: TabBarView(
            children: [
              context.read<FormHomeBloc>().buildTabInfo(
                    localizations.formHomeSection02TabHouse,
                    'hs_02_a',
                    state.listView01Controller,
                  ),
              context.read<FormHomeBloc>().buildTabInfo(
                    localizations.formHomeSection02TabHome,
                    'hs_02_b',
                    state.listView02Controller,
                  ),
              context.read<FormHomeBloc>().buildTabInfo(
                    localizations.formHomeSection02TabFoodSecurity,
                    'hs_02_c',
                    state.listView03Controller,
                  ),
              context.read<FormHomeBloc>().buildTabInfo(
                    localizations.formHomeSection02TabHygiene,
                    'hs_02_d',
                    state.listView04Controller,
                  ),
            ],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(text: localizations.formHomeSection02TabHouse),
              Tab(text: localizations.formHomeSection02TabHome),
              Tab(text: localizations.formHomeSection02TabFoodSecurity),
              Tab(text: localizations.formHomeSection02TabHygiene),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: context.read<FormHomeBloc>().handleSubmit,
            child: const Icon(Icons.chevron_right_rounded),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        ),
      ),
    );
  }
}
