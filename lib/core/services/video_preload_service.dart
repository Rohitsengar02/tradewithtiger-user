import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoPreloadService {
  static final VideoPreloadService _instance = VideoPreloadService._internal();
  factory VideoPreloadService() => _instance;
  VideoPreloadService._internal();

  final Map<String, VideoPlayerController> _controllers = {};

  Future<void> preloadVideos(List<String> urls) async {
    for (var url in urls) {
      if (!_controllers.containsKey(url)) {
        try {
          final controller = VideoPlayerController.networkUrl(Uri.parse(url));
          _controllers[url] = controller;
          // We don't initialize here to save hardware decoders.
          // The widget that uses the controller will initialize it on demand.
        } catch (e) {
          debugPrint("Failed to create controller for $url: $e");
        }
      }
    }
  }

  VideoPlayerController? getController(String url) {
    return _controllers[url];
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
