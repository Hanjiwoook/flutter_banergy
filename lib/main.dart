import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_banergy/bottombar.dart';
import 'package:flutter_banergy/appbar/search_Widget.dart';
import 'package:flutter_banergy/main_category/IconSlider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_banergy/mainDB.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MainpageApp(),
    ),
  );
}

class MainpageApp extends StatelessWidget {
  final File? image;

  const MainpageApp({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '식품 알레르기 관리 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 50, 160, 107),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Flexible(
            child: SearchWidget(), // Flexible 추가
          ),
        ],
      ),
      body: const Column(
        children: [
          // 여기에 아이콘 슬라이드를 넣어줍니다.
          IconSlider(),
          SizedBox(height: 16),
          Expanded(
            child: ProductGrid(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // initState에서 데이터를 불러옵니다.
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://172.16.107.66:8000/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        final List<dynamic> productList = json.decode(response.body);
        products = productList.map((item) => Product.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              _handleProductClick(context, products[index]);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.network(
                      products[index].frontproduct,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  products[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(products[index].allergens),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleProductClick(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('상품 정보'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('카테고리: ${product.kategorie}'),
                Text('이름: ${product.name}'),
                Image.network(
                  product.frontproduct,
                  fit: BoxFit.cover,
                ),
                Image.network(
                  product.backproduct,
                  fit: BoxFit.cover,
                ),
                Text('알레르기 식품: ${product.allergens}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
