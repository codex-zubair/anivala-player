import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../core/formatters.dart';
import '../core/media_item.dart';
import '../state/library_state.dart';
import '../theme/app_theme.dart';

/// Fullscreen local player with gesture controls and automatic resume.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.item, this.startAt});

  final MediaItem item;
  final Duration? startAt;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  Timer? _saveTimer;
  bool _landscape = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initialise();
  }

  Future<void> _initialise() async {
    try {
      final File file = File(widget.item.path);
      if (!await file.exists()) {
        setState(() => _error = 'File not found or no longer accessible.');
        return;
      }
      final VideoPlayerController controller =
          VideoPlayerController.file(file);
      await controller.initialize();
      _controller = controller;

      final Duration? resume = widget.startAt;
      if (resume != null &&
          resume.inSeconds > 5 &&
          resume < controller.value.duration) {
        await controller.seekTo(resume);
      }
      await controller.play();
      controller.addListener(_onTick);
      _scheduleHide();
      _startAutoSave();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not play this file.');
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  /// Persists progress every 10 seconds while playing, so Continue Watching is
  /// always up to date even if the app is killed.
  void _startAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (_controller?.value.isPlaying ?? false) {
        _savePosition();
      }
    });
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  Future<void> _savePosition() async {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await context.read<LibraryState>().recordProgress(
          item: widget.item,
          position: c.value.position,
          duration: c.value.duration,
        );
  }

  Future<void> _exit() async {
    await _savePosition();
    if (mounted) Navigator.of(context).pop();
  }

  void _togglePlay() {
    final VideoPlayerController? c = _controller;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _savePosition();
      } else {
        c.play();
        _scheduleHide();
      }
    });
  }

  void _seekBy(int seconds) {
    final VideoPlayerController? c = _controller;
    if (c == null) return;
    Duration target = c.value.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > c.value.duration) target = c.value.duration;
    c.seekTo(target);
    _scheduleHide();
  }

  void _toggleOrientation() {
    setState(() => _landscape = !_landscape);
    SystemChrome.setPreferredOrientations(
      _landscape
          ? <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (_error != null)
              _ErrorView(message: _error!, onBack: _exit)
            else if (!_ready)
              const Center(child: CircularProgressIndicator(color: AppTheme.accent2))
            else
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            if (_ready) _videoKeyHandler(),
            if (_ready && _controlsVisible) _overlay(),
          ],
        ),
      ),
    );
  }

  Widget _videoKeyHandler() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleControls,
        onDoubleTapDown: (TapDownDetails d) {
          final double w = MediaQuery.of(context).size.width;
          if (d.localPosition.dx < w / 2) {
            _seekBy(-10);
          } else {
            _seekBy(10);
          }
        },
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _overlay() {
    final VideoPlayerController c = _controller!;
    final Duration pos = c.value.position;
    final Duration total = c.value.duration;
    final double progress = total.inMilliseconds == 0
        ? 0
        : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.75),
          ],
          stops: const <double>[0, 0.45, 1],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: _exit,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    widget.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleOrientation,
                  icon: Icon(
                    _landscape
                        ? Icons.screen_lock_portrait_rounded
                        : Icons.screen_rotation_rounded,
                  ),
                  tooltip: 'Rotate',
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 40,
                  onPressed: () => _seekBy(-10),
                  icon: const Icon(Icons.replay_10_rounded),
                  tooltip: 'Back 10s',
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 64,
                  onPressed: _togglePlay,
                  icon: Icon(
                    c.value.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                  tooltip: c.value.isPlaying ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 40,
                  onPressed: () => _seekBy(10),
                  icon: const Icon(Icons.forward_10_rounded),
                  tooltip: 'Forward 10s',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Text(Formatters.duration(pos),
                      style: const TextStyle(fontSize: 12.5)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        activeTrackColor: AppTheme.accent2,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppTheme.accent2,
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (double v) {
                          final Duration target = Duration(
                            milliseconds:
                                (total.inMilliseconds * v).round(),
                          );
                          c.seekTo(target);
                          _scheduleHide();
                        },
                      ),
                    ),
                  ),
                  Text(Formatters.duration(total),
                      style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.warm),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onBack, child: const Text('Go back')),
        ],
      ),
    );
  }
}
