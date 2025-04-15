import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoKey;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoKey,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  bool _showCaptions = false;
  bool _isPlaying = true;
  bool _isReady = false;
  Duration _position = Duration.zero;
  Orientation? _initialOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialOrientation = MediaQuery.of(context).orientation;
    });
    _initializeController();
  }

  Future<void> _restoreOrientation() async {
    if (_initialOrientation == Orientation.portrait) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else if (_initialOrientation == Orientation.landscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: _showCaptions,
        showLiveFullscreenButton: true,
        captionLanguage: 'en',
        forceHD: true,
      ),
    )..addListener(_controllerListener);
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        _position = _controller.value.position;
      });
    }
  }

  void _toggleOrientation() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _togglePlayPause() {
    if (!_isReady) return;
    
    if (_isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleCaptions() {
    if (!_isReady) return;
    
    setState(() {
      _showCaptions = !_showCaptions;
    });
    
    // Store current position and playing state
    final currentPosition = _controller.value.position;
    final wasPlaying = _controller.value.isPlaying;
    
    // Dispose old controller
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    
    // Create new controller with updated caption settings
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: YoutubePlayerFlags(
        autoPlay: wasPlaying,
        mute: false,
        enableCaption: _showCaptions,
        showLiveFullscreenButton: true,
        captionLanguage: 'en',
        forceHD: true,
        startAt: currentPosition.inSeconds,
      ),
    )..addListener(_controllerListener);
  }

  void _seekTo(Duration position) {
    if (!_isReady) return;
    _controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _controller.toggleFullScreenMode();
          return false;
        }
        await _restoreOrientation();
        return true;
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: orientation == Orientation.portrait
                ? AppBar(
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () async {
                        await _restoreOrientation();
                        if (mounted) Navigator.of(context).pop();
                      },
                    ),
                    title: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : null,
            body: SafeArea(
              child: YoutubePlayerBuilder(
                onEnterFullScreen: () {
                  setState(() {
                    _isFullScreen = true;
                  });
                },
                onExitFullScreen: () {
                  setState(() {
                    _isFullScreen = false;
                  });
                },
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Theme.of(context).colorScheme.primary,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                  onReady: () {
                    setState(() {
                      _isReady = true;
                      _isPlaying = _controller.value.isPlaying;
                    });
                    debugPrint('Player is ready.');
                  },
                  onEnded: (data) async {
                    await _restoreOrientation();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                builder: (context, player) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          player,
                          if (orientation == Orientation.portrait) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _seekTo(
                                      Duration(
                                        seconds: _position.inSeconds - 10,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: _togglePlayPause,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _seekTo(
                                      Duration(
                                        seconds: _position.inSeconds + 10,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _showCaptions ? Icons.closed_caption : Icons.closed_caption_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleCaptions,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      orientation == Orientation.portrait
                                          ? Icons.screen_rotation
                                          : Icons.screen_lock_rotation,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleOrientation,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (!_isReady)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    _restoreOrientation();
    super.dispose();
  }
} 