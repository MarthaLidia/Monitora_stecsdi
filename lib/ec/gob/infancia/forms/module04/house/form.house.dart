/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2021-12-14
/// @Updated:

library ec.gob.infancia.ecuadorsincero.forms.module04.house;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';
import 'package:sincero/ec/gob/infancia/core/core.dart';
import 'package:sincero/ec/gob/infancia/core/utils/utils.dart';
import 'package:sincero/ec/gob/infancia/forms/forms.dart';
import 'package:sincero/ec/gob/infancia/forms/module04/embarazo/form.embarazo.dart';
//import 'package:sincero/ec/gob/infancia/forms/module04/home/form.home.dart';
import 'package:sincero/ec/gob/infancia/forms/module04/module04.dart';
//import 'package:sincero/ec/gob/infancia/forms/module04/people/form.people.dart';
import 'package:sincero/ec/gob/infancia/home/home.dart';
import 'package:sincero/main.dart';
import 'package:sqflite/sql.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'form.house.bloc-state.dart';
part 'form.house.bloc.dart';
part 'form.house.state.dart';
part 'form.house.widget.dart';

///obtener información de la madre
Future<dynamic> getInfoPersona (cedula) async {
  try{
    var uri =Uri.https(
        "brigadas.infancia.gob.ec:8091",
        "/api/person/public/$cedula"
    );
    var response=await http.get(uri);
    print("response:");
    print(response.request);
    if(response.statusCode==200){
      var body=json.decode(utf8.decoder.convert(response.bodyBytes));
      print("CEDULADOS");
      print(body);
      return body["result"];
    }
    return {};
  }catch(err){
    print(err);
    print("[ERROR] ${err.toString()}");
  }
}

