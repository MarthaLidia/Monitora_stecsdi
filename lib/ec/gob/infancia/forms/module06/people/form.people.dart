/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module06.people;

import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/person/form.person.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sql.dart';
import 'package:url_launcher/url_launcher.dart';


part 'form.people.bloc-state.dart';
part 'form.people.bloc.dart';
part 'form.people.state.dart';
part 'form.people.widget.dart';
