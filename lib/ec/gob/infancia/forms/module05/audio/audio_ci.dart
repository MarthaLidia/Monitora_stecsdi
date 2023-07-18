import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';


class AudioCi extends StatefulWidget {
  const AudioCi({Key? key, required this.onAudioSave}):super(key: key);
  final Function() onAudioSave;
  @override
  State<AudioCi> createState() => _AudioCi();

}

class _AudioCi extends State<AudioCi> {

  int _counter = 0;
  final record = Record();
  bool recording = false;
  bool pause = false;


  void recordStart() async {
    if (await record.hasPermission()) {
      // Start recording
      await record.start(
        path: '/storage/self/primary/Download/audioCI.m4a',
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 32000, // by default
        samplingRate: 44100, // by default
      );

      setState((){
        recording=true;
      });
    }
  }

  void start() async {
    bool ispaused = await record.isPaused();
    bool isrecording = await record.isRecording();
    if (ispaused) {
      await record.resume();
      setState(() {
        pause=false;
        recording=true;
      });
      return;
    }
    if (isrecording) {
      return;
    }

    final permission = Permission.storage;
    final status = await permission.status;
    debugPrint('>>>Status $status');

    /// here it is coming as PermissionStatus.granted
    if (status != PermissionStatus.granted) {
      await permission.request();
      if (await permission.status.isGranted) {
        recordStart();
      } else {
        await permission.request();
      }
      debugPrint('>>> ${await permission.status}');
    } else {
      recordStart();
    }
    //directory = Directory('/storage/emulated/0/Download');

  }

  void recordPauseResume() async {
    bool isRecording = await record.isRecording();
    bool isResume = await record.isPaused();

    if (isRecording) {
      await record.pause();
      setState((){
        pause=true;
        recording=false;
      });

    }
    if (isResume) {
      await record.resume();
      setState((){
        pause=false;
        recording=true;
      });
    }
  }

  void recordStop() async {
    // Get the state of the recorder
    bool isRecording = await record.isRecording();


    // Stop recording
    if (isRecording) {
      await record.stop();
      setState(() {
        recording=false;
        pause=false;
      });
    }
    widget.onAudioSave();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Grabación concentimiento informado."),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: start,
                    icon: Icon(Icons.fiber_manual_record,size: 40.00),
                    color: recording ? Colors.red : Colors.blueGrey),
                IconButton(onPressed: recordPauseResume,
                  icon: Icon(Icons.pause,size: 40.00,),
                  color: pause ? Colors.deepOrange : Colors.blueGrey),
                IconButton(onPressed: recordStop,
                    icon: Icon(Icons.stop,size: 50.00),
                    color: Colors.blueGrey),
              ],
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
