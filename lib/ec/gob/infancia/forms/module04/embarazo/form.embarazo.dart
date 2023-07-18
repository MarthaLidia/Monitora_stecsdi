/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module04.embarazo;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
//import 'package:sincero/ec/gob/infancia/forms/module04/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module04/module04.dart';
//import 'package:sincero/ec/gob/infancia/forms/module04/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sql.dart';

part 'form.embarazo.bloc-state.dart';
part 'form.embarazo.bloc.dart';
part 'form.embarazo.state.dart';
part 'form.embarazo.widget.dart';
