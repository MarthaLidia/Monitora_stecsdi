/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-04-30
/// @Updated: 2021-05-17

part of ec.gob.infancia.ecuadorsincero.home;

extension HomeView on HomeBloc {
  /// Construye los widgets necesarios de las encuestas.
  List<Widget> get buildFormData {
    if (state.forms.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Text(
            localizations.homeNoWaiting,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ];
    }

    var width = MediaQuery.of(context).size.width;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 15, left: 15),
            width: width,
            child: Text(
              localizations.homeWaitingForSync,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 15, left: 15, top: 30),
            width: width,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: UtilsColorPalette.secondary,
                ),
              ),
            ),
          ),
          for (var form in state.forms)
            Container(
              margin: const EdgeInsets.only(right: 15, left: 15),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: UtilsColorPalette.secondary,
                  ),
                ),
              ),
              child: Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 50 / width,
                  children: [
                    form.complete
                        ? SlidableAction(
                            onPressed: (_) => _handleSync(form),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.green,
                            icon: Icons.sync_rounded,
                          )
                        : SlidableAction(
                            onPressed: (_) => _handleDelete(form),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.red,
                            icon: Icons.delete_outline_rounded,
                          ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      bottom: 10,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      color: form.id > 0
                          ? UtilsColorPalette.secondary25
                          : Colors.transparent,
                    ),
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: [
                                TextSpan(
                                  text: localizations.fieldFormCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
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
                                TextSpan(text: ': ${form.finalAddress}\n'),
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
                                        text:
                                            '\n${localizations.fieldTryNumberLabel}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                form.tryNumber > 3
                                    ? const TextSpan(text: '')
                                    : TextSpan(
                                        text: ' ${form.tryNumber}',
                                      ),
                                if (form.updateMessage.isNotEmpty)
                                  TextSpan(
                                    text: '\n${form.updateMessage}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            GestureDetector(
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: UtilsColorPalette.primary,
                                size: 40,
                              ),
                              onTap: () async {
                                UtilsHttp.checkConnectivity().then((isOnline) {
                                  if (state.isOnline) {
                                    Navigator.of(context).pushNamed(
                                        FormsMapWidget.routeName,
                                        arguments: {
                                          'latitude': form.latitude,
                                          'longitude': form.longitude,
                                        }).then((value) {
                                      if (value != null) {
                                        var latLng = value as LatLng;
                                        _manualUpdateLocation(form,
                                            latLng.latitude, latLng.longitude);
                                      }
                                    });
                                  } else {
                                    UtilsToast.showWarning(
                                        localizations.homeMapOfflineMessage);
                                  }
                                });
                              },
                            ),
                            const Icon(
                              Icons.arrow_right,
                              color: UtilsColorPalette.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    var route = '';
                    switch (form.module) {
                      case Module01Constants.moduleId:
                        route = (form.tryNumber > 3 || form.complete)
                            ? FormPeopleWidget.routeName
                            : FormHouseWidget.routeNameEdit;
                        break;
                      case Module02Constants.moduleId:
                        route = (form.tryNumber > 3 || form.complete)
                            ? module02.FormPeopleWidget.routeName
                            : module02.FormHouseWidget.routeNameEdit;
                        break;
                      case Module03Constants.moduleId:
                        route = (form.tryNumber > 3 || form.complete)
                            ? module03.FormPeopleWidget.routeName
                            : module03.FormHouseWidget.routeNameEdit;
                        break;
                      case Module05Constants.moduleId:
                        route = (form.tryNumber > 3 || form.complete)
                            ? module05.FormPeopleWidget.routeName
                            : module05.FormHouseWidget.routeNameEdit;
                        break;
                      case Module06Constants.moduleId:
                        route = (form.tryNumber > 3 || form.complete)
                            ? module06.FormPeopleWidget.routeName
                            : module06.FormHouseWidget.routeNameEdit;
                        break;
                    }
                    Navigator.of(context).pushNamed(
                      route,
                      arguments: {
                        'id': form.id,
                      },
                    ).then(
                      (value) {
                        handleLoadOffline();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      )
    ];
  }

  /// Construye los widgets necesarios para la sincronización de DPA.
  List<Widget> get buildZonesData => [
        for (var city in state.cities)
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                CheckboxListTile(
                  title: Text(city['label']),
                  value: state.parentSelection[city['code']],
                  tristate: true,
                  onChanged: (value) {
                    state.addParentSelection(city['code'], value ?? false);
                  },
                ),
                for (var location in state.locations
                    .where((item) => item['parent'] == city['code']))
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: UtilsColorPalette.primary,
                          width: 1,
                        ),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(location['label']),
                      value: state.zoneSelection[location['code']] ?? false,
                      onChanged: (value) {
                        state.addZoneSelection(
                            location['code'], value!, location['parent']);
                      },
                    ),
                  ),
              ],
            ),
          ),
      ];

  /// Construye el widget necesario para el botón de submit de DPA.
  Widget get buildZoneSubmit => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: ElevatedButton(
          onPressed: handleLoadPeople,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.homeOptionSyncZonesSubmit),
              const Icon(Icons.sync_rounded),
            ],
          ),
        ),
      );

  /// Construye el widget de menú.
  Widget get buildDrawer => Drawer(
        child: RawScrollbar(
          controller: _drawerScrollController,
          thumbColor: UtilsColorPalette.secondary,
          thumbVisibility: true,
          radius: const Radius.circular(5),
          child: CustomScrollView(
            controller: _drawerScrollController,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: UtilsColorPalette.primary,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headline4!.merge(
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                          children: [
                            TextSpan(text: localizations.homeTitle),
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: 'v1.0.12 (45)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!state.isOnline)
                      ListTile(
                        title: Text(
                          localizations.homeOptionOfflineMessage,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (state.isOnline)
                      ListTile(
                        title: Text(localizations.homeOptionPlan),
                        trailing: const Icon(
                          Icons.location_on_outlined,
                          color: UtilsColorPalette.secondary,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(PlanningWidget.routeName)
                              .then((value) {
                            handleLoadOffline();
                          });
                        },
                      ),
                    if (state.userInfo.claims
                        .contains('MOVIL:report|encuestador|report_link'))
                      ListTile(
                        title: Text(localizations.homeOptionReportFormsByUser),
                        trailing: const Icon(
                          Icons.bar_chart_rounded,
                          color: UtilsColorPalette.secondary,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(ReportsFormsByUserWidget.routeName);
                        },
                      ),
                    ListTile(
                      title: Text(
                        localizations.homeOptionSyncLogout,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      onTap: handleLogout,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: UtilsColorPalette.secondary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    if (state.isOnline)
                      ListTile(
                        title: Text(localizations.homeOptionSyncAll),
                        trailing: state.syncApp
                            ? const CircularProgressIndicator.adaptive()
                            : const Icon(
                                Icons.sync_rounded,
                                color: UtilsColorPalette.secondary,
                              ),
                        onTap: handleSyncAll,
                      ),
                    // if (state.isOnline &&
                    //     state.userInfo.claims
                    //         .contains('MOVIL:home|encuestador|question_sync'))
                    //   ListTile(
                    //     title: Text(localizations.homeOptionSyncQuestions),
                    //     trailing: state.syncApp
                    //         ? const CircularProgressIndicator.adaptive()
                    //         : const Icon(
                    //             Icons.sync_rounded,
                    //             color: UtilsColorPalette.secondary,
                    //           ),
                    //     onTap: handleQuestionSync,
                    //   ),
                    // if (state.isOnline &&
                    //     state.userInfo.claims
                    //         .contains('MOVIL:home|encuestador|form_sync'))
                    //   ListTile(
                    //     title: Text(localizations.homeOptionSyncOnline),
                    //     trailing: state.syncOnline
                    //         ? const CircularProgressIndicator.adaptive()
                    //         : const Icon(
                    //             Icons.sync_rounded,
                    //             color: UtilsColorPalette.secondary,
                    //           ),
                    //     onTap: handleLoadOnline,
                    //   ),
                    // if (state.isOnline &&
                    //     state.userInfo.claims
                    //         .contains('MOVIL:home|encuestador|zones_sync'))
                    //   ListTile(
                    //     title: Text(localizations.homeOptionSyncDpa),
                    //     trailing: state.syncDpa
                    //         ? const CircularProgressIndicator.adaptive()
                    //         : const Icon(
                    //             Icons.sync_rounded,
                    //             color: UtilsColorPalette.secondary,
                    //           ),
                    //     onTap: _handleDpaSync,
                    //   ),
                    // Container(
                    //   margin: const EdgeInsets.only(top: 5, bottom: 5),
                    //   decoration: const BoxDecoration(
                    //     border: Border(
                    //       top: BorderSide(
                    //         color: UtilsColorPalette.secondary,
                    //         width: 1,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // if (state.isOnline & !state.syncPeople && !state.syncRs)
                    //   ListTile(
                    //     title: Text(localizations.homeOptionSyncZones),
                    //     trailing: state.syncZones
                    //         ? const CircularProgressIndicator.adaptive()
                    //         : const Icon(
                    //             Icons.sync_rounded,
                    //             color: UtilsColorPalette.secondary,
                    //           ),
                    //     onTap: handleLoadZones,
                    //   ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //     vertical: 10,
                    //   ),
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style: Theme.of(context).textTheme.bodyText2,
                    //       children: [
                    //         TextSpan(
                    //           text: localizations.homeOptionTotalPeopleLabel,
                    //           style: const TextStyle(
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //         const TextSpan(text: ': '),
                    //         TextSpan(
                    //             text:
                    //                 '${state.data['totalPeopleLoaded'] ?? 0}'),
                    //         TextSpan(
                    //             text: ' ${localizations.homeOptionTotalOf} '),
                    //         TextSpan(text: '${state.data['totalPeople']}'),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // if (state.data['peopleStopwatch'] != null)
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 10,
                    //     ),
                    //     child: Flex(
                    //       direction: Axis.horizontal,
                    //       children: [
                    //         const Icon(Icons.watch_later_outlined,
                    //             color: UtilsColorPalette.primary),
                    //         Container(
                    //           padding: const EdgeInsets.only(
                    //             left: 10,
                    //           ),
                    //           child: Text(
                    //               '${state.data['peopleStopwatch'].elapsed}'),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //     vertical: 10,
                    //   ),
                    //   child: RichText(
                    //     text: TextSpan(
                    //       style: Theme.of(context).textTheme.bodyText2,
                    //       children: [
                    //         TextSpan(
                    //           text: localizations.homeOptionTotalRsLabel,
                    //           style: const TextStyle(
                    //             fontWeight: FontWeight.w700,
                    //           ),
                    //         ),
                    //         const TextSpan(text: ': '),
                    //         TextSpan(
                    //             text: '${state.data['totalRsLoaded'] ?? 0}'),
                    //         TextSpan(
                    //             text: ' ${localizations.homeOptionTotalOf} '),
                    //         TextSpan(text: '${state.data['totalRs']}'),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // if (state.data['rsStopwatch'] != null)
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 10,
                    //     ),
                    //     child: Flex(
                    //       direction: Axis.horizontal,
                    //       children: [
                    //         const Icon(Icons.watch_later_outlined,
                    //             color: UtilsColorPalette.primary),
                    //         Container(
                    //           padding: const EdgeInsets.only(
                    //             left: 10,
                    //           ),
                    //           child:
                    //               Text('${state.data['rsStopwatch'].elapsed}'),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // state.syncPeople || state.syncRs
                    //     ? Container(
                    //         margin: const EdgeInsets.only(top: 20),
                    //         child: const LinearProgressIndicator(),
                    //       )
                    //     : Column(
                    //         children: [
                    //           Container(
                    //             margin: const EdgeInsets.only(
                    //               top: 15,
                    //               right: 15,
                    //               left: 15,
                    //             ),
                    //             child: Text(
                    //               localizations.homeOptionSyncZonesDisclaimer,
                    //               style: const TextStyle(
                    //                 fontSize: 10,
                    //                 fontWeight: FontWeight.w500,
                    //                 fontStyle: FontStyle.italic,
                    //               ),
                    //             ),
                    //           ),
                    //           buildZoneSubmit,
                    //           ...buildZonesData,
                    //         ],
                    //       ),
                    // if (state.data['incrementForStopwatch'] != null)
                    //   Text(
                    //     '${state.data['incrementForStopwatch']}',
                    //     style: const TextStyle(color: Colors.transparent),
                    //   ),
                    // if (state.isOnline &&
                    //     state.cities.isNotEmpty &&
                    //     !state.syncPeople &&
                    //     !state.syncRs)
                    //   buildZoneSubmit,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
