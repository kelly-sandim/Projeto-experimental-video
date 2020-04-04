import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

import 'package:path_provider/path_provider.dart';
import '../../../../src/assets/colors/MyColors.dart';
//import 'package:app_vem_rodar_motorista/src/domain/public/api/PublicApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecordVideo extends StatefulWidget {
  @override
  _RecordVideoState createState() => _RecordVideoState();
}

class _RecordVideoState extends State<RecordVideo> { 

  /*********************************** VARIABLES *************************************/ 
  String videoName;
  String videoPath;
  CameraController controllerCamera;  
  List<CameraDescription> cameraList;
  int selectedCameraIdx;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  /************************************* FUNCTIONS *************************************/
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controllerCamera != null) {
      await controllerCamera.dispose();
    }

    controllerCamera = CameraController(cameraDescription, ResolutionPreset.medium);

    // If the controllerCamera is updated then update the UI.
    controllerCamera.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controllerCamera.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controllerCamera.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white
        );
      }
    });

    try {
      await controllerCamera.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx = selectedCameraIdx < cameraList.length - 1
        ? selectedCameraIdx + 1
        : 0;
    CameraDescription selectedCamera = cameraList[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((String fileName) {
      if (fileName != null) {
        Fluttertoast.showToast(
            msg: 'Recording video started',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white
        );
      }
      //dá um tempo de 30 sec de gravação
      Timer timer;
      timer = Timer.periodic(Duration(seconds: 30), (Timer t) { 
          _onStopButtonPressed();
          timer.cancel();
      });      
    });
  }
  

  void _onStopButtonPressed() {
    _stopVideoRecording(_callSendVideo).then((_) {
      if (mounted) setState(() {});
        Fluttertoast.showToast(
          msg: 'Video recorded to $videoPath',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white
        );
    });
  }

  Future<String> _startVideoRecording() async {
    if (!controllerCamera.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white
      );

      return null;
    }

    // Do nothing if a recording is on progress
    if (controllerCamera.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = '$currentTime.mp4';
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controllerCamera.startVideoRecording(fileName);  
      videoName = fileName; 
      videoPath = filePath;   
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return fileName;
  }

  Future<void> _stopVideoRecording(_callSendVideo) async {
    if (!controllerCamera.value.isRecordingVideo) {
      return null;
    }

    try {
      await controllerCamera.stopVideoRecording();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('videoName', videoName);
      prefs.setString('videoPath', videoPath);

      _callSendVideo();
      
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  _callSendVideo()
  {
    Navigator.pushNamed(context, '/SendVideo');
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white
    );
  }
  
  /*************************************** VIEW ***************************************/
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Get the listonNewCameraSelected of available cameraList.
    // Then set the first camera as selected.
    availableCameras()
        .then((availableCameras) {
      cameraList = availableCameras;

      if (cameraList.length > 0) {
        setState(() {
          selectedCameraIdx = 1;
        });

        _onCameraSwitched(cameraList[selectedCameraIdx]).then((void v) {});
      }
    })
        .catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controllerCamera != null && controllerCamera.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _captureControlRowWidget(),
                Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*************************** WIDGETS ***********************************/

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_front;
      case CameraLensDirection.front:
        return Icons.camera_rear;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controllerCamera == null || !controllerCamera.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controllerCamera.value.aspectRatio,
      child: CameraPreview(controllerCamera),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameraList == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameraList[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(
                _getCameraLensIcon(lensDirection)
            ),
            label: lensDirection.toString()
            .substring(lensDirection.toString().indexOf('.')+1) == "back" ? Text("Frontal") 
                                                                          : Text("Traseira")
        ),
      ),
    );
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.videocam, size: 40),
              color: MyColors.primaryColor,
              onPressed: controllerCamera != null &&
                  controllerCamera.value.isInitialized &&
                  !controllerCamera.value.isRecordingVideo
                  ? _onRecordButtonPressed
                  : null,
            ),
            // IconButton(
            //   icon: const Icon(Icons.stop),
            //   color: Colors.red,
            //   onPressed: controllerCamera != null &&
            //       controllerCamera.value.isInitialized &&
            //       controllerCamera.value.isRecordingVideo
            //       ? _onStopButtonPressed
            //       : null,
            // )
          ],
        ),
      ),
    );
  }
}
