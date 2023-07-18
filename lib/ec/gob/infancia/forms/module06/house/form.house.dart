/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module06.house;

import 'dart:math';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/map/map.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io' as io;

part 'form.house.bloc-state.dart';
part 'form.house.bloc-view.dart';
part 'form.house.bloc.dart';
part 'form.house.state.dart';
part 'form.house.widget.dart';
