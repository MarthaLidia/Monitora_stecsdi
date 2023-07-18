/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.planning;

class PlanningBloc extends BaseBloc<PlanningBlocState> {
  PlanningBloc({
    required context,
  }) : super(context: context, creator: () => PlanningBlocState());

  @override
  onLoad() async {
    state.loading = true;
    await currentLocation;
    _handleLoadOffline();
  }

  /// Almacena el controlador del mapa en el patrón BLOC para posterior uso.
  onMapCreated(GoogleMapController mapController) {
    if (!state._mapController.isCompleted) {
      state._mapController.complete(mapController);
    }
  }

  /// Construye el botón de agregar nuevos formularios.
  Widget get buildAddFormButton => SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.layers),
              onPressed: () {
                if (state.mapType == MapType.normal) {
                  state.addData('mapType', MapType.hybrid);
                } else {
                  state.addData('mapType', MapType.normal);
                }
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(FormHouseWidget.routeName)
                    .then((_) {
                  _handleLoadOffline();
                });
              },
            ),
          ],
        ),
      );

  /// Gestiona la información offline.
  _handleLoadOffline() {
    state.loading = true;
    sqliteDB.query('FormHeader').then((formHeader) {
      var formList = formHeader
          .map((data) => ModelFormHeader.db(data))
          .toList()
          .cast<ModelFormHeader>();
      state.addData('forms', formList);
      Set<Marker> markers = {};
      for (var form in formList) {
        markers.add(
          Marker(
            draggable: false,
            markerId: MarkerId('${form.id}'),
            position: LatLng(form.latitude, form.longitude),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        (form.code?.isEmpty ?? true)
                            ? const TextSpan(text: '')
                            : TextSpan(
                                text: localizations.fieldFormCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        (form.code?.isEmpty ?? true)
                            ? const TextSpan(text: '')
                            : TextSpan(
                                text: ': ${form.code}\n',
                              ),
                        TextSpan(
                          text: localizations.fieldDateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': ${DateFormat('dd-MM-yyyy').format(form.datetime)}\n',
                        ),
                        TextSpan(
                          text: localizations.fieldAddressLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ': ${form.address ?? form.reverseAddress}\n',
                        ),
                        TextSpan(
                          text: localizations.fieldCreatedByLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ': ${form.userFullName}',
                        ),
                        form.tryNumber > 3
                            ? const TextSpan(text: '')
                            : TextSpan(
                                text: '\n${localizations.fieldTryNumberLabel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        form.tryNumber > 3
                            ? const TextSpan(text: '')
                            : TextSpan(
                                text: ' ${form.tryNumber}',
                              ),
                      ],
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Icon(
                          Icons.note_alt_outlined,
                          color: UtilsColorPalette.primary,
                          size: 35,
                        ),
                      ),
                      onTap: () {
                        if (form.tryNumber > 3 || form.complete) {
                          Navigator.of(context).pushNamed(
                            FormPeopleWidget.routeName,
                            arguments: {
                              'id': form.id,
                            },
                          ).then(
                            (value) {
                              _handleLoadOffline();
                            },
                          );
                        } else {
                          Navigator.of(context).pushNamed(
                            FormHouseWidget.routeNameEdit,
                            arguments: {
                              'id': form.id,
                            },
                          ).then(
                            (value) {
                              _handleLoadOffline();
                            },
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          form.complete
                              ? Icons.sync_rounded
                              : Icons.delete_outline_rounded,
                          color: form.complete ? Colors.green : Colors.red,
                          size: 40,
                        ),
                      ),
                      onTap: () {
                        if (form.complete) {
                          _handleSync(form);
                        } else {
                          _handleDelete(form);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
      state.addData('markers', markers);
      state.loading = false;
    });
  }

  /// Gestiona la sincronización de los formularios.
  _handleSync(ModelFormHeader form) async {
    var formId = form.id;
    UtilsHttp.checkConnectivity().then((_) {
      FormUtils.submitForm(
        context,
        state,
        formId,
        localizations,
        onCompleteOnline: () {
          Navigator.of(context).pop();
          _handleLoadOffline();
        },
        onError: () {
          UtilsToast.showWarning(localizations.fieldFormError_WAITING_ERROR);
        },
        module: form.module,
      );
    });
  }

  /// Elimina los formularios locales del dispositivo.
  _handleDelete(ModelFormHeader form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          top: 20,
          right: 20,
          bottom: 10,
          left: 20,
        ),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: [
              TextSpan(
                text: localizations.homeDeleteFormLabel,
              ),
              const TextSpan(
                text: '\n',
              ),
              TextSpan(
                text: localizations.homeDeleteFormQuestion,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(
          top: 10,
          right: 20,
          bottom: 20,
          left: 20,
        ),
        buttonPadding: EdgeInsets.zero,
        actions: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                _handleDeleteItem(form);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded),
                  Text(localizations.homeDeleteFormYes),
                ],
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      _handleLoadOffline();
    });
  }

  _handleDeleteItem(ModelFormHeader form) async {
    sqliteDB.delete(
      'FormAnswer',
      where: 'fa_header = ? AND fa_module = ?',
      whereArgs: [form.id, form.module],
    );
    sqliteDB.delete(
      'FormHeader',
      where: 'fh_id = ? AND fh_module = ?',
      whereArgs: [form.id, form.module],
    );

    var forms = state.forms;
    forms.remove(form);
    state.addData('forms', forms);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
