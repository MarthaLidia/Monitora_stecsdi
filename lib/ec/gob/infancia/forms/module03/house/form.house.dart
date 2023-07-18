/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module03.house;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/map/map.dart';
import 'package:sincero/ec/gob/infancia/forms/module03/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module03/module03.dart';
import 'package:sincero/ec/gob/infancia/forms/module03/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sqflite.dart';

part 'form.house.bloc-state.dart';
part 'form.house.bloc-view.dart';
part 'form.house.bloc.dart';
part 'form.house.state.dart';
part 'form.house.widget.dart';
