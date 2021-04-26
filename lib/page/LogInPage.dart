import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:tunein/data/data.dart';
import 'package:tunein/data/function.dart';
import 'package:tunein/page/SignUpPage.dart';

import '../main.dart';

///로그인화면

class LogInPage extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogInPage> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    //디바이스 너비
    double _device_width = MediaQuery.of(context).size.width;
    //디바이스 높이
    double _device_height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: _device_height,
        width: _device_width,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("images/loginpage_background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*
            ///로그인 버튼
            Container(
              margin: new EdgeInsets.only(bottom: _device_height * (2 / 100)),
              child: FlatButton(
                onPressed: null,
                child: Image.asset(
                  "images/loginpage_btn_Login.png",
                  width: _device_width * (62.8 / 100),
                  height: _device_height * (6.2 / 100),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ///새계정 만들기 버튼
            Container(
              margin: new EdgeInsets.only(bottom: _device_height * (2 / 100)),
              child: FlatButton(
                onPressed: null,
                child: Image.asset(
                  "images/loginpage_btn_NewAccount.png",
                  width: _device_width * (62.8 / 100),
                  height: _device_height * (6.2 / 100),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            */
            Container(
              //margin: new EdgeInsets.only(bottom: _device_height * (2 / 100)),
              child: SignInButton(
                Buttons.Google,
                onPressed: () async {
                  /// 원본을 놔두고 따로 테스트해보기 위해서 플랫폼을 나누에서 진행
                  if (Platform.isIOS) {
                    /// 로딩화면용 context
                    /// 그냥 Navigator.pop(context) 를 사용하면 로딩화면이 사라지지 않아서
                    /// 이 방법으로 진행했습니다.
                    /// 출처 https://stackoverflow.com/questions/50683524/how-to-dismiss-flutter-dialog

                    BuildContext _dialogContext;

                    /// 인디케이터 출력
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        _dialogContext = context;
                        return AlertDialog(
                          content: CupertinoActivityIndicator(),
                        );
                      },
                    );

                    /// 구글 로그인 진행
                    bool signIn = await signInWithGoogle();
                    signInWithGoogle().then(
                          ( _result) async {
                        User? user = FirebaseAuth.instance.currentUser;

                        Navigator.pop(context);

                        if (user != null) {
                          await FirebaseFirestore.instance.collection('Account').doc(user.uid).get().then((doc) {
                            if(doc.exists){
                              print("doc.exists");
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (context) => MyHomePage()));
                            }
                            else{
                              print("doc.else");
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => SignUpPage()));
                            }
                          });
                        }
                        else {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => MyHomePage()));
                        }
                      },
                    );
                  }

                  else {
                    bool signIn = await signInWithGoogle();
                    if(signIn){
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance.collection('Account').doc(user.uid).get().then((doc) {
                          if(doc.exists){
                            isLogIn = true;
                            print("doc.exists");
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => MyHomePage()));
                          }
                          else{
                            print("doc.else");
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                          }
                        });
                      }

                      else {
                        print("doc.docelse");
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()));
                      }
                    }
                  }
                },
              ),
            ),
            Container(
              margin: new EdgeInsets.only(bottom: _device_height * (10 / 100)),
              child: FlatButton(
                onPressed: null,
                child: Image.asset(
                  "images/loginpage_btn_FindAccount.png",
                  width: _device_width * (35.5 / 100),
                  height: _device_height * (2.2 / 100),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
