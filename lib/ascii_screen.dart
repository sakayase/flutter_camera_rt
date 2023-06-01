import 'package:flutter/material.dart';

class AsciiScreen extends StatelessWidget {
  const AsciiScreen({super.key, required this.asciiStream});
  final Stream<String> asciiStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withAlpha(150),
      child: StreamBuilder<String>(
        stream: asciiStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RichText(
              textScaleFactor: 1,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 5,
                  fontFamily: 'Roboto',
                ),
                children: buildReversedAsciiArt(snapshot.data!),
              ),
            );
          }
          return SizedBox.shrink();
        },
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
