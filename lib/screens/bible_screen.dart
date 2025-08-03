import 'package:flutter/material.dart';
import '../widgets/bible_reader.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(
        title: Text('Bíblia NVI'),
        centerTitle: true,
      ),
      body: BibleReader(),
    );
  }
}