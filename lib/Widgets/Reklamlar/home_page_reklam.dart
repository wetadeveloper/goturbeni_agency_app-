import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageReklam extends StatefulWidget {
  const HomePageReklam({super.key});

  @override
  HomePageReklamState createState() => HomePageReklamState();
}

class HomePageReklamState extends State<HomePageReklam> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

//Zamanlayıcı
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView(
        controller: _pageController,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // reklama tıklandığında yapılacak işlem
              // ignore: deprecated_member_use
              launch('https://www.selametturizm.com');
            },
            child: Container(
              color: Colors.red,
              child: Container(),
            ),
          ),
          GestureDetector(
            onTap: () {
              // reklama tıklandığında yapılacak işlem
              // ignore: deprecated_member_use
              launch('https://www.selametturizm.com');
            },
            child: Container(
              color: Colors.green,
              child: Container(),
            ),
          ),
          GestureDetector(
            onTap: () {
              // reklama tıklandığında yapılacak işlem
              // ignore: deprecated_member_use
              launch('https://www.selametturizm.com');
            },
            child: Container(
              color: Colors.blue,
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
