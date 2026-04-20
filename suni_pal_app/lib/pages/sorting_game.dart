import 'dart:math';
import 'package:flutter/material.dart';

enum ShapeType { circle, square, triangle }

const shapeNames = ['circles', 'squares', 'triangles'];

class SortingGame extends StatefulWidget {
  const SortingGame({super.key});
  @override
  State<SortingGame> createState() => SortingGameState();
}

class SortingGameState extends State<SortingGame> {
  static const int count = 5;
  late List<int> order;
  bool won = false;
  int shapeIndex = 0;

  final rng = Random();
  final palette = [Colors.red, Colors.blue, Colors.amber, Colors.green, Colors.purple];

  @override
  void initState() {
    super.initState();
    newRound();
  }

  void newRound() {
    do {
      order = List.generate(count, (i) => i)..shuffle(rng);
    } while (isSorted());
    won = false;
  }

  bool isSorted() {
    for (int i = 0; i < order.length - 1; i++) {
      if (order[i] > order[i + 1]) return false;
    }
    return true;
  }

  void swap(int a, int b) {
    setState(() {
      final tmp = order[a]; order[a] = order[b]; order[b] = tmp;
      if (isSorted()) won = true;
    });
  }

  int? selected;

  bool get allDone => won && shapeIndex >= ShapeType.values.length - 1;

  void nextShape() {
    setState(() {
      shapeIndex++;
      selected = null;
      newRound();
    });
  }

  void restart() {
    setState(() {
      shapeIndex = 0;
      selected = null;
      newRound();
    });
  }

  Widget buildShape(int index, double size, Color color, bool isSelected) {
    final key = ValueKey('$shapeIndex-$index');
    switch (ShapeType.values[shapeIndex]) {
      case ShapeType.circle:
        return AnimatedContainer(
          key: key,
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
          ),
        );
      case ShapeType.square:
        return AnimatedContainer(
          key: key,
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
          ),
        );
      case ShapeType.triangle:
        return AnimatedContainer(
          key: key,
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          child: CustomPaint(
            painter: TrianglePainter(color, isSelected),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shapeName = shapeNames[shapeIndex];

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 250, 254),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 222, 250, 254), elevation: 0,
        title: Image.asset(
          'assets/images/page_titles/sorter.png',
          height: 60,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: restart)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              won
                  ? 'Well done! You sorted the $shapeName!'
                  : 'Tap two $shapeName to swap them.\nSmallest on the left, biggest on the right.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxCircle = min(constraints.maxWidth / (count + 1), constraints.maxHeight * 0.6);
                final minCircle = maxCircle * 0.35;
                final step = (maxCircle - minCircle) / (count - 1);

                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(count, (i) {
                      final rank = order[i];
                      final size = minCircle + rank * step;
                      final color = palette[rank % palette.length];
                      final isSelected = selected == i;
                      return GestureDetector(
                        onTap: () {
                          if (won) return;
                          if (selected == null) {
                            setState(() => selected = i);
                          } else {
                            if (selected != i) swap(selected!, i);
                            setState(() => selected = null);
                          }
                        },
                        child: buildShape(i, size, color, isSelected),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          if (won)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: allDone
                  ? ElevatedButton(
                      onPressed: restart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 185, 218, 223),
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Play Again'),
                    )
                  : ElevatedButton(
                      onPressed: nextShape,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 185, 218, 223),
                        foregroundColor: Colors.black87,
                      ),
                      child: Text('${shapeNames[shapeIndex + 1][0].toUpperCase()}${shapeNames[shapeIndex + 1].substring(1)}'),
                    ),
            ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  TrianglePainter(this.color, this.isSelected);

  Path trianglePath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.18;

    final v0 = Offset(w / 2, 0);
    final v1 = Offset(w, h);
    final v2 = Offset(0, h);

    Offset towards(Offset from, Offset to) {
      final d = to - from;
      return from + d / d.distance * r;
    }

    return Path()
      ..moveTo(towards(v0, v2).dx, towards(v0, v2).dy)
      ..quadraticBezierTo(v0.dx, v0.dy, towards(v0, v1).dx, towards(v0, v1).dy)
      ..lineTo(towards(v1, v0).dx, towards(v1, v0).dy)
      ..quadraticBezierTo(v1.dx, v1.dy, towards(v1, v2).dx, towards(v1, v2).dy)
      ..lineTo(towards(v2, v1).dx, towards(v2, v1).dy)
      ..quadraticBezierTo(v2.dx, v2.dy, towards(v2, v0).dx, towards(v2, v0).dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = trianglePath(size);
    canvas.drawShadow(path, color.withValues(alpha: 0.4), 8, false);
    canvas.drawPath(path, Paint()..color = color);
    if (isSelected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(TrianglePainter old) => old.color != color || old.isSelected != isSelected;
}
