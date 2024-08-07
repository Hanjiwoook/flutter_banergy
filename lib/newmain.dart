import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_banergy/appbar/Search_Widget.dart';
import 'package:flutter_banergy/login/login_login.dart';
import 'package:flutter_banergy/mypage/mypage.dart';
import 'package:flutter_banergy/mypage/mypage_freeboard.dart';
import 'package:flutter_banergy/product/code.dart';
import 'package:flutter_banergy/product/ocr_result.dart';
import 'package:flutter_banergy/product/product_detail.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_banergy/mainDB.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:photo_view/photo_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_banergy/main_category/bigsnacks.dart';
import 'package:flutter_banergy/main_category/gimbap.dart';
import 'package:flutter_banergy/main_category/snacks.dart';
import 'package:flutter_banergy/main_category/Drink.dart';
import 'package:flutter_banergy/main_category/instantfood.dart';
import 'package:flutter_banergy/main_category/ramen.dart';
import 'package:flutter_banergy/main_category/lunchbox.dart';
import 'package:flutter_banergy/main_category/Sandwich.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    const MaterialApp(
      home: MainpageApp(),
    ),
  );
}

// 앱의 메인 페이지를 빌드하는 StatelessWidget입니다.
class MainpageApp extends StatelessWidget {
  final File? image;

  const MainpageApp({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

// 홈 화면을 관리하는 StatefulWidget입니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
  String? authToken; // 사용자의 인증 토큰
  final ImagePicker _imagePicker = ImagePicker(); // 이미지 피커 인스턴스
  final _qrBarCodeScannerDialogPlugin =
      QrBarCodeScannerDialog(); // QR/바코드 스캐너 플러그인 인스턴스
  String? code; // 바코드
  String resultCode = ''; // 스캔된 바코드 결과
  String ocrResult = ''; // OCR 결과
  bool isOcrInProgress = false; // OCR 작업 진행 여부
  final picker = ImagePicker(); // 이미지 피커 인스턴스
  late String img64; // 이미지를 Base64로 인코딩한 결과
  late ScrollController _scrollController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // 로그인 상태 확인
    _scrollController = ScrollController();
    _scrollController.addListener(_toggleVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_toggleVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _isVisible = false;
      });
    } else {
      setState(() {
        _isVisible = true;
      });
    }
  }

  // 이미지 업로드 및 OCR 작업을 수행합니다.
  Future<void> _uploadImage(XFile pickedFile) async {
    setState(() {
      isOcrInProgress = true; // 이미지 업로드 시작
    });

    final url = Uri.parse('$baseUrl:8000/logindb/ocr');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $authToken';
    request.files
        .add(await http.MultipartFile.fromPath('image', pickedFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = jsonDecode(responseData);
      setState(() {
        ocrResult = decodedData['text'].join('\n'); // OCR 결과 업데이트
      });
    } else {
      setState(() {
        ocrResult =
            'Failed to perform OCR: ${response.statusCode}'; // OCR 실패 메시지 업데이트
      });
    }
  }

  // 사용자의 로그인 상태를 확인하고 인증 토큰을 가져옵니다.
  Future<void> _checkLoginStatus() async {
    final token = await _loginUser();
    if (token != null) {
      final isValid = await _validateToken(token);
      setState(() {
        authToken = isValid ? token : null;
      });
    }
  }

  // 사용자가 이미 로그인했는지 확인합니다.
  Future<String?> _loginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // 토큰의 유효성을 확인합니다.
  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl:8000/logindb/loginuser'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  int _selectedIndex = 0; // 현재 선택된 바텀 네비게이션 바 아이템의 인덱스
  int _current = 0;
  final CarouselController _controller = CarouselController();
  List<String> imageList = [
    'assets/images/ad.png',
  ];

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
      body: Column(
        children: [
          Visibility(
            visible: _isVisible,
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  sliderWidget(),
                  sliderIndicator(),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _isVisible,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) {
                  // 카테고리 정보 (이름과 이미지 파일 이름)
                  List<Map<String, String>> categories = [
                    {"name": "라면", "image": "001.png"},
                    {"name": "패스트푸드", "image": "002.png"},
                    {"name": "김밥", "image": "003.png"},
                    {"name": "도시락", "image": "004.png"},
                    {"name": "샌드위치", "image": "005.png"},
                    {"name": "음료", "image": "006.png"},
                    {"name": "간식", "image": "007.png"},
                    {"name": "과자", "image": "008.png"},
                  ];
                  // 현재 카테고리
                  var category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      _navigateToScreen(
                        context,
                        category["name"]!,
                      );
                    },
                    child: SizedBox(
                      width: 100,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.asset(
                                'assets/images/${category["image"]}',
                                width: 60, // 이미지의 너비
                                height: 60, // 이미지의 높이
                              ),
                            ),
                            Text('${category["name"]}', // 카테고리 이름 라벨
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'PretendardBold')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Expanded(
            child: ProductGrid(), // 상품 그리드
          ),
          if (isOcrInProgress) // OCR 작업이 진행 중인 경우에만 표시
            Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.5),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    '서버에 이미지 업로드 중... \n 최대 2~3분이 소요됩니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green, // 선택된 아이템의 색상
        unselectedItemColor: Colors.black, // 선택되지 않은 아이템의 색상
        selectedLabelStyle:
            const TextStyle(color: Colors.green), // 선택된 아이템의 라벨 색상
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/home.png'),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/ai.png'),
            ),
            label: 'AI 추천',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/lens.png'),
            ),
            label: '렌즈',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/heart.png'),
            ),
            label: '찜',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/person.png'),
            ),
            label: '마이 페이지',
          ),
        ],
        onTap: (index) async {
          setState(() {
            _selectedIndex = index; // 선택된 인덱스 업데이트
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainpageApp()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Freeboard()));
          } else if (index == 2) {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            var cameraStatus = await Permission.camera.status;
                            if (!cameraStatus.isGranted) {
                              await Permission.camera.request();
                            }
                            final pickedFile = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                            ) as XFile;

                            setState(() {
                              // 이미지 선택 후에 진행 바를 나타냅니다.
                              isOcrInProgress = true;
                            });

                            try {
                              await _uploadImage(pickedFile);
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Ocrresult(
                                    imagePath: pickedFile.path,
                                    ocrResult: ocrResult,
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint('OCR failed: $e');
                            } finally {
                              setState(() {
                                // OCR 작업 완료 후에 진행 바를 숨깁니다.
                                isOcrInProgress = false;
                              });
                            }
                          },
                          child: const Text(
                            '카메라',
                            style: TextStyle(fontFamily: 'PretendardMedium'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final pickedFile = await _imagePicker.pickImage(
                                source: ImageSource.gallery) as XFile;
                            setState(() {
                              isOcrInProgress = true;
                            });
                            // ignore: duplicate_ignore
                            try {
                              // OCR 수행
                              await _uploadImage(pickedFile);

                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Ocrresult(
                                    imagePath: pickedFile.path,
                                    ocrResult: ocrResult,
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint('OCR failed: $e');
                            }
                          },
                          child: const Text(
                            '갤러리',
                            style: TextStyle(fontFamily: 'PretendardMedium'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
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
                          child: const Text(
                            'QR/바코드',
                            style: TextStyle(fontFamily: 'PretendardMedium'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (index == 4) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MypageApp()),
            );
          }
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String categoryName) {
    Widget? screen;
    switch (categoryName) {
      case '라면':
        screen = const RamenScreen();
        break;
      case '패스트푸드':
        screen = const InstantfoodScreen();
        break;
      case '김밥':
        screen = const GimbapScreen();
        break;
      case '도시락':
        screen = const LunchboxScreen();
        break;
      case '샌드위치':
        screen = const SandwichScreen();
        break;
      case '음료':
        screen = const DrinkScreen();
        break;
      case '간식':
        screen = const SnacksScreen();
        break;
      case '과자':
        screen = const BigsnacksScreen();
        break;
    }
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

// 캐러셀 관련 코드
  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
        (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  imgLink,
                  fit: BoxFit.fill,
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 220,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 상품 그리드를 표시하는 StatefulWidget입니다.
class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
  late List<Product> products = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    fetchData(); // 데이터 가져오기
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 상품 데이터를 가져오는 비동기 함수
  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('$baseUrl:8000/'),
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

  // 사용자의 로그인 상태를 확인하고 메인 페이지로 리디렉션하는 함수
  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      // 로그인x
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginApp()),
      );
    } else {
      // 로그인 o -> 메인 페이지로 이동
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainpageApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: products.length,
      shrinkWrap: true,
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PretendardRegular'), // 텍스트 크기와 별도로 다시 수정
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

  // 상품 클릭 시 새로운창에서 상품 정보를 표시하는 함수
  void _handleProductClick(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pdScreen(product: product),
      ),
    );
  }
}
