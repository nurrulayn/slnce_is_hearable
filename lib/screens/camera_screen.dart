import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:silence_is_hearable/screens/splash_screen.dart';

class CameraScreen extends StatefulWidget {
  final String predictionType;

  const CameraScreen({required this.predictionType, Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  late List<CameraDescription> _cameras;
  int _selectedCameraIndex = 0;
  String _handGestureOutput = '';
  String _facialExpressionOutput = '';
  String _sentencePrediction = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<String>> _extractFrames(String videoPath) async {
    final directory = await getTemporaryDirectory();
    final outputDir = directory.path;
    const frameRate = 8; // Extract 8 frames per second
    const duration = 3; // 3 seconds video
    final frames = <String>[];

    final command = '-i $videoPath -vf fps=$frameRate $outputDir/frame%d.png';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode!.isValueSuccess()) {
        for (var i = 1; i <= frameRate * duration; i++) {
          final framePath = '$outputDir/frame$i.png';
          if (await File(framePath).exists()) {
            final frameBytes = await File(framePath).readAsBytes();
            frames.add(base64Encode(frameBytes));
          } else {
            print('Frame not found: $framePath');
          }
        }
      } else {
        print('Error executing FFmpeg command. Return code: ${returnCode.getValue()}');
      }
    });

    return frames;
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      try {
        await _initializeControllerFuture;
        await _controller.startVideoRecording();
        setState(() {
          _isRecording = true;
        });

        await Future.delayed(const Duration(seconds: 3));

        final XFile videoFile = await _controller.stopVideoRecording();
        final String videoPath = videoFile.path;

        final List<String> frames = await _extractFrames(videoPath);

        // Prepare endpoint URLs based on prediction types
        late String handGestureEndpoint;
        late String sentenceEndpoint;
        late String facialExpressionEndpoint;

        switch (widget.predictionType) {
          case 'word':
            handGestureEndpoint = 'http://192.168.10.6:5000/predict_hand_gesture';
            break;
          case 'sentence':
            sentenceEndpoint = 'http://192.168.10.6:5002/predict_sentence';
            break;
          default:
            throw Exception('Unknown prediction type: ${widget.predictionType}');
        }

        facialExpressionEndpoint = 'http://192.168.10.6:5001/predict_facial_expression';

        // Send frames to the selected endpoints
        if (widget.predictionType == 'word' && handGestureEndpoint.isNotEmpty) {
          final handGestureResponse = await http.post(
            Uri.parse(handGestureEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'frames': frames}),
          );

          if (handGestureResponse.statusCode == 200) {
            var data = jsonDecode(handGestureResponse.body);

            if (data.containsKey('prediction') && data['prediction'] != null) {
              setState(() {
                _handGestureOutput = data['prediction'];
              });
            } else {
              print('Hand gesture prediction not found in response or is null');
            }
          } else {
            print('Failed to get hand gesture prediction from endpoint');
          }
        }

        if (widget.predictionType == 'sentence' && sentenceEndpoint.isNotEmpty) {
          final sentenceResponse = await http.post(
            Uri.parse(sentenceEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'frames': frames}),
          );

          if (sentenceResponse.statusCode == 200) {
            var data = jsonDecode(sentenceResponse.body);

            if (data.containsKey('prediction_1') && data['prediction_1'] != null) {
              String prediction1 = data['prediction_1'];
              String prediction2 = data['prediction_2'];

              // Customize concatenation logic here
              setState(() {
                _sentencePrediction = '$prediction1 $prediction2';
              });
            } else {
              print('Sentence prediction not found in response or is null');
            }
          } else {
            print('Failed to get sentence prediction from endpoint');
          }
        }

        final facialExpressionResponse = await http.post(
          Uri.parse(facialExpressionEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'frames': frames}),
        );

        if (facialExpressionResponse.statusCode == 200) {
          var data = jsonDecode(facialExpressionResponse.body);

          if (data.containsKey('prediction') && data['prediction'] != null) {
            setState(() {
              _facialExpressionOutput = data['prediction'];
            });
          } else {
            print('Facial expression prediction not found in response or is null');
          }
        } else {
          print('Failed to get facial expression prediction from endpoint');
        }

        // Show feedback dialog after 1 second
        await Future.delayed(const Duration(seconds: 1));

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Prediction Results & Feedback'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.predictionType == 'word')
                  Text('Word Prediction: $_handGestureOutput'),
                if (widget.predictionType == 'sentence')
                  Text('Sentence Prediction: $_sentencePrediction'),
                Text('Facial Expression Prediction: $_facialExpressionOutput'),
                const SizedBox(height: 20.0),
                const Text('Please provide feedback based on the predictions:'),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Handle feedback rating
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Handle feedback rating
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Handle feedback rating
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Handle feedback rating
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        // Handle feedback rating
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      } catch (e) {
        print("Error recording video: $e");
      } finally {
        setState(() {
          _isRecording = false;
        });
      }
    } else {
      setState(() {
        _isRecording = false;
      });
    }
  }


  void _toggleCamera() {
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Camera Screen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: Row(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _toggleRecording,
                  child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                ),
                const SizedBox(width: 20.0),
                FloatingActionButton(
                  onPressed: _toggleCamera,
                  child: const Icon(Icons.switch_camera),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

