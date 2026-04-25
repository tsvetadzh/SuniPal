import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _Cmd { above, over, under, toTheLeft, toTheRight }

class RoomGame extends StatefulWidget {
  const RoomGame({super.key});

  @override
  State<RoomGame> createState() => _RoomGameState();
}

class _RoomGameState extends State<RoomGame> {
  static const _text = <_Cmd, String>{
    _Cmd.above:      'Put Suni above the table.',
    _Cmd.over:       'Put Suni on top of the table.',
    _Cmd.under:      'Put Suni under the table.',
    _Cmd.toTheLeft:  'Put Suni to the left of the table.',
    _Cmd.toTheRight: 'Put Suni to the right of the table.',
  };

  static const _sequence = [
    _Cmd.above,
    _Cmd.over,
    _Cmd.under,
    _Cmd.toTheLeft,
    _Cmd.toTheRight,
  ];

  static const double _suniSize = 70;
  static const double _tableW   = 340;
  static const double _tableH   = 220;
  static const double _snap     = 30.0;

  int    _step    = 0;
  bool   _success = false;
  bool   _won     = false;
  double _suniX   = 20;
  double _suniY   = 20;
  Size?  _area;

  _Cmd get _cmd => _sequence[_step];

  Rect _tableRect() {
    final a = _area!;
    return Rect.fromLTWH(
      a.width / 2 - _tableW / 2,
      a.height / 2 - _tableH / 2,
      _tableW,
      _tableH,
    );
  }

  bool _isCorrect(Rect t, Offset c) {
    switch (_cmd) {
      case _Cmd.above:
        return c.dy < t.top - _snap &&
            c.dx > t.left - _suniSize * 0.6 &&
            c.dx < t.right + _suniSize * 0.6;
      case _Cmd.over:
        return t.inflate(_suniSize * 0.35).contains(c);
      case _Cmd.under:
        return c.dy > t.top + t.height * 0.3 &&
            c.dy < t.bottom &&
            c.dx > t.left + t.width * 0.15 &&
            c.dx < t.right - t.width * 0.15;
      case _Cmd.toTheLeft:
        return c.dx < t.left - _snap;
      case _Cmd.toTheRight:
        return c.dx > t.right + _snap;
    }
  }

  void _restart() {
    setState(() {
      _step = 0;
      _success = false;
      _won = false;
      _suniX = 20;
      _suniY = 20;
    });
  }

  void _advance() {
    if (_step < _sequence.length - 1) {
      setState(() {
        _step++;
        _success = false;
        _suniX = 20;
        _suniY = 20;
      });
    } else {
      setState(() => _won = true);
    }
  }

  void _onPanUpdate(DragUpdateDetails e) {
    if (_success || _won) return;
    setState(() {
      _suniX += e.delta.dx;
      _suniY += e.delta.dy;
      if (_area != null) {
        _suniX = _suniX.clamp(0.0, _area!.width - _suniSize);
        _suniY = _suniY.clamp(0.0, _area!.height - _suniSize);
      }
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_success || _won || _area == null) return;
    final center = Offset(_suniX + _suniSize / 2, _suniY + _suniSize / 2);
    if (_isCorrect(_tableRect(), center)) {
      HapticFeedback.heavyImpact();
      setState(() => _success = true);
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) _advance();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String instrText = _won
        ? 'Amazing!'
        : _success
            ? 'Well done!'
            : (_text[_cmd] ?? '');
    final Color instrColor =
        (_success || _won) ? Colors.green.shade600 : Colors.black87;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 250, 254),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 222, 250, 254),
        elevation: 0,
        title: Image.asset(
          'assets/images/page_titles/wheresuni.png',
          height: 90,
          fit: BoxFit.contain,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restart,
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(_won ? 'won' : (_success ? 'ok$_step' : 'q$_step')),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: const Color.fromARGB(255, 222, 250, 254),
              child: Text(
                instrText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: instrColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
          // Step progress dots
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_sequence.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.circle,
                    size: 14,
                    color: i < _step
                        ? Colors.green.shade400
                        : i == _step
                            ? Colors.orange.shade400
                            : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),
          // Play area
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                // Cache the area size so gesture callbacks can use it
                _area = Size(constraints.maxWidth, constraints.maxHeight);
                final table = _tableRect();

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Table (fixed at centre)
                    Positioned(
                      left: table.left,
                      top: table.top,
                      width: table.width,
                      height: table.height,
                      child: Image.asset(
                        'assets/images/characters/table.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Suni
                    Positioned(
                      left: _suniX,
                      top: _suniY,
                      child: GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: AnimatedScale(
                          scale: _success ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Image.asset(
                            'assets/images/characters/suni_table.png',
                            width: _suniSize,
                            height: _suniSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // Win overlay
                    if (_won)
                      Container(
                        color: Colors.white.withValues(alpha: 0.75),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Amazing!',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _restart,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Play Again',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
