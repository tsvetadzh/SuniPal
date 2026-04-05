import 'package:flutter/material.dart';
import 'package:suni_pal_app/pages/songs.dart';

class SoundsGame extends StatefulWidget {
  const SoundsGame({super.key});

  @override
  State<SoundsGame> createState() => _SoundsGameState();
}

class _SoundsGameState extends State<SoundsGame> {
  final List<({String image, String soundKey})> soundOptions = const [
    (image: 'assets/images/banners/xylophone.png', soundKey: 'xylophone'),
    (image: 'assets/images/banners/guitar.png', soundKey: 'guitar'),
    (image: 'assets/images/banners/piano.png', soundKey: 'piano'),
    (image: 'assets/images/banners/violin.png', soundKey: 'violin'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 600 ? 20.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sounds'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(soundOptions.length, (index) {
                  final option = soundOptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongsPage(
                              selectedSound: option.soundKey,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 5,
                          child: Image.asset(
                            option.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
