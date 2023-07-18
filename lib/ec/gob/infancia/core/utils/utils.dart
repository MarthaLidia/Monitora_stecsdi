/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-15
/// @Updated: 2022-05-17

library ec.gob.infancia.ecuadorsincero.utils;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sincero/ec/gob/infancia/forms/map/map.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/house/form.house.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/people/child/form.child.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/people/person/form.person.dart';
import 'package:sincero/ec/gob/infancia/forms/module01/people/woman/form.woman.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/home/form.home.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/house/form.house.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/people/child/form.child.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/people/form.people.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/people/person/form.person.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module02/people/woman/form.woman.dart'
    as module02;
import 'package:sincero/ec/gob/infancia/forms/module03/home/form.home.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/house/form.house.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/people/child/form.child.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/people/form.people.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/people/person/form.person.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module03/people/woman/form.woman.dart'
    as module03;
import 'package:sincero/ec/gob/infancia/forms/module04/house/form.house.dart'
    as module04;
import 'package:sincero/ec/gob/infancia/forms/module04/embarazo//form.embarazo.dart'
as module04;
import 'package:sincero/ec/gob/infancia/forms/module04/child//form.child.dart'
as module04;

import 'package:sincero/ec/gob/infancia/forms/module05/home/form.home.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/house/form.house.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/people/child/form.child.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/people/form.people.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/people/person/form.person.dart'
as module05;
import 'package:sincero/ec/gob/infancia/forms/module05/people/woman/form.woman.dart'
as module05;

import 'package:sincero/ec/gob/infancia/forms/module06/home/form.home.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/house/form.house.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/people/child/form.child.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/people/form.people.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/people/person/form.person.dart'
as module06;
import 'package:sincero/ec/gob/infancia/forms/module06/people/woman/form.woman.dart'
as module06;

import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/ec/gob/infancia/login/login.dart';
import 'package:sincero/ec/gob/infancia/planning/planning.dart';
import 'package:sincero/ec/gob/infancia/reports/forms-by-user/reports.forms-by-user.dart';
import 'package:sqflite/sqflite.dart';

part 'utils.base-bloc.dart';

part 'utils.base-state.dart';

part 'utils.bloc-provider.widget.dart';

part 'utils.constants.dart';

part 'utils.datetime.dart';

part 'utils.gps-permission.dart';

part 'utils.http.dart';

part 'utils.map-modal.dart';

part 'utils.raw-scrollbar.widget.dart';

part 'utils.read-write-files.dart';

part 'utils.request-wrapper.dart';

part 'utils.routing.dart';

part 'utils.sqlite-manager.dart';

part 'utils.toast.dart';

typedef ItemCreator<T> = T Function();
