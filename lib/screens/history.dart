import 'package:flutter/material.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<HistoryModel> histories = [
    HistoryModel('TRIP-2021-0002', true, true, 'ให้บริการสำเร็จ'),
    HistoryModel('TRIP-2021-0001', false, false, 'ยกเลิก')
  ];

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _headerWidget('assets/images/list.png', 'ประวัติงาน'),
                  SizedBox(
                    height: 16,
                  ),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: ListView.builder(
                              itemCount: histories.length,
                              itemBuilder: (BuildContext context, int index) {
                                HistoryModel historieList = histories[index];
                                return Column(
                                  children: <Widget>[
                                    Container(
                                        height: 105,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 12.0,
                                                    right: 5.0,
                                                    top: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Image.asset(
                                                          'assets/images/clipboard.png',
                                                          height: 15,
                                                          width: 15,
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          '${historieList.title}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Athiti',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                        width: 90,
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 3,
                                                                right: 3,
                                                                top: 0,
                                                                bottom: 0),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: historieList
                                                                    .isCancel
                                                                ? Color
                                                                    .fromRGBO(
                                                                        137,
                                                                        137,
                                                                        137,
                                                                        1)
                                                                : Color
                                                                    .fromRGBO(
                                                                        192,
                                                                        192,
                                                                        192,
                                                                        1)),
                                                        child: Center(
                                                          child: Text(
                                                            historieList
                                                                    .status ??
                                                                'status',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Athiti',
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ))
                                                  ],
                                                )),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 41.0,
                                                  right: 5.0,
                                                  top: 3),
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      '◉ รับเข้า BP01 (สายบางปลา)',
                                                      style: TextStyle(
                                                          fontFamily: 'Athiti',
                                                          color: historieList
                                                                  .isComing
                                                              ? Color.fromRGBO(
                                                                  92,
                                                                  184,
                                                                  92,
                                                                  1)
                                                              : Color.fromRGBO(
                                                                  255, 0, 0, 1),
                                                          fontSize: 12)),
                                                  Text(
                                                      '◉ ทะเบียนรถ: 75-6097 (CB-20)',
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
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                );
                              })))
                ],
              )),
        ],
      ),
    ));
  }
}

Container _headerWidget(imagePath, headerText) {
  return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Row(
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 20,
            width: 20,
          ),
          SizedBox(width: 10),
          Text(
            headerText,
            style: commonHeaderLabelStyle,
          )
        ],
      ));
}
