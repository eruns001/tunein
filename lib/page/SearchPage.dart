
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunein/data/data.dart';
import 'package:tunein/data/function.dart';
import 'package:tunein/page/QuestionReadPage().dart';
import 'package:tunein/widget/NetworkingAppBar.dart';
import 'package:tunein/widget/SearchPage_DocumentView.dart';

import 'UploadQuestionPage.dart';

/// 2021-02-24 21:45
/// main.dart 파일의 정리를 위해서 검색 페이지 분리

//전역변수
//searchTextEditingController
TextEditingController searchTextEditingController = TextEditingController();



class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  int pageNum = 1;
  int pageLowNum = 1;
  int pageHighNum = 5;


  ScrollController _sController = ScrollController();


  @override
  void initState() {
    setSearchPageUQPCount();
    setSearchPageUQPList();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //화면 크기 체크
    //디바이스 너비
    double _device_width = MediaQuery.of(context).size.width;
    //디바이스 높이
    double _device_height = MediaQuery.of(context).size.height;

    var pageDocs = FirebaseFirestore.instance.collection("uqpPost").orderBy("Time").limit(10);

    return Scaffold(
      appBar: NetworkingAppBar(context: context, deviceHeight: _device_height, deviceWidth: _device_width, title: "", stackIndex: 0),
      /*
      PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
            brightness: Brightness.light,
            centerTitle: true,
            titleSpacing: -5,
            backgroundColor: Colors.white.withOpacity(0.0),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: SizedBox(
              height: 500,
              child: Row(
                children: <Widget>[
                  ///선 세개
                  IconButton(
                      padding: EdgeInsets.only(left: 30, right: 25),
                      icon: Icon(
                        CupertinoIcons.bars,
                        color: const Color(0xff46abdb),
                        size: 50,
                      ),
                      onPressed: (){
                        //Scaffold.of(context).openDrawer();
                      }),
                  ///검색창
                  new Flexible(
                    child: TextFormField(
                      controller: searchTextEditingController,
                      decoration: InputDecoration(
                        hintText: '$searchPageCounter', //'검색어를 입력해 주세요.',
                        hintStyle: TextStyle(
                          color: const Color(0xffa2d5ed),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: const Color(0xff46abdb))),
                        suffixIcon: Icon(
                          CupertinoIcons.search,
                          color: const Color(0xff46abdb),
                          size: 30,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xffa2d5ed),
                      ),
                      onFieldSubmitted: null,
                    ),
                  ),
                  ///새글
                  IconButton(
                      padding: EdgeInsets.only(left: 20, right: 25),
                      icon: Icon(
                        CupertinoIcons.doc,
                        color: const Color(0xff46abdb),
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UploadQuestionPage()),
                        );
                      }),
                ],
              ),
            )),
      ),
      */
      body: Column(
        children: [
          ///Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ///Dropdown - 위치
              DropdownButton<String>(
                value: dropdownValueAddress,
                onChanged: ( newValue) {
                  setState(() {
                    dropdownValueAddress = newValue.toString();
                  });
                },
                items: searchAddressList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ///Dropdown - 역할
              DropdownButton<String>(
                value: dropdownValueRole,
                onChanged: ( newValue) {
                  setState(() {
                    dropdownValueRole = newValue.toString();
                    positionList = setPositionList(dropdownValueRole);
                  });
                },
                items: searchRoleList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              /*
                  ///Dropdown - 분야
                  DropdownButton<String>(
                    value: dropdownValuePosition,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValuePosition = newValue;
                      });
                    },
                    items: positionList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                   */
              ///Dropdown - 갯수
              DropdownButton<int>(
                value: dropdownValueNumber,
                onChanged: ( newValue) {
                  setState(() {
                    dropdownValueNumber = newValue!;
                  },
                  );
                },
                items: <int>[10, 20, 30, 40]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              )
            ],
          ),
          Expanded(
              child: StreamBuilder(
                stream: currentStream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }
                  if(snapshot.data == null){
                    return Text("Loading");
                  }
                  print("searchaasdfasdnapshot : ${snapshot.data!.docs[0].id}");
                  return new ListView(
                    shrinkWrap: true,
                    controller: new ScrollController(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(8),
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      return new ListTile(
                        minVerticalPadding: 10,
                        title: new Text(document.data()!['Title']),
                        subtitle: new Text(document.data()!['Summarize']),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => QuestionReadPage(
                                Writer_uid: document.data()!['Writer_uid'],
                                Time: document.data()!['Time'].toString(),
                                Title: document.data()!['Title'],
                                Summarize: document.data()!['Summarize'],
                                Contents: document.data()!['Contents'],
                                QuestionId: document.id,
                              )
                          ));
                        },
                      );
                    }).toList(),
                  );
                },
              ),
          ),
          /*
          Container(
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: _device_width * 0.1,
                  margin: EdgeInsets.all(_device_width * 0.04),
                  child: TextButton(
                    child: Text(
                        "<"
                    ),
                    onPressed: (){
                      if(pageLowNum != 1){
                        setState(() {
                          pageLowNum = pageLowNum - 5;
                          pageHighNum = pageLowNum + 4;
                        });//((pageNum - 1)*dropdownValueNumber)<searchPageUQPCount
                      }
                    },
                  ),
                ),
                for(int pageNow = pageLowNum; pageNow <= pageHighNum ; pageNow ++)
                  Container(
                    width: _device_width * 0.08,
                    margin: EdgeInsets.all(_device_width * 0.01),
                    child: TextButton(
                      child: Text(
                          pageNow.toString()
                      ),
                      onPressed: (){
                        setState(() {

                        });
                      },
                    ),
                  ),
                Container(
                  width: _device_width * 0.1,
                  margin: EdgeInsets.all(_device_width * 0.04),
                  child: TextButton(
                    child: Text(
                        ">"
                    ),
                    onPressed: (){
                      if(((pageLowNum + 9)*dropdownValueNumber) < searchPageUQPCount){
                        setState(() {
                          pageLowNum = pageLowNum + 5;
                          pageHighNum = pageLowNum + 4;
                        });
                      }
                      else if (pageLowNum + 5 <= (searchPageUQPCount / dropdownValueNumber).ceil()){
                        setState(() {
                          pageLowNum = pageLowNum + 5;
                          pageHighNum = (searchPageUQPCount / dropdownValueNumber).ceil();
                        });
                      }
                      print('SearchPage/ pageLowNom : $pageLowNum');
                      print('SearchPage/ pageHighNum : $pageHighNum');
                    },
                  ),
                ),
              ],
            ),
          ),

           */
        ],
      )
    );
  }
}


Widget temp(_device_width, _device_height) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(10.0),
          width: _device_width * (38.4 / 100),
          height: _device_height * (18.4 / 100),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff46abdb), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x80cacaca),
                    offset: Offset(0, -1),
                    blurRadius: 16,
                    spreadRadius: 2)
              ],
              color: Colors.white),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          width: _device_width * (38.4 / 100),
          height: _device_height * (18.4 / 100),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff46abdb), width: 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x80cacaca),
                    offset: Offset(0, -1),
                    blurRadius: 16,
                    spreadRadius: 2)
              ],
              color: Colors.white),
        ),
        //Image.asset('images/search_btn_home.png'),
      ],
    ),
  );
}

Widget textNumberButton(double _deviceWidth, _deviceHeight, int limitNum){

  return Container();
}

void searchItem(Query query,int limitNum) {
  var temp = FirebaseFirestore.instance
      .collection('uqpPost')
      .orderBy('Time', descending: true);
  var first = FirebaseFirestore.instance
      .collection('uqpPost')
      .orderBy('Time', descending: true)
      .limit(limitNum).get().then(
          (QuerySnapshot snapshot){
            print("query ${snapshot.size.toString()}");
            print(snapshot.docs[0].id);

            var next = FirebaseFirestore.instance
                .collection('uqpPost').orderBy('Time', descending: true).startAfter([snapshot.docs[snapshot.size -1].id]).limit(2);

          });
}

