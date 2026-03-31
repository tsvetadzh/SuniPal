import 'package:flutter/material.dart';
import 'package:suni_pal_app/pages/dots_game.dart';
import 'package:suni_pal_app/pages/puzzle_game.dart';
import 'package:suni_pal_app/pages/sorting_game.dart';
import 'package:suni_pal_app/pages/sounds_game.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final horizontalPadding = screenSize.width < 600 ? 20.0 : 32.0;
    final bannerSpacing = screenHeight * 0.05;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 170,
        leading: Image.asset(
            'images/sunipal_logo.png', 
            fit: BoxFit.contain
          ),
        
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBanner(
                      context: context,
                      imagePath: 'assets/images/banners/sounds.png',
                      destination: SoundsGame(),
                    ),
                    SizedBox(height: bannerSpacing),
                    _buildBanner(
                      context: context,
                      imagePath: 'assets/images/banners/dots.png',
                      destination: DotsGame(),
                    ),
                    SizedBox(height: bannerSpacing),
                    _buildBanner(
                      context: context,
                      imagePath: 'assets/images/banners/puzzle.png',
                      destination: PuzzleGame(),
                    ),
                    SizedBox(height: bannerSpacing),
                    _buildBanner(
                      context: context,
                      imagePath: 'assets/images/banners/sorter.png',
                      destination: SortingGame(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner({
    required BuildContext context,
    required String imagePath,
    required Widget destination,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(60),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(60),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
