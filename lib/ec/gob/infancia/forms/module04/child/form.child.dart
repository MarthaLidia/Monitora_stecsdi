library ec.gob.infancia.ecuadorsincero.forms.module04.child;

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

part 'form.child.bloc-state.dart';
part 'form.child.bloc.dart';
part 'form.child.state.dart';
part 'form.child.widget.dart';