import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';

class VideoCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraDescription initialCamera;

  const VideoCaptureScreen({
    Key? key,
    required this.cameras,
    required this.initialCamera,
  }) : super(key: key);

  @override
  State<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _videoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initCamera(widget.initialCamera);
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _recordingTimer?.cancel();

      try {
        final XFile videoFile = await _controller.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPath = videoFile.path;
        });

        // Save to gallery
        await _saveToGallery(videoFile.path);
      } catch (e) {
        debugPrint('Error stopping recording: $e');
      }
    } else {
      try {
        await _initializeControllerFuture;

        final Directory appDir = await getTemporaryDirectory();
        final String videoDirectory = '${appDir.path}/Videos';
        await Directory(videoDirectory).create(recursive: true);
        final String filePath =
            '$videoDirectory/${DateTime.now().millisecondsSinceEpoch}.mp4';

        await _controller.startVideoRecording();

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
          _videoPath = null;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  Future<void> _saveToGallery(String path) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Commented out due to package compatibility issues
      // await GallerySaver.saveVideo(path);

      // Instead, we'll just simulate saving
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video captured successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Capture'),
        backgroundColor: DesignSystem.primaryColor,
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: () {
                final currentCameraIndex = widget.cameras.indexOf(
                  _controller.description,
                );
                final newCameraIndex =
                    (currentCameraIndex + 1) % widget.cameras.length;
                _initCamera(widget.cameras[newCameraIndex]);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller),
                      if (_isRecording)
                        Positioned(
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDuration(_recordingDuration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () {
                    if (_isRecording) {
                      _toggleRecording();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  onTap: _isSaving ? null : _toggleRecording,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape:
                          _isRecording ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius:
                          _isRecording ? BorderRadius.circular(16) : null,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      color: _isRecording ? Colors.red : Colors.transparent,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _isRecording
                            ? const Icon(Icons.stop,
                                color: Colors.white, size: 32)
                            : const Icon(Icons.fiber_manual_record,
                                color: Colors.red, size: 32),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  color: _videoPath != null ? Colors.white : Colors.grey,
                  onPressed: _videoPath != null
                      ? () {
                          Navigator.of(context).pop(File(_videoPath!));
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
