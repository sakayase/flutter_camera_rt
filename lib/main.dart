import 'package:flutter/material.dart';
import 'package:flutter_camera_rt/camera_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: CameraScreen(),
      ),
    );
  }

  List<TextSpan> buildReversedAsciiArt(String asciiArt) {
    List<TextSpan> list = [];
    for (var i = asciiArt.length - 1; i >= 0; i--) {
      list.add(TextSpan(text: asciiArt[i]));
    }
    return list;
  }
}

Size calcTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaleFactor: 1,
    textWidthBasis: TextWidthBasis.parent,
  )..layout();
  return textPainter.size;
}

final double textWidth = calcTextSize(
  ' ',
  const TextStyle(
    fontSize: 5,
    fontFamily: 'Roboto',
  ),
).width;
final double textHeight = calcTextSize(
  ' ',
  const TextStyle(
    fontSize: 5,
    fontFamily: 'Roboto',
  ),
).height;
