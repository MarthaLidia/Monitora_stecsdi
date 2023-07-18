/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated: 2021-05-17

library ec.gob.infancia.ecuadorsincero.home;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/map/map.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/house/form.house.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/module01.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/house/form.house.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/module02.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/people/form.people.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module03/house/form.house.dart'
as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/module03.dart';
import 'package:sincero/ec/gob/infancia/forms/module03/people/form.people.dart'
as module03;
import 'package:sincero/ec/gob/infancia/forms/module04/house/form.house.dart'
as module04;
import 'package:sincero/ec/gob/infancia/forms/module04/embarazo/form.embarazo.dart'
as module04;
import 'package:sincero/ec/gob/infancia/forms/module05/house/form.house.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/module05.dart';
import 'package:sincero/ec/gob/infancia/forms/module05/people/form.people.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module06/house/form.house.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/form.people.dart'
as module06;
import 'package:sincero/ec/gob/infancia/login/login.dart';
import 'package:sincero/ec/gob/infancia/planning/planning.dart';
import 'package:sincero/ec/gob/infancia/reports/forms-by-user/reports.forms-by-user.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sqflite.dart';

part 'home.bloc-state.dart';
part 'home.bloc-view.dart';
part 'home.bloc.dart';
part 'home.state.dart';
part 'home.widget.dart';
