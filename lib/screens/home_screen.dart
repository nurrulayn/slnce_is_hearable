import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silence_is_hearable/global/common/toast.dart';
import 'package:silence_is_hearable/screens/camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent navigation
        return Future.value(false);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.teal.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(
                height: 80,
              ),
              const Text(
                "Let's get started!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 20.0),
              Flexible(
                child: Image.asset(
                  'assets/images/IMG_9790.jpg',
                  height: 300.0,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _onCameraButtonPressed(context, 'word'),
                    child: Text(
                      "Word Prediction",
                      style: TextStyle(color: Colors.teal.shade200),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _onCameraButtonPressed(context, 'sentence'),
                    child: Text(
                      "Sentence Prediction",
                      style: TextStyle(color: Colors.teal.shade200),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCameraButtonPressed(context, String predictionType) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(predictionType: predictionType),
        ),
      );
    } else if (status.isDenied) {
      showToast(message: 'Please allow camera access to proceed with the video recording');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
