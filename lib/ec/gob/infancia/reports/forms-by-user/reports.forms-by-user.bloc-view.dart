/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-17
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.reports.formsbyuser;

extension ReportsFormsByUserBlocView on ReportsFormsByUserBloc {
  Widget get buildSeparator => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: UtilsColorPalette.secondary),
              ),
            ),
            width: width,
          ),
          const SizedBox(height: 10),
        ],
      );

  Widget get buildSearchSection {
    var widthSize = (width - 126) / 2;
    return Flex(
      direction: Axis.vertical,
      children: [
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(
            top: 10,
            right: 20,
            bottom: 5,
            left: 20,
          ),
          width: width,
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: widthSize,
                child: Text(
                  '${localizations.labelDateFromLabel}:',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: widthSize,
                child: Text(
                  '${localizations.labelDateToLabel}:',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            right: 20,
            bottom: 10,
            left: 20,
          ),
          width: width,
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: widthSize,
                child: TextField(
                  controller: state.dateFromController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'dd-mm-aaaa',
                  ),
                  onTap: _handleDateSelection,
                ),
              ),
              SizedBox(
                width: widthSize,
                child: TextField(
                  controller: state.dateToController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'dd-mm-aaaa',
                  ),
                  onTap: _handleDateSelection,
                ),
              ),
              FloatingActionButton(
                onPressed: _handleLoadReport,
                child: const Icon(Icons.search_rounded),
              ),
            ],
          ),
        ),
        buildSeparator,
      ],
    );
  }

  Widget get buildFormsChart => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: width,
        child: SizedBox(
          height: 250,
          width: 250,
          child: PieChart(
            PieChartData(
              sections: [
                _buildChartItem(
                  color: UtilsColorPalette.reportColor01,
                  value: state.notSyncPercent,
                ),
                _buildChartItem(
                  color: UtilsColorPalette.reportColor02,
                  value: state.validPercent,
                ),
                _buildChartItem(
                  color: UtilsColorPalette.reportColor03,
                  value: state.notValidPercent,
                ),
              ],
            ),
          ),
        ),
      );

  Widget get buildFormsTableSummary => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: width,
        child: Column(
          children: [
            if (state.totalQty > 0)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: const Border(
                    top: BorderSide(color: UtilsColorPalette.primary),
                    bottom: BorderSide(color: UtilsColorPalette.primary),
                  ),
                  color: UtilsColorPalette.theme.shade400,
                ),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      width: width - (width >= 768 ? 380 : 130),
                      child: Text(
                        localizations.labelDetailLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 70,
                      child: Text(
                        localizations.labelTotalLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (state.notSyncQty > 0)
              _buildSummaryItem(
                color: UtilsColorPalette.reportColor01,
                label: localizations.reportFormNoSyncLabel,
                qty: state.notSyncQty,
                weight: FontWeight.w700,
              ),
            if (state.syncQty > 0)
              _buildSummaryItem(
                label: localizations.reportFormSyncLabel,
                qty: state.syncQty,
                weight: FontWeight.w700,
              ),
            if (state.syncQty > 0)
              _buildSummaryItem(
                color: UtilsColorPalette.reportColor02,
                label: localizations.reportFormValidLabel,
                qty: state.validQty,
                isChild: true,
              ),
            if (state.syncQty > 0)
              _buildSummaryItem(
                color: UtilsColorPalette.reportColor03,
                label: localizations.reportFormWaitingLabel,
                qty: state.notValidQty,
                isChild: true,
              ),
            if (state.syncQty > 0)
              Container(
                alignment: Alignment.centerRight,
                width: width,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: UtilsColorPalette.primary),
                  ),
                  color: UtilsColorPalette.theme.shade400,
                ),
                child: Text(
                  '${state.totalQty}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
          ],
        ),
      );

  Widget get buildFormsTableDetail => Flex(
        direction: Axis.vertical,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
            decoration: BoxDecoration(
              border: const Border(
                top: BorderSide(color: UtilsColorPalette.primary),
                bottom: BorderSide(color: UtilsColorPalette.primary),
              ),
              color: UtilsColorPalette.theme.shade400,
            ),
            child: Text(
              localizations.reportDetailLabel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ignore: no_leading_underscores_for_local_identifiers
          for (var _idx = 0; _idx < state.allData.length; _idx++)
            Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: state.allData[_idx].id > 0 &&
                            !state.allData[_idx].status
                        ? UtilsColorPalette.secondary25
                        : Colors.transparent,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: width,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(
                          text: localizations.labelNumberLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ': ${_idx + 1}\n'),
                        TextSpan(
                          text: localizations.labelCodeLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ': ${state.allData[_idx].code}\n',
                        ),
                        TextSpan(
                          text: localizations.labelDateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': ${DateFormat('dd-MM-yyyy').format(state.allData[_idx].datetime)}\n',
                        ),
                        TextSpan(
                          text: localizations.labelLocationLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ': ${state.allData[_idx].dpa}\n',
                        ),
                        TextSpan(
                          text: localizations.labelStatusLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ': '),
                        if (state.allData[_idx].id > 0 &&
                            state.allData[_idx].status)
                          TextSpan(
                              text: localizations.reportFormValidStatusLabel),
                        if (state.allData[_idx].id > 0 &&
                            !state.allData[_idx].status)
                          TextSpan(
                              text: localizations.reportFormWaitingStatusLabel),
                        if (state.allData[_idx].id < 0)
                          TextSpan(
                              text: localizations.reportFormNoSyncStatusLabel),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: UtilsColorPalette.primary,
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ],
            ),
        ],
      );

  Widget _buildSummaryItem({
    Color color = Colors.transparent,
    required String label,
    required int qty,
    bool isChild = false,
    FontWeight weight = FontWeight.w400,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: UtilsColorPalette.primary),
          ),
        ),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isChild) const SizedBox(width: 20),
            Container(
              height: 20,
              width: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(
              width:
                  width - (isChild ? 20 : 0) - (width >= 768 ? 430 : 170),
              child: Text(
                label,
                style: TextStyle(fontWeight: weight),
              ),
            ),
            Container(
              width: 70,
              alignment: Alignment.topRight,
              child: Text(
                '$qty',
                style: TextStyle(fontWeight: weight),
              ),
            ),
          ],
        ),
      );

  PieChartSectionData _buildChartItem({
    required Color color,
    required double value,
  }) =>
      PieChartSectionData(
        color: color,
        value: value,
        title: NumberFormat('#.##%').format(value),
        radius: 60,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
}
