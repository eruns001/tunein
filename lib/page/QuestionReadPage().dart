import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tunein/data/data.dart';
import 'package:tunein/page/TeamPage.dart';
import 'package:tunein/widget/NetworkingAppBar.dart';

class QuestionReadPage extends StatefulWidget {

  final String Writer_uid;
  final String Time;
  final String Title;
  final String Summarize;
  final String Contents;
  final String QuestionId;

  const QuestionReadPage({
    Key? key,
    required this.Writer_uid,
    required this.Time,
    required this.Title,
    required this.Summarize,
    required this.Contents,
    required this.QuestionId,
  });

  @override
  _QuestionReadState createState() => _QuestionReadState();
}

class _QuestionReadState extends State<QuestionReadPage> {

  @override
  Widget build(BuildContext context) {
    //디바이스 너비
    double _device_width = MediaQuery.of(context).size.width;
    //디바이스 높이
    double _device_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: NetworkingAppBar(
        context: context,
        deviceHeight: _device_height,
        deviceWidth: _device_width,
        title: '',
        stackIndex: 1,
        leftButton: Container(
          margin: EdgeInsets.only(left: _device_width * 0.02),
          child: IconButton(
              icon: Icon(
                CupertinoIcons.chevron_left,
                color: const Color(0xff46abdb),
                size: 35,
              ),
              onPressed: (){
                Navigator.pop(context);
              }
          ),
        ),
        rightButtonIcon: Container()
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///작성자 프로필사진 + 작성자 역할
            Container(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance.collection('Account').doc(widget.Writer_uid).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (snapshot.data != null){
                      Map<String, dynamic>? data = snapshot.data!.data();
                      return Container(
                        margin: EdgeInsets.only(left: _device_width * 0.065),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                height: _device_width * 0.12,
                                width: _device_width * 0.12,
                                child: Image.network(
                                  data!["imageUrl"],
                                ),
                              )
                            ),
                            Container(
                              child: Text(
                                data["nickName"],
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              margin: EdgeInsets.only(left: _device_width * 0.03),
                            )
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: _device_height * 0.02, left: _device_width * 0.08),
              child: Text(
                widget.Title,
                style: TextStyle(
                  color: const Color(0xff000000),
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.bold,
                  fontStyle:  FontStyle.normal,
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: _device_height * 0.02, left: _device_width * 0.08),
              child: Text(
                widget.Summarize,
                style: TextStyle(
                  color: const Color(0xff000000),
                  fontFamily: "NotoSansKR",
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top:  _device_height * 0.05),
                width: _device_width * 0.9,
                height: 1,
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: _device_height * 0.05, left: _device_width * 0.08),
              child: Text(
                widget.Contents,
                style: TextStyle(
                  color: const Color(0xff000000),
                  fontFamily: "NotoSansKR",
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top:  _device_height * 0.05, bottom:  _device_height * 0.05),
                width: _device_width * 0.9,
                height: 1,
                color: Colors.black,
              ),
            ),
            Center(
              child: ElevatedButton(onPressed: () async {
                await FirebaseFirestore.instance.collection('uqpPost').doc(widget.QuestionId).get().then((DocumentSnapshot value) {
                  if(!value.data()!.containsKey('team')){
                    FirebaseFirestore.instance.collection('team').add({
                      'teamMember': [uid],
                      'Post' : widget.QuestionId,
                    }).then((DocumentReference value) {
                      FirebaseFirestore.instance.collection('uqpPost').doc(widget.QuestionId).update({
                        'team': value.id
                      });
                      print("DocumentReference : ${value.id}");
                      FirebaseFirestore.instance.collection('Account').doc(uid).get().then((DocumentSnapshot uservalue) {
                        if(!uservalue.data()!.containsKey('Teams')){
                          FirebaseFirestore.instance.collection('Account').doc(uid).update({
                            'Teams' : [value.id],
                          });
                        }
                        else{
                          FirebaseFirestore.instance.collection('Account').doc(uid).update({
                            'Teams' : FieldValue.arrayUnion([value.id]),
                          });
                        }
                      });
                    });
                  }
                  else{

                    FirebaseFirestore.instance.collection('uqpPost').doc(widget.QuestionId).get().then((DocumentSnapshot value){
                      FirebaseFirestore.instance.collection('team').doc(value['team']).update({
                        'teamMember': FieldValue.arrayUnion([uid])
                      });

                      FirebaseFirestore.instance.collection('Account').doc(uid).get().then((DocumentSnapshot uservalue) {
                        if(!uservalue.data()!.containsKey('Teams')){
                          FirebaseFirestore.instance.collection('Account').doc(uid).update({
                            'Teams' : [value['team']],
                          });
                        }
                        else{
                          FirebaseFirestore.instance.collection('Account').doc(uid).update({
                            'Teams' : FieldValue.arrayUnion([value['team']]),
                          });
                        }
                      });
                    });
                  }
                });
              },
                child: Text(
                "참여"
              ),),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('uqpPost').doc(widget.QuestionId).get().then((DocumentSnapshot value){
                    if(value.data()!.containsKey('team')){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => TeamPage(teamID: value.data()!['team'],)));
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "모집된 팀원이 없습니다.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  });
                },
                child: Text(
                  "TeamMember"
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}