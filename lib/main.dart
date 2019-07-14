import 'package:flutter/material.dart';
import 'package:quake_improved/pages/quake_map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terremoto 2.0',
      home: QuakeMap(),
    );
  }
}
