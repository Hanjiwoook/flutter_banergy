import 'package:flutter/material.dart';
import 'package:flutter_banergy/main.dart';
import '../mypage/mypage.dart';

void main() {
  runApp(const MaterialApp(
    home: Delete(),
  ));
}

class Delete extends StatelessWidget {
  const Delete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 50, 160, 107)),
      useMaterial3: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 탈퇴하기"),
        backgroundColor: const Color.fromARGB(255, 29, 171, 102),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'images/000.jpeg',
                  width: 80,
                  height: 80,
                ),
                const Text(
                  '탈퇴하기',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                const InputField(label: '계정 비밀번호', hintText: '계정 비밀번호를 입력하세요'),
                const SizedBox(height: 20),
                const InputField(
                  label: '탈퇴 사유',
                  hintText: '간단한 탈퇴 사유를 적어주세요.',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 다이얼로그를 표시
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('회원 탈퇴 완료'),
                          content: const Text('회원 탈퇴가 성공적으로 처리되었습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // 다이얼로그를 닫음
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 29, 171, 102),
                  ),
                  child:
                      const Text('회원탈퇴', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      //bottomNavigationBar: BottomNavBar(),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final String hintText;

  const InputField({required this.label, this.hintText = ""});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ],
    );
  }
}
