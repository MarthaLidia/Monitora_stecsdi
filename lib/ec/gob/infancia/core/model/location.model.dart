/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-05-06
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelLocation {
  final String state;
  final String stateLabel;
  final String city;
  final String cityLabel;
  final String location;
  final String locationLabel;

  ModelLocation({
    required this.state,
    required this.stateLabel,
    required this.city,
    required this.cityLabel,
    required this.location,
    required this.locationLabel,
  });

  factory ModelLocation.from(Map<String, dynamic> obj) => ModelLocation(
        state: obj['state'],
        stateLabel: obj['stateLabel'],
        city: obj['city'],
        cityLabel: obj['cityLabel'],
        location: obj['location'],
        locationLabel: obj['locationLabel'],
      );

  factory ModelLocation.db(Map<String, dynamic> obj) => ModelLocation(
        state: obj['l_state'],
        stateLabel: obj['l_stateLabel'],
        city: obj['l_city'],
        cityLabel: obj['l_cityLabel'],
        location: obj['l_location'],
        locationLabel: obj['l_locationLabel'],
      );

  Map<String, dynamic> toDb() => {
        'l_state': state,
        'l_stateLabel': stateLabel,
        'l_city': city,
        'l_cityLabel': cityLabel,
        'l_location': location,
        'l_locationLabel': locationLabel,
      };

  String get label => '$location - $locationLabel - $cityLabel - $stateLabel';

  @override
  toString() =>
      '''{ 'stateLabel': $stateLabel, 'cityLabel': $cityLabel, 'locationLabel': $locationLabel }''';
}
