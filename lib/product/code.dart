import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_banergy/appbar/Search_Widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_banergy/bottombar.dart';
import 'package:flutter_banergy/mainDB.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CodeScreen extends StatefulWidget {
  final String resultCode;

  const CodeScreen({super.key, required this.resultCode});

  @override
  _CodeScreenState createState() => _CodeScreenState(resultCode);
}

class _CodeScreenState extends State<CodeScreen> {
  String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
  late String resultCode;
  late List<Product> products = [];

  _CodeScreenState(this.resultCode); // 생성자 수정

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('$baseUrl:8000/scan?barcode=$resultCode'),
    );
    if (response.statusCode == 200) {
      // 서버가 잘 작동하는 지 테스트
      print('서버로부터 받은 데이터: ${response.body}');
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
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Flexible(
            child: SearchWidget(),
          ),
        ],
      ),
      body: scanGrid(products: products),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class scanGrid extends StatefulWidget {
  final List<Product> products;

  scanGrid({super.key, required this.products});

  @override
  State<scanGrid> createState() => _scanGridState();
}

class _scanGridState extends State<scanGrid> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '데이터베이스에 저장된 내용이 없습니다 ㅜ.ㅜ',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                  context: context,
                  onCode: (code) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeScreen(
                          resultCode: code ?? "스캔된 정보 없음",
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text('다시찍기'),
            ),
          ],
        ),
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                _handleProductClick(context, widget.products[index]);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      widget.products[index].frontproduct,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.products[index].name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(widget.products[index].allergens),
                ],
              ),
            ),
          );
        },
      );
    }
  }
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
