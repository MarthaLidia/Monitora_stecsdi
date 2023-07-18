/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module02.house;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/module02.dart';
import 'package:sincero/ec/gob/infancia/forms/module02/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sql.dart';

part 'form.house.bloc-state.dart';
part 'form.house.bloc.dart';
part 'form.house.state.dart';
part 'form.house.widget.dart';
