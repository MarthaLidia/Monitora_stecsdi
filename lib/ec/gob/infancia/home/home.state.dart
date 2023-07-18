/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated: 2022-05-05

part of ec.gob.infancia.ecuadorsincero.home;

class HomeState extends BaseState<HomeWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<HomeBloc, HomeBlocState>(
      creator: () => HomeBloc(context: context),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
          titleSpacing: 0,
        ),
        onDrawerChanged: (value) async {
          if (value) {
            context.read<HomeBloc>().checkConnectivity();
          }
        },
        drawer: context.read<HomeBloc>().buildDrawer,
        extendBody: true,
        body: state.loading
            ? Container(
                padding: const EdgeInsets.only(
                  top: 15,
                  right: 15,
                  left: 15,
                  bottom: 0,
                ),
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              )
            : CustomRawScrollbar(
                controller: _scrollController,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 15,
                      right: 15,
                      left: 15,
                      bottom: 20,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headline1,
                        children: [
                          const TextSpan(
                            text: 'Hola ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: state.userInfo.info.fullName,
                          ),
                          const TextSpan(
                            text: '!',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...context.read<HomeBloc>().buildFormData,
                  if (state.userInfo.claims.contains('MOVIL:home||module_02'))
                    const SizedBox(height: 20),
                  if (state.userInfo.claims.contains('MOVIL:home||module_02'))
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        bottom: 30,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(module02.FormHouseWidget.routeName)
                              .then((value) {
                            context.read<HomeBloc>().handleLoadOffline();
                          });
                        },
                        //child: const Icon(
                          //Icons.add,
                          //color: Colors.white,
                        //),
                        child: Text(
                          "WEB"
                        ),
                      ),
                    ),

                  if (state.userInfo.claims.contains('MOVIL:home||module_03'))
                    const SizedBox(height: 20),
                  if (state.userInfo.claims.contains('MOVIL:home||module_03'))
                    Container(
                    margin: const EdgeInsets.only(
                      right: 15,
                      left: 15,
                      bottom: 30,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(module03.FormHouseWidget.routeName)
                            .then((value) {
                          context.read<HomeBloc>().handleLoadOffline();
                        });
                      },
                      //child: const Icon(
                       // Icons.add,
                       // color: Colors.white,
                      //),
                      child: Text(
                          "Mingas ICF"
                      ),
                    ),
                  ),
                  if (state.userInfo.claims.contains('MOVIL:home||module_05'))
                    const SizedBox(height: 20),
                  if (state.userInfo.claims.contains('MOVIL:home||module_05'))
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        bottom: 30,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(module05.FormHouseWidget.routeName)
                              .then((value) {
                            context.read<HomeBloc>().handleLoadOffline();
                          });
                        },
                        //child: const Icon(
                        // Icons.add,
                        // color: Colors.white,
                        //),
                        child: Text(
                            "Campaña Vacunación"
                        ),
                      ),
                    ),
                  if (state.userInfo.claims.contains('MOVIL:home||module_06'))
                    const SizedBox(height: 20),
                  if (state.userInfo.claims.contains('MOVIL:home||module_06'))
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        bottom: 30,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(module06.FormHouseWidget.routeName)
                              .then((value) {
                            context.read<HomeBloc>().handleLoadOffline();
                          });
                        },
                        //child: const Icon(
                        // Icons.add,
                        // color: Colors.white,
                        //),
                        child: Text(
                            "Encuesta BIF"
                        ),
                      ),
                    ),
                  if (state.userInfo.claims.contains('MOVIL:home||module_04'))
                    const SizedBox(height: 20),
                  if (state.userInfo.claims.contains('MOVIL:home||module_04'))
                  Container(
                    margin: const EdgeInsets.only(
                      right: 15,
                      left: 15,
                      bottom: 30,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(module04.FormHouseWidget.routeName)
                            .then((value) {
                          //context.read<HomeBloc>().handleLoadOffline();
                        });
                      },
                      //child: const Icon(
                      // Icons.add,
                      // color: Colors.white,
                      //),
                      child: Text(
                          "Registro Control de Salud"
                      ),
                    ),
                  )
                ],
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Visibility(
          visible: state.userInfo.claims.contains('MOVIL:home||module_01'),
          child:  FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(FormHouseWidget.routeName)
                  .then((value) {
                context.read<HomeBloc>().handleLoadOffline();
              });
            },
          ),
        )
      ),
    );
  }
}
