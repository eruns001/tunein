import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunein/page/NullPage.dart';
import 'package:tunein/page/UploadQuestionPage.dart';
import 'package:tunein/widget/NetworkingDrawer.dart';

import 'data/class/Member.dart';
import 'data/class/Team.dart';
import 'data/class/TuneInUser.dart';
import 'data/data.dart';
import 'data/function.dart';
import 'page/CommunityPage.dart';
import 'page/HomePage.dart';
import 'page/LogInPage.dart';
import 'page/LoginLayoutPage.dart';
import 'page/MyProfilePage.dart';
import 'page/SearchPage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 네비게이션에 표시될 아이콘의 높이
  static const double ICON_HEIGHT = 30;

  /// 현재 표시 중인 페이지의 인덱스
  int _currentIndex = 2;

  //Widget pageNow = _pageList.elementAt((_currentIndex));

  /// 네비게이션에 표시될 항목들
  List<BottomNavigationBarItem> _navigationList = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Container(
        height: ICON_HEIGHT,
        child: Image.asset(
          'images/navigation_icon_searchUser.png',
          height: ICON_HEIGHT,
        ),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Container(
        height: ICON_HEIGHT,
        child: Image.asset(
          'images/navigation_icon_myPage.png',
          height: ICON_HEIGHT,
        ),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Container(
        height: ICON_HEIGHT,
        child: Image.asset(
          'images/navigation_icon_home.png',
          height: ICON_HEIGHT,
        ),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Container(
        height: ICON_HEIGHT,
        child: Image.asset(
          'images/navigation_icon_community.png',
          height: ICON_HEIGHT,
        ),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Container(
        height: ICON_HEIGHT,
        child: Image.asset(
          'images/navigation_icon_magazine.png',
          height: ICON_HEIGHT,
        ),
      ),
      label: '',
    ),
  ];

  /// 내비게이션을 터치했을 때 실행될 메서드
  _onTaped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  bool _initialized = false;
  bool _error = false;
  String _errorText = '';

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _errorText = e.toString();
        _error = true;
      });
    }
    setuid();
    setSearchPageUQPCount();
  }

  ///앱 첫실행때 한번 실행되는 함수
  @override
  void initState() {
    // TODO: implement initState
    initializeFlutterFire();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    /// 페이지들
    List<Widget> _pageList = <Widget>[
      SearchPage(),
      MyProfilePage(user: userNow),
      HomePage(),
      Nullpage(), //CommunityPage(),
      Nullpage(), // 임시
      // MagazinePage(),
    ];

    ///로그인 되어있는 상태면 바로 메인화면으로 가는 걸 구현할랬는데, 생각만큼 안나옴
    /// 21-03-01 ios 에서 빌드해서 테스트하려니까 자꾸 앱이 강제종료가 되어 따로 테스트하겠슴다.

    /// 참고사이트 https://papabee.tistory.com/163?category=903336


    // Show error message if initialization failed
    if(_error) {
      return Scaffold(
        body: Center(child: Text("$_errorText", style: TextStyle(color: Colors.blue),),),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Scaffold(
        body: Container(child: Text("_initialized", style: TextStyle(color: Colors.blue),),),
      );
    }

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ( context,  snapshot) {
        /// 데이터가 있을 경우 로그인이 되어있는 상태
        if (snapshot.hasData) {
          print("mainPage hasData");
          return Scaffold(

            body: IndexedStack(
              index: _currentIndex,
              children: _pageList,
            ),
            drawer: NetworkingDrawer(context: context),
            bottomNavigationBar: Container(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                items: _navigationList,
                onTap: _onTaped,
              ),
            ),
          );

        }
        /// 데이터가 없을 경우 로그인이 되어있지 않은 상태
        else {
          return LogInPage();
        }
      },
    );
  }
}
