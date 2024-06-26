// 비회원 필터링 테스트

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_banergy/NoUser/no_user_main.dart';
import 'package:flutter_banergy/login/login_FirstApp.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_banergy/bottombar.dart';
// import 'package:flutter_banergy/mypage/mypage.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const Nouserfiltering());
}

class Nouserfiltering extends StatelessWidget {
  const Nouserfiltering({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FilteringPage(),
    );
  }
}

class FilteringPage extends StatefulWidget {
  const FilteringPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FilteringPageState createState() => _FilteringPageState();
}

class _FilteringPageState extends State<FilteringPage> {
  List<String?> checkListValue2 = [];
  String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost';
  List<String> checkList2 = [
    "계란",
    "밀",
    "대두",
    "우유",
    "게",
    "새우",
    "돼지고기",
    "닭고기",
    "소고기",
    "고등어",
    "복숭아",
    "토마토",
    "호두",
    "잣",
    "땅콩",
    "아몬드",
    "조개류",
    "기타"
  ];

  Future<void> _userFiltering(
      BuildContext context, List<String?> checkListValue2) async {
    final String allergies = jsonEncode(checkListValue2);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl:8000/nouser/ftr'),
        body: jsonEncode({'allergies': allergies}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('적용완료!!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NoUserMainpageApp(),
                        ));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 29, 171, 102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text('다시 확인해주세요.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 29, 171, 102),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('확인'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "알러지 필터링",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F2F7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FirstApp(),
              ),
            );
          },
        ),
      ),
      //bottomNavigationBar: const BottomNavBar(),
      body: Column(
        children: [
          // Image 추가
          Container(
            color: Colors.white,
            child: Image.asset(
              'images/000.jpeg',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "해당하는 알레르기를 체크해주세요",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'PretendardSemiBold',
            ),
          ),
          // 중앙에 정렬된 필터 영역
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              child: Row(
                children: [
                  // 왼쪽 필터
                  Expanded(
                    child: buildFilterList(checkList2),
                  ),
                ],
              ),
            ),
          ),
          // 적용 버튼 추가
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03C95B),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () => {
                _userFiltering(context, checkListValue2),
                print("저장된 값: $checkListValue2")
              },
              child: const Text(
                '적용',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'PretendardSemiBold'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 체크박스 리스트를 생성하는 함수
  Widget buildFilterList(List<String> filterList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filterList.length,
      itemBuilder: (context, index) {
        String filter = filterList[index];
        return Container(
          margin: const EdgeInsets.all(10.0),
          child: CheckboxListTile(
            onChanged: (bool? check) {
              setState(() {
                if (checkListValue2.contains(filter)) {
                  checkListValue2.remove(filter);
                  return;
                }
                checkListValue2.add(filter);
              });
            },
            title: Text(filter),
            value: checkListValue2.contains(filter) ? true : false,
          ),
        );
      },
    );
  }
}
