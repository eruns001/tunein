import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tunein/data/data.dart';
import 'dart:io';

import 'package:tunein/page/SearchPage.dart';

import 'class/TuneInUser.dart';

Future network_function_getImage(String where, int _counter) async{
  PickedFile? pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
  File image = File(pickedFile!.path);

  Reference storageReference = FirebaseStorage.instance.ref()
      .child(where)
      .child(uid)
      .child('${dateFormat.format(DateTime.now())}_${uid}_No$_counter.jpg');
  _counter ++;

  UploadTask uploadTask = storageReference.putFile(image);
  TaskSnapshot strageTask = await uploadTask;//.onComplete;
  //String downloadURL = await strageTask.ref.getDownloadURL();
  strageTask.ref.getDownloadURL().then((value) {
    print("from function value : $value");
    imageUrl = value;
    print("from function imageUrl : $imageUrl");
    return value;
  });
}

///url 받아서 이미지 반환
Widget returnImageFromUrl(String url){
  return Image(
      image:  NetworkImage(url),
  );
}

Future signInWithGoogle () async{

  LoginService(){

  }
  Firebase.initializeApp();
  GoogleSignIn googleSignIn = GoogleSignIn();
  print("googleSingIn start");
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  print("googleSingIn before");
  if(googleUser == null) {
    print("googleSingIn null");
    return false;
  }
  print("googleSingIn then");

  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken
  );

  UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);

  if(userCred != null){
    User? user = userCred.user;
    print("user.uid : ${user!.uid}");
    uid = user.uid;
  }
  return true;
}

Future signin(String email, String password) async {
  try{
    UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    //FirebaseUser user = result.user;

    return Future.value(true);
  } catch(e){
    switch(e){
      case 'ERROR_INVALID_EMAIL':
        print('error_signin : ERROR_INVALID_EMAIL');
    }
  }
}

Future signup(String email, String password) async {
  try{
    UserCredential result = await auth.signInWithEmailAndPassword(email: email, password: password);
    //FirebaseUser user = result.user;

    return Future.value(true);
  } catch(e){
    switch(e){
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        print('error_signup : ERROR_EMAIL_ALREADY_IN_USE');
    }
  }
}

///로그아웃
Future<bool> signOutUser() async {
  User? user = FirebaseAuth.instance.currentUser;

  if(user!.providerData[1].providerId == 'google.com'){
    await googleSignIn.disconnect();
  }
  await auth.signOut();
  userNow = new TuneInUser();
  return Future.value(false);
}

///회원탈퇴
Future<bool> WithdrawalUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore.instance.collection('Account').doc(user!.uid).delete();
  await user.delete();
  if(user.providerData[1].providerId == 'google.com'){
    await googleSignIn.disconnect();
  }
  await auth.signOut();
  user = null;
  userNow = new TuneInUser();
  return Future.value(false);
}

///회원가입 된 상태인지 확인
void IsLogin() {
  var docRef = FirebaseFirestore.instance.collection('Account').doc(uid);
  docRef.get();
}


///init
Future<bool> setuid() {
  auth = FirebaseAuth.instance;
  print("setuid");

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null){
    print("from function value : ${currentUser.photoURL}");
    basicImageUrl = currentUser.photoURL!;
    print("from function basicImageUrl : $basicImageUrl");
    uid = currentUser.uid;

    FirebaseFirestore.instance.collection('Account').doc(uid).get()
        .then((DocumentSnapshot ds) {
      userNow = TuneInUser(
        imageUrl: ds.data()!['imageUrl'],
        nickName: ds.data()!['nickName'],
        name: ds.data()!['name'],
        phoneNum: ds.data()!['contact'],
        email: ds.data()!['e_mail'],
        career: ds.data()!['career'],
        birth: ds.data()!['birth'],
        roll: ds.data()!['roll'],
        position: ds.data()!['position'],
        address: ds.data()!['address'],
      );
    }).then((value){
      return true;
    });
  }
  return Future<bool>.value(false);
}
///init Login UserData 로그인 유저 데이터 입력


///SearchPage
List<String> setPositionList(Role) {
  List<String> PositionList = positionNullList;
  switch(Role){
    case "모든역할":
      PositionList= positionNullList;
      break;
    case "SW 개발":
      PositionList= positionDeveloperList;
      break;
    case "기획/PM/운영":
      PositionList= positionPlannerList;
      break;
    case "마케팅":
      PositionList= positionMarketingList;
      break;
    case "일러스트/디자인":
      PositionList = positionDesignerList;
      break;
    case "영상/인터넷 방송":
      PositionList = positionVideoList;
      break;
    case "음악":
      PositionList = positionMusicList;
      break;
  }
  return PositionList;
}

Future<List> getUQPList() async {
  List temp = [];
  QuerySnapshot value = await FirebaseFirestore.instance.collection('uqpPost').orderBy('Time').limit(10).get();
  temp = value.docs;
  return temp;
}
//페이지 넘길때마다 이 함수 사용할 것.
Future<void> setSearchPageUQPCount () async {
  final DocumentReference docRef =FirebaseFirestore.instance.collection('meta').doc('uqp');
  docRef.get().then((DocumentSnapshot ds) {
    searchPageUQPCount = ds.data()!['count'];
    print("setSearchPageUQPCount $searchPageUQPCount");
  });
}
Future<void> setSearchPageUQPList() async{
  searchPageUQPList = await getUQPList();
}

///로그인 이후 회원정보 받아오기
Future getAccount() async{


}