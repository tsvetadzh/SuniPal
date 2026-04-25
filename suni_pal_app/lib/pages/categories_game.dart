import 'dart:math';
import 'package:flutter/material.dart';

class GameItem {
  final String imagePath;
  final String category;
  GameItem(this.imagePath, this.category);
}

class GameCategory {
  final String name;
  final String imagePath;
  GameCategory(this.name, this.imagePath);
}

class CategoriesGame extends StatefulWidget {
  const CategoriesGame({super.key});

  @override
  State<CategoriesGame> createState() => CategoriesGameState();
}

class CategoriesGameState extends State<CategoriesGame> {
  final List<GameItem> allItems = [
    GameItem('assets/images/categories/items/dog_item.png', 'Animals'),
    GameItem('assets/images/categories/items/cat_item.png', 'Animals'),
    GameItem('assets/images/categories/items/hamster_item.png', 'Animals'),
    GameItem('assets/images/categories/items/giraffe_item.png', 'Animals'),
    GameItem('assets/images/categories/items/car_item.png', 'Transport'),
    GameItem('assets/images/categories/items/bus_item.png', 'Transport'),
    GameItem('assets/images/categories/items/bike_item.png', 'Transport'),
    GameItem('assets/images/categories/items/happy_item.png', 'Emotions'),
    GameItem('assets/images/categories/items/sad_item.png', 'Emotions'),
    GameItem('assets/images/categories/items/angry_item.png', 'Emotions'),
    GameItem('assets/images/categories/items/circle_item.png', 'Shapes'),
    GameItem('assets/images/categories/items/triangle_item.png', 'Shapes'),
    GameItem('assets/images/categories/items/square_item.png', 'Shapes'),
    GameItem('assets/images/categories/items/football_item.png', 'Sport'),
    GameItem('assets/images/categories/items/tennis_item.png', 'Sport'),
    GameItem('assets/images/categories/items/swimming_item.png', 'Sport'),
  ];

  final List<GameCategory> categories = [
    GameCategory('Animals', 'assets/images/categories/icons/animals.png'),
    GameCategory('Emotions', 'assets/images/categories/icons/emotions.png'),
    GameCategory('Transport', 'assets/images/categories/icons/transport.png'),
    GameCategory('Shapes', 'assets/images/categories/icons/shapes.png'),
    GameCategory('Sport', 'assets/images/categories/icons/sport.png'),
  ];

  late List<GameItem> items;
  int currentIndex = 0;
  bool answered = false;
  bool correct = false;
  bool finished = false;
  @override
  void initState() {
    super.initState();
    items = List.from(allItems)..shuffle(Random());
  }

  void checkAnswer(String chosenCategory) {
    if (answered) return;
    setState(() {
      answered = true;
      correct = chosenCategory == items[currentIndex].category;
    });
  }

  void tryAgain() {
    setState(() {
      answered = false;
    });
  }

  void nextItem() {
    setState(() {
      if (currentIndex < items.length - 1) {
        currentIndex++;
        answered = false;
      } else {
        finished = true;
      }
    });
  }

  void restart() {
    setState(() {
      currentIndex = 0;
      answered = false;
      finished = false;
      items = List.from(allItems)..shuffle(Random());
    });
  }

  Widget categoryImage(String path, double size) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          Icon(Icons.category, size: size * 0.6, color: Colors.grey),
    );
  }

  Widget itemImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          const Icon(Icons.image, size: 60, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = items[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFDEFAFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDEFAFE),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Sort It!',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: restart),
        ],
      ),
      body: finished
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Well done!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You sorted all the pictures!',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: restart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9DADF),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    ),
                    child: const Text('Play Again', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;

                final catBoxWidth = ((w - 44) / 3).clamp(70.0, 120.0);
                final catBoxHeight = ((h * 0.5 - 70) / 2).clamp(65.0, 115.0);
                final catImgSize = catBoxHeight * 0.48;
                final itemSize = (h * 0.28).clamp(100.0, 160.0);

                return Column(
                  children: [
                    SizedBox(
                      height: h * 0.52,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Drag the picture to the right category!',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          SizedBox(height: h * 0.02),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: categories.map((cat) {
                              return DragTarget<String>(
                                onAcceptWithDetails: (details) => checkAnswer(cat.name),
                                builder: (context, candidateData, rejectedData) {
                                  final isHovering = candidateData.isNotEmpty;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: catBoxWidth,
                                    height: catBoxHeight,
                                    decoration: BoxDecoration(
                                      color: isHovering ? Colors.blue.shade100 : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: isHovering ? Border.all(color: Colors.blue, width: 2) : null,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        categoryImage(cat.imagePath, catImgSize),
                                        const SizedBox(height: 4),
                                        Text(cat.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.48,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (answered) ...[
                            SizedBox(height: h * 0.06),
                            if (correct)
                              const Text(
                                'Correct!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            SizedBox(height: h * 0.06),
                            ElevatedButton(
                              onPressed: correct ? nextItem : tryAgain,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB9DADF),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              child: Text(correct ? 'Next' : 'Try Again'),
                            ),
                          ],
                          Expanded(
                            child: Center(
                              child: answered
                                  ? const SizedBox.shrink()
                                  : Draggable<String>(
                                      data: item.category,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: itemSize,
                                          height: itemSize,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 16)],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: itemImage(item.imagePath),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        width: itemSize,
                                        height: itemSize,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.grey.shade400, width: 2),
                                        ),
                                      ),
                                      child: Container(
                                        width: itemSize,
                                        height: itemSize,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: itemImage(item.imagePath),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
