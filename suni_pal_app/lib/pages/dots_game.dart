import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dot {
  final String id;
  double x, y, size;
  Color color;
  Dot({
    required this.id, required this.x, required this.y, required this.size, required this.color
    });
}

enum _Step {
   tapCenter1, tapCenter2, rubLeft, rubRight, tapYellow, tapRed, tapBlue, scatter, freePlay 
  }

class DotsGame extends StatefulWidget {
  const DotsGame({super.key});
  @override
  State<DotsGame> createState() => _DotsGameState();
}

class _DotsGameState extends State<DotsGame> with SingleTickerProviderStateMixin {
  final List<Dot> dots = [];
  final _rng = Random();
  int _idCounter = 0, _tapCount = 0, _rubCount = 0;
  _Step _step = _Step.tapCenter1;
  String _centerId = '', _leftId = '', _rightId = '';
  late AnimationController _scatterCtrl;
  List<Offset>? _targets;

  static const double _size = 70, _gap = 80;

  static const _text = {
    _Step.tapCenter1: 'Press the dot.',
    _Step.tapCenter2: 'Press it again.',
    _Step.rubLeft: 'Rub the left dot.',
    _Step.rubRight: 'Now rub the right dot.',
    _Step.tapYellow: 'Tap the yellow dot 5 times.',
    _Step.tapRed: 'Tap the red dot 5 times.',
    _Step.tapBlue: 'Tap the blue dot 5 times.',
    _Step.scatter: 'Now shake it!\nTap the screen to scatter the dots.',
    _Step.freePlay: 'Move the dots around!',
  };

  double get _cx => MediaQuery.of(context).size.width / 2 - _size / 2;
  double get _cy => (MediaQuery.of(context).size.height - 200) / 2 - _size / 2;

  @override
  void initState() {
    super.initState();
    _scatterCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600)
      )
      ..addListener(() => setState(() {}))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && _targets != null) {
          setState(() {
            for (int i = 0; i < dots.length && i < _targets!.length; i++) {
              dots[i].x = _targets![i].dx;
              dots[i].y = _targets![i].dy;
            }
            _targets = null;
            _step = _Step.freePlay;
          });
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _restart());
  }

  @override
  void dispose() { _scatterCtrl.dispose(); super.dispose(); }

  void _restart() {
    setState(() {
      dots.clear(); _idCounter = 0; _tapCount = 0; _rubCount = 0;
      _step = _Step.tapCenter1; _targets = null;
      _centerId = '${_idCounter++}'; _leftId = ''; _rightId = '';
      dots.add(Dot(id: _centerId, x: _cx, y: _cy, size: _size, color: Colors.amber));
    });
  }

  Dot newDot(double x, double y, Color c) =>
      Dot(id: '${_idCounter++}', x: x, y: y, size: _size, color: c);

  void addColumn(double x, Color c, int n) {
    final startY = _cy - (n - 1) * _gap / 2;
    for (int i = 0; i < n; i++) {
      dots.add(newDot(x, startY + i * _gap, c));
    }
  }

  void bounce(Dot d) {
    d.size = _size + 8;
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => d.size = _size);
    });
  }

  void onTap(Dot d) {
    HapticFeedback.selectionClick();
    switch (_step) {
      case _Step.tapCenter1:
        if (d.id != _centerId) return;
        _leftId = '${_idCounter++}';
        setState(() { dots.add(Dot(
          id: _leftId, 
          x: _cx - _size - 40, 
          y: _cy, 
          size: _size, 
          color: Colors.amber
          )); _step = _Step.tapCenter2; });

      case _Step.tapCenter2:
        if (d.id != _centerId) return;
        _rightId = '${_idCounter++}';
        setState(() { dots.add(Dot(
          id: _rightId, 
          x: _cx + _size + 40, 
          y: _cy, size: _size, 
          color: Colors.amber
          )); _step = _Step.rubLeft; });

      case _Step.tapYellow:
        if (d.id != _centerId) return;
        _tapCount++; bounce(d);
        if (_tapCount >= 5) setState(() { dots.removeWhere((d) => d.id == _centerId); addColumn(_cx, Colors.amber, 5); _tapCount = 0; _step = _Step.tapRed; });

      case _Step.tapRed:
        if (d.color != Colors.red) return;
        _tapCount++; bounce(d);
        if (_tapCount >= 5) setState(() { dots.removeWhere((d) => d.id == _leftId); addColumn(_cx - _size - 40, Colors.red, 5); _tapCount = 0; _step = _Step.tapBlue; });

      case _Step.tapBlue:
        if (d.color != Colors.blue) return;
        _tapCount++; bounce(d);
        if (_tapCount >= 5) setState(() { dots.removeWhere((d) => d.id == _rightId); addColumn(_cx + _size + 40, Colors.blue, 5); _tapCount = 0; _step = _Step.scatter; });

      default: break;
    }
  }

  void _onDrag(Dot d, DragUpdateDetails e) {
    if (_step == _Step.rubLeft && d.id == _leftId) {
      _rubCount++;
      if (_rubCount % 4 == 0) { HapticFeedback.selectionClick(); setState(() => d.color = Color.lerp(d.color, Colors.red, 0.3)!); }
      if (_rubCount >= 20) setState(() { d.color = Colors.red; _rubCount = 0; _step = _Step.rubRight; });
    } else if (_step == _Step.rubRight && d.id == _rightId) {
      _rubCount++;
      if (_rubCount % 4 == 0) { HapticFeedback.selectionClick(); setState(() => d.color = Color.lerp(d.color, Colors.blue, 0.3)!); }
      if (_rubCount >= 20) setState(() { d.color = Colors.blue; _rubCount = 0; _step = _Step.tapYellow; });
    } else if (_step == _Step.freePlay) {
      setState(() { d.x += e.delta.dx; d.y += e.delta.dy; });
    }
  }

  void _scatter() {
    if (_step != _Step.scatter) return;
    HapticFeedback.heavyImpact();
    final s = MediaQuery.of(context).size;
    final m = _size + 10;
    _targets = dots.map((_) => Offset(m / 2 + _rng.nextDouble() * (s.width - m), m / 2 + _rng.nextDouble() * (s.height - 250 - m))).toList();
    _scatterCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 250, 254),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 222, 250, 254), elevation: 0,
        title: Image.asset(
            'images/page_titles/dots_title.png',
            height: 40,
          ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _restart, tooltip: 'Start Over')],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(_step), width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: const Color.fromARGB(255, 222, 250, 254),
              child: Text(_text[_step] ?? '', textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _scatter, behavior: HitTestBehavior.translucent,
              child: Stack(clipBehavior: Clip.none, children: [for (int i = 0; i < dots.length; i++) _dotWidget(i)]),
            ),
          ),
          if (_step == _Step.tapYellow || _step == _Step.tapRed || _step == _Step.tapBlue)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.circle, size: 16, color: i < _tapCount ? Colors.black87 : Colors.grey.shade300)))),
            ),
        ],
      ),
    );
  }

  Widget _dotWidget(int i) {
    final d = dots[i];
    double x = d.x, y = d.y;
    if (_targets != null && i < _targets!.length) {
      final t = Curves.easeOutCubic.transform(_scatterCtrl.value);
      x = d.x + (_targets![i].dx - d.x) * t;
      y = d.y + (_targets![i].dy - d.y) * t;
    }
    return Positioned(left: x, top: y, child: GestureDetector(
      onTap: () => onTap(d), onPanUpdate: (e) => _onDrag(d, e),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: d.size, height: d.size,
        decoration: BoxDecoration(color: d.color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: d.color.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)])),
    ));
  }
}