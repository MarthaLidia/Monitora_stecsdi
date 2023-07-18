/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-22
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module06.person;

import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/module06.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/child/form.child.dart';
import 'package:sincero/ec/gob/infancia/forms/module06/people/woman/form.woman.dart';
import 'package:sincero/main.dart';


import '../../../../home/home.dart';
import '../../../module04/house/form.house.dart';

part 'form.person.bloc-state.dart';
part 'form.person.bloc.dart';
part 'form.person.state.dart';
part 'form.person.widget.dart';
