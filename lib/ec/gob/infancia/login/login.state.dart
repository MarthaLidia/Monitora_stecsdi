/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-13
/// @Updated: 2022-05-26

part of ec.gob.infancia.ecuadorsincero.login;

class LoginState extends BaseState<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProviderWidget<LoginBloc, LoginBlocState>(
      creator: () => LoginBloc(context: context),
      builder: (context, state) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: UtilsColorPalette.theme,
          ),
          padding: const EdgeInsets.only(
            top: 75,
            right: 30,
            bottom: 40,
            left: 30,
          ),
          child: AutofillGroup(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Text(
                    localizations.loginTitle,
                    style: Theme.of(context).textTheme.headline1!.merge(
                          const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Text(
                    localizations.loginSubTitle,
                    style: Theme.of(context).textTheme.headline2!.merge(
                          const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 35,
                    right: 40,
                    bottom: 10,
                    left: 40,
                  ),
                  child: TextFormField(
                    controller: state.userController,
                    decoration: InputDecoration(
                      hintText: localizations.loginFormUser,
                      prefixIcon: const Icon(
                        Icons.account_circle_outlined,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9.]")),
                    ],
                    autofillHints: const [AutofillHints.username],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    controller: state.passController,
                    decoration: InputDecoration(
                      hintText: localizations.loginFormPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  child: FloatingActionButton(
                    onPressed: context.read<LoginBloc>().handleSubmit,
                    child: state.loading
                        ? const CircularProgressIndicator.adaptive(
                            backgroundColor: UtilsColorPalette.primary,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          )
                        : Text(
                            localizations.loginFormSubmit,
                            style: const TextStyle(
                              color: UtilsColorPalette.primary,
                            ),
                          ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 35,
                    right: 40,
                    bottom: 10,
                    left: 40,
                  ),
                  child: Text(
                    '${DateTime.now().year}',
                    style: Theme.of(context).textTheme.headline2!.merge(
                          const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 35,
                    right: 40,
                    bottom: 10,
                    left: 40,
                  ),
                  child: Text(
                    'v1.0.12 (45)',
                    style: Theme.of(context).textTheme.bodyText2!.merge(
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
