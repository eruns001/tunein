import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunein/page/TeamPage.dart';
import 'package:tunein/widget/NetworkingAppBar.dart';

class TeamListPage extends StatefulWidget {

  final List teamList;

  const TeamListPage ({
    Key? key,
    required this.teamList
  });

  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {

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
          title: '참여한 팀 목록',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for(int a = 0; a < widget.teamList.length; a++)
            Container(
              width: _device_width * 0.9,
              margin: EdgeInsets.only(top: _device_width * 0.01),
              child: Center(
                child: TextButton(
                  child: Text(
                    widget.teamList[a],
                    style: TextStyle(
                      color: const Color(0xff000000),
                      fontFamily: "NotoSansKR",
                      fontStyle:  FontStyle.normal,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => TeamPage(teamID: widget.teamList[a],)));
                  },
                ),
              )
            )
        ],
      ),
    );
  }
}