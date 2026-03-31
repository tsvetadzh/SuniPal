import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({
    super.key,
    required this.selectedSound,
  });

  final String selectedSound;

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _player;

  bool _isLoading = true;
  String? _errorMessage;

  static const Map<String, SongItem> songsBySound = {
    'xylophone': SongItem(
      title: 'Xylophone',
      assetPath: 'assets/audio/xylophone.mp3',
    ),
    'guitar': SongItem(
      title: 'Guitar',
      assetPath: 'assets/audio/guitar.mp3',
    ),
    'piano': SongItem(
      title: 'Piano',
      assetPath: 'assets/audio/piano.mp3',
    ),
    'violin': SongItem(
      title: 'Violin',
      assetPath: 'assets/audio/cello.mp3',
    ),
  };

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _loadSelectedSong();
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSong = songsBySound[widget.selectedSound];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedSound),
        backgroundColor: const Color.fromARGB(255, 222, 250, 254),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          children: [
            Align(
              alignment: const Alignment(0, -0.35),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(320, 320),
                    painter: CirclePainter(_controller.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (selectedSong != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      selectedSong.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    _buildProgressBar(),
                    const SizedBox(height: 20),
                    _buildControls(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSelectedSong() async {
    final selectedSong = songsBySound[widget.selectedSound];

    if (selectedSong == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No audio has been configured for this sound yet.';
      });
      return;
    }

    try {
      await _player.setLoopMode(LoopMode.one);
      await _player.setAsset(selectedSong.assetPath);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Add ${selectedSong.assetPath} to play this sound inside the app.';
      });
    }
  }

  Widget _buildStatus(SongItem selectedSong) {
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Preparing audio...'),
        ],
      );
    }

    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text(
      'Ready to play ${selectedSong.title.toLowerCase()}.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration?>(
      stream: _player.durationStream,
      builder: (context, durationSnapshot) {
        final total = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final maxSeconds = total.inMilliseconds > 0
                ? total.inMilliseconds / 1000
                : 1.0;
            final currentSeconds = position.inMilliseconds > 0
                ? position.inMilliseconds / 1000
                : 0.0;

            return Column(
              children: [
                Slider(
                  value: currentSeconds.clamp(0.0, maxSeconds),
                  max: maxSeconds,
                  onChanged: (_isLoading || _errorMessage != null)
                      ? null
                      : (value) async {
                          await _player.seek(
                            Duration(milliseconds: (value * 1000).round()),
                          );
                        },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(total)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildControls() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final isReady = !_isLoading && _errorMessage == null;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: isReady ? _restart : null,
              icon: const Icon(Icons.replay),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: isReady ? (isPlaying ? _pause : _play) : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
              ),
              child: Text(isPlaying ? 'Pause' : 'Play'),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: isReady ? _stop : null,
              icon: const Icon(Icons.stop),
            ),
          ],
        );
      },
    );
  }

  Future<void> _play() async {
    await _player.play();
  }

  Future<void> _pause() async {
    await _player.pause();
  }

  Future<void> _stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
  }

  Future<void> _restart() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class SongItem {
  const SongItem({
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;
}

class CirclePainter extends CustomPainter {
  const CirclePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final pulse = 1 + (0.05 * sin(value * 2 * pi));
    final outerRotation = value * 2 * pi;
    final middleRotation = -value * 2.6 * pi;
    final innerRotation = value * 3.2 * pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(pulse);

    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(255, 65, 62, 221),
          Color.fromARGB(255, 16, 122, 172),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 150))
      ..style = PaintingStyle.fill;

    final middlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(220, 139, 146, 204),
          Color.fromARGB(220, 141, 153, 234),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 105))
      ..style = PaintingStyle.fill;

    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(255, 156, 215, 236),
          Color.fromARGB(255, 166, 212, 228),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 70))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.rotate(outerRotation);
    canvas.drawCircle(Offset.zero, 130, outerPaint);
    _paintOrbit(
      canvas,
      radius: 130,
      orbitRadius: 112,
      dotRadius: 14,
      dotColor: const Color.fromARGB(170, 255, 255, 255),
      trailColor: const Color.fromARGB(120, 224, 248, 255),
    );
    canvas.restore();

    canvas.save();
    canvas.rotate(middleRotation);
    canvas.drawCircle(Offset.zero, 92, middlePaint);
    _paintOrbit(
      canvas,
      radius: 92,
      orbitRadius: 76,
      dotRadius: 11,
      dotColor: const Color.fromARGB(150, 248, 250, 255),
      trailColor: const Color.fromARGB(100, 210, 227, 255),
    );
    canvas.restore();

    canvas.save();
    canvas.rotate(innerRotation);
    canvas.drawCircle(Offset.zero, 58, innerPaint);
    _paintOrbit(
      canvas,
      radius: 58,
      orbitRadius: 44,
      dotRadius: 8,
      dotColor: const Color.fromARGB(170, 255, 255, 255),
      trailColor: const Color.fromARGB(90, 206, 244, 255),
    );
    canvas.restore();

    canvas.restore();
  }

  void _paintOrbit(
    Canvas canvas, {
    required double radius,
    required double orbitRadius,
    required double dotRadius,
    required Color dotColor,
    required Color trailColor,
  }) {
    final trailPaint = Paint()
      ..color = trailColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dotRadius * 0.9;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: orbitRadius),
      -0.8,
      1.25,
      false,
      trailPaint,
    );

    canvas.drawCircle(
      Offset(cos(0.25) * orbitRadius, sin(0.25) * orbitRadius),
      dotRadius,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(cos(pi + 0.6) * orbitRadius, sin(pi + 0.6) * orbitRadius),
      dotRadius * 0.55,
      dotPaint..color = dotColor.withAlpha(110),
    );

    final ringPaint = Paint()
      ..color = const Color.fromARGB(255, 226, 174, 231).withAlpha(36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}