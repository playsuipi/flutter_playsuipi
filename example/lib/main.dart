import 'package:flutter/material.dart';

import 'package:flutter_playsuipi/core.dart';

const suits = ['♣', '♦', '♥', '♠'];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GameRef gameRef;

  String floorDisplay = '';
  String handDisplay = '';

  @override
  void initState() {
    super.initState();
    final seed = List<int>.generate(32, (i) => 0);
    gameRef = Core.newGame(seed);
    getGameState();
  }

  @override
  void dispose() {
    super.dispose();
    Core.freeGame(gameRef);
  }

  void getGameState() {
    final floor = Core.readFloor(gameRef);
    List<String> floorValues = [];
    for (final pile in floor) {
      String mark = '';
      switch (pile.mark) {
        case Mark.empty:
          continue;
        case Mark.group:
          mark = 'G';
          break;
        case Mark.build:
          mark = 'B';
          break;
        default:
          break;
      }
      floorValues.add('$mark${pile.value}');
    }
    final hands = Core.readHands(gameRef);
    final handValues = hands.map((card) => '${suits[card.suit]}${card.value}');
    setState(() {
      floorDisplay = floorValues.join(', ');
      handDisplay = handValues.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Play Suipi')),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'FLOOR:  $floorDisplay',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'HAND:  $handDisplay',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
