import 'dart:math';
import 'package:flutter/material.dart';

class SortingGame extends StatefulWidget {
  const SortingGame({super.key});
  @override
  State<SortingGame> createState() => _SortingGameState();
}

class _SortingGameState extends State<SortingGame> {
  static const int _count = 5;
  late List<int> _order;
  bool _won = false;

  final _rng = Random();
  final _palette = [Colors.red, Colors.blue, Colors.amber, Colors.green, Colors.purple];

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    do {
      _order = List.generate(_count, (i) => i)..shuffle(_rng);
    } while (_isSorted());
    _won = false;
  }

  bool _isSorted() {
    for (int i = 0; i < _order.length - 1; i++) {
      if (_order[i] > _order[i + 1]) return false;
    }
    return true;
  }

  void _swap(int a, int b) {
    setState(() {
      final tmp = _order[a]; _order[a] = _order[b]; _order[b] = tmp;
      if (_isSorted()) _won = true;
    });
  }

  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 250, 254),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 222, 250, 254), elevation: 0,
        title: Image.asset(
          'images/page_titles/sorter.png',
          height: 60,
          ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() { _newRound(); _selected = null; }))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _won ? 'Well done!' : 'Tap two circles to swap them.\nSmallest on the left, biggest on the right.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _won ? Colors.green : Colors.black87),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxCircle = min(constraints.maxWidth / (_count + 1), constraints.maxHeight * 0.6);
                final minCircle = maxCircle * 0.35;
                final step = (maxCircle - minCircle) / (_count - 1);

                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_count, (i) {
                      final rank = _order[i];
                      final size = minCircle + rank * step;
                      final color = _palette[rank % _palette.length];
                      final isSelected = _selected == i;
                      return GestureDetector(
                        onTap: () {
                          if (_won) return;
                          if (_selected == null) {
                            setState(() => _selected = i);
                          } else {
                            if (_selected != i) _swap(_selected!, i);
                            setState(() => _selected = null);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          if (_won)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton(
                onPressed: () => setState(() { _newRound(); _selected = null; }),
                child: const Text('Play Again'),
              ),
            ),
        ],
      ),
    );
  }
}
