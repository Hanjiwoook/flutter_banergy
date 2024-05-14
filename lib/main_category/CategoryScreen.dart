import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Center(
        child: Text('여기는 $categoryName 화면입니다'),
      ),
    );
  }
}
