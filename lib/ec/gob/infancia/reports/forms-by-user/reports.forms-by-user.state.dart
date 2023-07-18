/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.reports.formsbyuser;

class ReportsFormsByUserState extends BaseState<ReportsFormsByUserWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<ReportsFormsByUserBloc,
        ReportsFormsByUserBlocState>(
      creator: () => ReportsFormsByUserBloc(context),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
        ),
        body: CustomRawScrollbar(
          controller: state.scrollController,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                localizations.reportFormByUserTitle,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            context.read<ReportsFormsByUserBloc>().buildSearchSection,
            if (state.loading)
              Container(
                padding: const EdgeInsets.only(
                  top: 15,
                  right: 15,
                  left: 15,
                  bottom: 0,
                ),
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              ),
            if (!state.loading && state.syncQty > 0)
              Flex(
                direction: width >= 768 ? Axis.horizontal :  Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child:
                        context.read<ReportsFormsByUserBloc>().buildFormsChart,
                  ),
                  SizedBox(
                    width: width - (width >= 768 ? 250 : 0),
                    child: context
                        .read<ReportsFormsByUserBloc>()
                        .buildFormsTableSummary,
                  ),
                ],
              ),
            if (!state.loading && state.syncQty > 0)
              context.read<ReportsFormsByUserBloc>().buildSeparator,
            if (!state.loading && state.totalQty > 0)
              context.read<ReportsFormsByUserBloc>().buildFormsTableDetail,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
