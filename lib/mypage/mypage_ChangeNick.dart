import 'package:flutter/material.dart';
//import 'package:flutter_banergy/main.dart';
import '../mypage/mypage.dart';

/*void main() {
  runApp(const MaterialApp(
    home: ChangeNick(),
  ));
}*/

class ChangeNick extends StatefulWidget {
  const ChangeNick({Key? key}) : super(key: key);

  @override
  _ChangeNickState createState() => _ChangeNickState();
}

class _ChangeNickState extends State<ChangeNick>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 50, 160, 107)),
      useMaterial3: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("닉네임 변경하기"),
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
                const SizedBox(height: 20),
                const Text(
                  '닉네임 변경',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 60),
                const InputField(label: '원래 닉네임 *'),
                const SizedBox(height: 20),
                const InputField(
                    label: '변경할 닉네임 *', hintText: '변경할 닉네임을 입력하세요'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: const Text('닉네임이 성공적으로 변경되었습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
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
                  child: const Text('닉네임 변경',
                      style: TextStyle(color: Colors.white)),
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

// 글상자
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
              )),
        ),
      ],
    );
  }
}
