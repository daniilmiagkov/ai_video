import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoService {
  VideoPlayerController? controller;

  Future<void> loadVideo(String path) async {
    controller = VideoPlayerController.file(File(path));
    await controller!.initialize();
  }

  void dispose() {
    controller?.dispose();
  }
}
