import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('Hello', style: TextStyle(color: Colors.red)),
            Image.network('https://i.postimg.cc/vZqRKZGy/height100.png'),
          ],
        ),
      ),
    );
  }
}
