import 'package:flutter/material.dart';
import 'package:pgc/screens/confirmfinishjob.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/passenger.dart';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/widgets/commonsmallprocessbackground.dart';

class ScanAndList extends StatefulWidget {
  @override
  _ScanAndListState createState() => _ScanAndListState();
}

class _ScanAndListState extends State<ScanAndList> {
  int _selectedPage = 0;
  PageController _pageController;
  String status = '';
  List<PassengerModel> passengers = [
    PassengerModel('นาย A', 'เข็นรถ', '12.00 น.'),
    PassengerModel('นาย B', 'ทำครัว', '10.00 น.'),
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
    /*  Future.delayed(Duration.zero, () {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
    }); */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
    });
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
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20),
                child: BackPressInContainer(context),
              ),
              SizedBox(height: 15),
              Expanded(
                  child: Container(
                decoration: commonBackgroundStyle,
                margin: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      CommonSmallProcessBackground(),
                      Container(
                        height: 50,
                        decoration: tabbuttonBackground,
                        margin:
                            EdgeInsets.only(left: 10.0, right: 10.0, top: 15),
                        padding: EdgeInsets.only(left: 7.0, right: 7.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: TabButton(
                                      text: 'สแกน',
                                      fontSize: 15,
                                      pageNumber: 0,
                                      selectedPage: _selectedPage,
                                      onPressed: () {
                                        _changePage(0);
                                      },
                                      haveNumText: false,
                                      numText: '0')),
                              Expanded(
                                  child: TabButton(
                                      text: 'ขึ้นรถแล้ว',
                                      fontSize: 15,
                                      pageNumber: 1,
                                      selectedPage: _selectedPage,
                                      onPressed: () {
                                        _changePage(1);
                                      },
                                      haveNumText: true,
                                      numText: '15'))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          children: [
                            _scanPage(context, status),
                            _arrivedPassengerListPage(passengers)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ],
      ),
    ));
  }
}

Container _scanPage(context, status) {
  return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.black),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          _endScanButton(context, status)
        ],
      ));
}

Container _arrivedPassengerListPage(passengers) {
  return Container(
      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: ListView.builder(
              key: PageStorageKey<String>('arrivedPassengerListPage'),
              itemCount: passengers.length,
              itemBuilder: (BuildContext context, int index) {
                PassengerModel passengersList = passengers[index];
                return Column(
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                                width: 1.5,
                                color: Color.fromRGBO(242, 242, 242, 1)),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                top: 2.0,
                                left: 4.0,
                                right: 5.0,
                                bottom: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${passengersList.fullname}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            arrivedPassengerListNameTextStyle,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        '${passengersList.department}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            arrivedPassengerListDepartmentTextStyle,
                                      )
                                    ],
                                  )),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${passengersList.arriveTime}',
                                        style:
                                            arrivedPassengerListTimeTextStyle,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text('',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              arrivedPassengerListDepartmentTextStyle)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                );
              })));
}

GestureDetector _endScanButton(context, status) {
  return GestureDetector(
    onTap: () {
      _goConfirmFinishJob(context, status);
    },
    child: Container(
      height: 60,
      decoration: endScanButtonStyle,
      child: Center(
        child: Text(
          'สิ้นสุดการสแกน',
          style: endScanTextStyle,
        ),
      ),
    ),
  );
}

void _backPress(context) {
  Navigator.pop(context);
}

GestureDetector _backButton(context) {
  return GestureDetector(
    onTap: () {
      _backPress(context);
    },
    child: Image.asset(
      'assets/images/backarrow.png',
      height: 25,
    ),
  );
}

void _goConfirmFinishJob(context, status) {
  print(status);
  if (status == 'finished') {
    Navigator.pop(context);
  } else if (status == 'non-success') {
    Navigator.pop(context);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmFinishJob()),
    );
  }
}
