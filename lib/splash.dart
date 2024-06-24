import 'dart:async';

import 'package:diary/home.dart';
import 'package:flutter/material.dart';

class splash extends StatefulWidget {
  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  String _displayText = "";
  int _currentIndex = 0;
  final String _fullText = 'Diary and Reminder App';

  @override
  void initState() {
    super.initState();
    const typingInterval = 200;
    Timer.periodic(Duration(milliseconds: typingInterval), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
    Timer(Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DiaryHomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color.fromARGB(255, 199, 131, 131),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              './assets/imgs/diary.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              _displayText,
              style: TextStyle(fontSize: 34, color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
