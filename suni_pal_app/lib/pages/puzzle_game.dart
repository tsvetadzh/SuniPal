import 'package:flutter/material.dart';
import 'dart:math';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {  
  static const int totalPuzzles = 5;
  static const int gridSize = 3;

  late List<int> tiles;
  int _currentPuzzle = 1;
  bool _isSolved = false;

  final Random _random = Random();


  @override
  void initState(){
    super.initState();
    initPuzzle();
  }

  void initPuzzle(){
    _isSolved = false;

    tiles = List.generate(gridSize * gridSize, (index) {
      if (index == gridSize * gridSize - 1) return 0;
      return index + 1;
    });
    shuffle();
  }

  void shuffle(){

    for (int i = 0; i < 30; i++){
      List<int> movableTiles = [];

      for (int j = 0; j < tiles.length; j++){
        if (canMove(j)) {
          movableTiles.add(j);
        }
      }

      int moveIndex = movableTiles[_random.nextInt(movableTiles.length)];
      moveTile(moveIndex, notify: false);
    }
    setState(() {});
  }

  bool canMove(int index){
    int emptyIndex = tiles.indexOf(0);

    int row = index ~/ gridSize;
    int col = index % gridSize;

    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    return (row == emptyRow && (col - emptyCol).abs() == 1) || (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void moveTile(int index, {bool notify = true}){
    if (!canMove(index)) return;

    int emptyIndex = tiles.indexOf(0);
    tiles[emptyIndex] = tiles[index];
    tiles[index] = 0;

    if (notify) {
      setState(() {});

      if (isSolved()) {
        setState(() {
          _isSolved = true;
        });
      }
    }
  }

  bool isSolved(){
    for (int i = 0; i < tiles.length -1; i++){
      if (tiles[i] != i + 1){
        return false;
      }
    }
    return tiles.last == 0;
  }

  void nextPuzzle(){
    int newPuzzle;
    do {
      newPuzzle = _random.nextInt(totalPuzzles) + 1;
    } while (newPuzzle == _currentPuzzle);

    _currentPuzzle = newPuzzle;
    initPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/page_titles/puzzle.png',
          height: 60,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                initPuzzle(); 
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Flexible(
                flex: 2,
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: tiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                final tile = tiles[index];

                return GestureDetector(
                  onTap: () => moveTile(index),
                  child: tile == 0
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/puzzles/puz${_currentPuzzle}_$tile.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                );
              },
                ),
              ),
              const SizedBox(height: 16),
              if (_isSolved)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        nextPuzzle();
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
        
    );
  }
}