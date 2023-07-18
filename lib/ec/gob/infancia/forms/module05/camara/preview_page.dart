import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../../../main.dart';
import '../../../core/core.dart';
import '../module05.dart';
import 'dart:developer';

class PreviewPage extends StatelessWidget {
  PreviewPage({Key? key, required this.picture, required this.onSaveImage, this.questionId=""}) : super(key: key);

  final XFile picture;
  final Function(XFile,String) onSaveImage;
  String questionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captar imagen')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture.name),
          ElevatedButton(onPressed: ()async{
            onSaveImage(picture,questionId);
          }, child: Text("Guardar"))
        ]),
      ),
    );
  }
}
