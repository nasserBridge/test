import 'package:bridgeapp/src/utils/scale.dart';
import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  final String content;
  final String title;

  const DocumentScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Scale.x(16.0)),
        child: Text(content),
      ),
    );
  }
}
