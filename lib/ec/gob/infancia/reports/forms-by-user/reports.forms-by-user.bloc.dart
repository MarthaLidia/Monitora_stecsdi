/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.reports.formsbyuser;

class ReportsFormsByUserBloc extends BaseBloc<ReportsFormsByUserBlocState> {
  ReportsFormsByUserBloc(BuildContext context)
      : super(context: context, creator: () => ReportsFormsByUserBlocState());

  @override
  onLoad() {
    state.addData('onlineData', []);
    state.addData('offlineData', []);
    sqliteDB.query('Location').then((value) {
      var locations = value
          .map((data) => ModelLocation.db(data))
          .toList()
          .cast<ModelLocation>();
      state.addData('locations', locations);
    });
  }

  _handleDateSelection() {
    showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime.parse('2021-01-01'),
      lastDate: DateTime.now().add(
        const Duration(days: 1),
      ),
    ).then((value) {
      if (value != null) {
        state.addData('dateFrom', value.start);
        var dateTo = DateTime.parse(
            DateFormat('yyyy-MM-ddT23:59:59.999').format(value.end));
        state.addData('dateTo', dateTo);
        state.dateFromController.text =
            DateFormat('dd-MM-yyyy', 'es_EC').format(value.start);
        state.dateToController.text =
            DateFormat('dd-MM-yyyy', 'es_EC').format(value.end);
        state.addData('onlineData', []);
        state.addData('offlineData', []);
      }
    });
  }

  _handleLoadReport() {
    if (state.dateFrom != null && state.dateTo != null) {
      state.addData('onlineData', []);
      state.addData('offlineData', []);
      _handleOnlineData();
      _handleOfflineData();
    }
  }

  _handleOnlineData() async {
    state.loading = true;
    await checkConnectivity();
    if (!state.isOnline) {
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        state.loading = false;
        UtilsToast.showWarning(localizations.reportOfflineDataWarning);
      });
      return;
    }

    UtilsHttp.get<List<dynamic>>(
      url: 'v1/report/formByUserAndDate',
      queryParams: {
        'dateFrom': state.dateFrom.toString(),
        'dateTo': state.dateTo.toString(),
      },
    ).then((res) {
      var data = res
          .map((item) => ModelReportFormByUser.from(
                item,
                locations: state.locations,
              ))
          .toList();
      state.addData('onlineData', data);
    }).catchError((error) {
      UtilsToast.showDanger(localizations.reportOnlineDataError);
    }).whenComplete(() {
      state.loading = false;
    });
  }

  _handleOfflineData() {
    sqliteDB.query('FormHeader', where: 'fh_id <= 0').then((res) {
      var data = res
          .map((item) => ModelReportFormByUser.db(
                item,
                locations: state.locations,
              ))
          .where((item) =>
              item.datetime.millisecondsSinceEpoch >=
                  state.dateFrom!.millisecondsSinceEpoch &&
              item.datetime.millisecondsSinceEpoch <=
                  state.dateTo!.millisecondsSinceEpoch)
          .toList();
      state.addData('offlineData', data);
    });
  }
}
