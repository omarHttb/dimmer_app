import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class Dimpage extends StatefulWidget {
  const Dimpage({super.key});

  @override
  State<Dimpage> createState() => _DimpageState();
}

class _DimpageState extends State<Dimpage> {
  @override
  void initState() {
    super.initState();
    _getSystemBrightness();
  }

  static const platform =
      MethodChannel('com.example.dimmer_app/OverlayService');

  Future<void> _startOverlay() async {
    if (await Permission.systemAlertWindow.isGranted) {
      // Check permission
      try {
        await platform.invokeMethod('startOverlay');
      } on PlatformException catch (e) {
        print("Error starting overlay: '${e.message}'.");
      }
    } else {
      await Permission.systemAlertWindow.request(); // Request permission
      if (await Permission.systemAlertWindow.isGranted) {
        try {
          await platform.invokeMethod('startOverlay');
        } on PlatformException catch (e) {
          print("Error starting overlay: '${e.message}'.");
        }
      }
    }
  }

  Future<void> _stopOverlay() async {
    try {
      await platform.invokeMethod('stopOverlay');
    } on PlatformException catch (e) {
      print("Error stopping overlay: '${e.message}'.");
    }
  }

  Future<void> _getSystemBrightness() async {
    try {
      _brightness = await ScreenBrightness().system;
    } catch (e) {
      print("Failed to get system brightness: $e");
    }
  }

  double _opacity = 0.5;

  double _brightness = 0.0;

  Future<void> _requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }

  Future<void> _showOverlay() async {
    // Check if the permission is granted
    if (await Permission.systemAlertWindow.isGranted) {
      // Ensure the widget is still mounted before proceeding
      if (!context.mounted) {
        return; // Exit if the widget is no longer mounted
      }

      // Create the overlay entry
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            color: Colors.black.withOpacity(_opacity),
          ),
        ),
      );

      // Insert the overlay entry
      Overlay.of(context).insert(overlayEntry);
    } else {
      print("Overlay permission not granted");
    }
  }

  Future<void> _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setSystemScreenBrightness(brightness);
      setState(() {
        _brightness = brightness;
      });
    } catch (e) {
      print("Error setting brightness: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("screen Dimmer"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                min: 0.0, // Minimum brightness
                max: 1.0, // Maximum brightness
                value: _brightness,
                onChanged: (value) {
                  _setBrightness(value);
                },
              ),
              Text("Brightness: ${(_brightness * 100).toInt()}%"),
              const Text(
                "Opacity",
              ),
              Slider(
                value: _opacity,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _opacity = value;
                  });
                },
              ),
              Text(
                'Opacity: ${(_opacity * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: _requestOverlayPermission,
                child: const Text('Request Overlay Permission'),
              ),
              ElevatedButton(
                onPressed: _showOverlay,
                child: const Text('Show Dimming Overlay'),
              ),
              ElevatedButton(
                onPressed: _startOverlay,
                child: const Text('start overlay'),
              ),
              ElevatedButton(
                onPressed: _stopOverlay,
                child: const Text('Stop overlay'),
              ),
            ],
          ),
        ));
  }
}
