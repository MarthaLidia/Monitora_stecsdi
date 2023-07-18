/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.forms.module06.house;

extension FormHouseView on FormHouseBloc {
  List<Widget> get buildReadonlyInfo => [
        buildLabelValueInfo(
            localizations.fieldLatitudeLabel, formHeader.latitude),
        buildLabelValueInfo(
            localizations.fieldLongitudeLabel, formHeader.longitude),
        buildLabelValueInfo(
            localizations.fieldReverseAddressLabel, formHeader.reverseAddress),
        buildLabelValueInfo(localizations.fieldDateLabel,
            DateFormat('dd-MM-yyyy').format(formHeader.datetime)),
        buildLabelValueInfo(localizations.fieldTimeLabel,
            DateFormat('hh:mm aa').format(formHeader.datetime)),
        (formHeader.code ?? '').isNotEmpty
            ? buildLabelValueInfo(localizations.fieldFormCode, formHeader.code)
            : Container(),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 15),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: UtilsColorPalette.secondary,
              ),
            ),
          ),
        ),
      ];

  Widget buildLabelValueInfo(String label, dynamic value) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: '$value'),
            ],
          ),
        ),
      );

  Widget _buildAutocompleteField(
    BuildContext context,
    TextEditingController fieldTextController,
    FocusNode focusNode,
    void Function() onFieldSubmitted,
  ) =>
      TextField(
        controller: fieldTextController,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          //errorText: state.formErrors['h_05'],
        ),
        onChanged: (val) {
          if (val.length < (state.locationValue?.text.length ?? 0)) {
            _handleEmptyLocationSelected();
          }
        },
      );

  Widget _buildAutocompleteOptions(
    BuildContext context,
    void Function(ModelLocation) onSelected,
    Iterable<ModelLocation> options,
  ) =>
      Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            height: 210,
            child: RawScrollbar(
              controller: _autocompleteController,
              thumbColor: UtilsColorPalette.secondary,
              thumbVisibility: true,
              radius: const Radius.circular(5),
              child: ListView.builder(
                controller: _autocompleteController,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final ModelLocation option = options.elementAt(index);
                  final bool selected = option.label
                      .contains(state.data['locationSelected'] ?? '-1');
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? Colors.black12 : Colors.white,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

  Widget get _buildAutocomplete => Autocomplete<ModelLocation>(
        displayStringForOption: (item) => item.label,
        onSelected: _handleLocationSelected,
        initialValue: TextEditingValue(text:state.data["dpa"]??""),////state.locationValue,
        optionsBuilder: (value) {
          var text = value.text.toLowerCase();
          /*if(text.isEmpty){
            var text= "hola";
          }*/
          var found = state.locations
              .where((item) => item.label.toLowerCase().contains(text));
          print("Text");
          print(text);
          print("Found");
          print(found);
          return found;
        },
        //fieldViewBuilder: _buildAutocompleteField,
        optionsViewBuilder: _buildAutocompleteOptions,
      );

  List<Widget> get buildFormData => [
        if (state.locationValue != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.formHomeDpa),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: _buildAutocomplete,
                ),
              ],
            ),
          ),
        ...FormUtils.buildForm(
          state,
          questions:
              state.questions.where((question) => question.visible).toList(),
          handleChange: _handleQuestionChange,
          handleTabBtnNroDoc: _handleTabBtnNroDoc,
        ),
        (formHeader.code ?? '').isNotEmpty
            ? buildLabelValueInfo(localizations.fieldFormCode, formHeader.code)
            : Container(),
      ];
}
