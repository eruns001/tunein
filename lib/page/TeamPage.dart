import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunein/page/QuestionReadPage().dart';
import 'package:tunein/widget/NetworkingAppBar.dart';

class TeamPage extends StatefulWidget {

  final String teamID;

  const TeamPage ({
    Key? key,
    required this.teamID
  });

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {

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
          title: '팀원',
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
          rightButtonIcon: Container(
            child: TextButton(
              child: Text(
                  'POST'
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection("team").doc(widget.teamID).get().then((DocumentSnapshot value){
                  FirebaseFirestore.instance.collection('uqpPost').doc(value.data()!['Post']).get().then((DocumentSnapshot postSnapshot){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => QuestionReadPage(
                      Title: postSnapshot.data()!['Title'],
                      Writer_uid: postSnapshot.data()!['Writer_uid'],
                      QuestionId: postSnapshot.id,
                      Time: postSnapshot.data()!['Time'].toString(),
                      Summarize: postSnapshot.data()!['Summarize'],
                      Contents: postSnapshot.data()!['Contents'],
                    )));
                  });
                });
              },
            ),
          )
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: FirebaseFirestore.instance.collection('team').doc(widget.teamID).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                if(snapshot.data != null){
                  print("");
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: _device_width * 0.065),
                            child: Text("프사"),
                          ),
                          Text("닉네임"),
                          Container(
                            margin: EdgeInsets.only(right: _device_width * 0.065),
                            child: Text("역할"),
                          ),
                        ],
                      ),
                      for(int a = 0; a < snapshot.data!['teamMember'].length; a++)
                        FutureBuilder(
                          future: FirebaseFirestore.instance.collection('Account').doc(snapshot.data!['teamMember'][a]).get(),
                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                            if (snapshot.data != null){
                              Map<String, dynamic>? data = snapshot.data!.data();
                              return Container(
                                margin: EdgeInsets.only(left: _device_width * 0.065, right: _device_width * 0.065),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    ),
                                    Container(
                                      child: Text(
                                        data["roll"],
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      margin: EdgeInsets.only(left: _device_width * 0.03),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: CupertinoActivityIndicator(),
                            );
                          },
                        ),
                    ],
                  );

                }
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}