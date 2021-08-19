import 'package:flutter/material.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';
import 'package:pgc/widgets/tabbutton.dart';

class WorkList extends StatefulWidget {
  @override
  _WorkListState createState() => _WorkListState();
}

class _WorkListState extends State<WorkList> {
  int _selectedPage = 0;
  PageController _pageController;
  List<HistoryModel> histories = [
    HistoryModel('TRIP-2021-0002', true, true, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0001', false, false, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0002', true, true, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0001', false, false, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0002', true, true, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0001', false, false, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0002', true, true, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0001', false, false, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0002', true, true, 'รอให้บริการ'),
    HistoryModel('TRIP-2021-0001', false, false, 'รอให้บริการ')
  ];

  void _changePage(int pageNum) {
    setState(() {
      _selectedPage = pageNum;
      _pageController.animateToPage(pageNum,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);
    });
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          BackGround(),
          Container(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ProfileBarWithDepartment(),
                ]),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 85),
            height: double.infinity,
            width: double.infinity,
            decoration: backgroundWithBorderDecorationStyle,
            child: PageView(
              controller: _pageController,
              children: [_newJob(histories, context), _currentJob()],
            ),
          )
        ],
      ),
    ));
  }
}

Container _newJob(histories, ctx) {
  return Container(
    padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
    child: Column(children: <Widget>[
      Row(
        children: <Widget>[
          Image.asset(
            'assets/images/list.png',
            height: 20,
            width: 20,
          ),
          SizedBox(width: 10),
          Text(
            'ใบสั่งงาน',
            style: commonHeaderLabelStyle,
          ),
          _processWorkCountBox('15'),
          _doingWorkButton(ctx)
        ],
      ),
      SizedBox(
        height: 16,
      ),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: ListView.builder(
                  key: PageStorageKey<String>('pageOne'),
                  itemCount: histories.length,
                  itemBuilder: (BuildContext context, int index) {
                    HistoryModel historieList = histories[index];
                    return Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _showDialog(context);
                          },
                          child: Container(
                              height: 105,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: 12.0, right: 5.0, top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/images/clipboard.png',
                                                height: 20,
                                                width: 20,
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                '${historieList.title}',
                                                style: TextStyle(
                                                  fontFamily: 'Athiti',
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                              width: 90,
                                              padding: const EdgeInsets.only(
                                                  left: 3,
                                                  right: 3,
                                                  top: 0,
                                                  bottom: 0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: historieList.isCancel
                                                      ? Color.fromRGBO(
                                                          92, 184, 92, 1)
                                                      : Color.fromRGBO(
                                                          92, 184, 92, 1)),
                                              child: Center(
                                                child: Text(
                                                  historieList.status ??
                                                      'status',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontFamily: 'Athiti',
                                                  ),
                                                ),
                                              ))
                                        ],
                                      )),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 41.0, right: 5.0, top: 3),
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('◉ รับเข้า BP01 (สายบางปลา)',
                                            style: TextStyle(
                                                fontFamily: 'Athiti',
                                                color: historieList.isComing
                                                    ? Color.fromRGBO(
                                                        92, 184, 92, 1)
                                                    : Color.fromRGBO(
                                                        255, 0, 0, 1),
                                                fontSize: 12)),
                                        Text('◉ ทะเบียนรถ: 75-6097 (CB-20)',
                                            style: TextStyle(
                                              fontFamily: 'Athiti',
                                              fontSize: 12,
                                            )),
                                        Text(
                                          '◉ วันที่ปฏิบัติงาน: 02 ก.ค. 2564 08:00 น.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Athiti',
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  })))
    ]),
  );
}

Expanded _doingWorkButton(context) {
  return Expanded(
      child: GestureDetector(
    onTap: () {
      _goProgess(context);
    },
    child: Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color.fromRGBO(240, 173, 78, 1)),
        child: Text(
          'กำลังดำเนินการ',
          style: commonHeaderButtonDoingTextStyle,
        ),
      ),
    ),
  ));
}

Container _currentJob() {
  return Container(
    child: Center(
      child: Text('2'),
    ),
  );
}

void _showDialog(context) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 125, left: 40, right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'ตรวจสอบเลขไมล์ก่อนเปิดงาน',
                          style: callDialogBlueTextStyle,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'ทะเบียนรถ: TEST',
                          style: callDialogBlackTextStyle,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'เลขไมล์เริ่มต้น: TEST',
                          style: callDialogBlackTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(137, 137, 137, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'ปิด',
                                  style: buttonDialogTextStyle,
                                ),
                              ),
                            )),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            _goProgess(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(1, 84, 155, 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.zero,
                                topRight: Radius.zero,
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'เริ่มทำงาน',
                                style: buttonDialogTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

void _goProgess(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProcessWork()),
  );
}

Container _processWorkCountBox(numText) {
  return Container(
    margin: EdgeInsets.only(left: 5),
    padding: EdgeInsets.symmetric(horizontal: 4.0),
    decoration: BoxDecoration(
        color: Color.fromRGBO(161, 161, 161, 1),
        borderRadius: BorderRadius.circular(3)),
    child: Text(
      numText,
      style: doingWorkCountBoxTextStyle,
    ),
  );
}
