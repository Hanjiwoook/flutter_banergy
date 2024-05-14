import 'package:flutter/material.dart';

class ButtonOptions extends StatefulWidget {
  @override
  ButtonOptionsState createState() => ButtonOptionsState();
}

class ButtonOptionsState extends State<ButtonOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Text('First Screen'),
          ),
      body: SizedBox(
        height: 100.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return _buildItems(index);
          },
        ),
      ),
    );
  }

  Widget _buildItems(int index) {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          child: const Text("Hi"),
          onPressed: () {},
        ),
      ),
    );
  }
}
