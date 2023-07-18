/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module06.home;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/form.people.dart';
import 'package:sincero/main.dart';

import '../../../home/home.dart';

part 'form.home.bloc-state.dart';
part 'form.home.bloc.dart';
part 'form.home.state.dart';
part 'form.home.widget.dart';
