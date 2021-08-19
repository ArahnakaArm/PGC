import 'package:flutter/material.dart';
import 'package:pgc/model/process.dart';
import 'package:pgc/screens/checkin.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';

class ProcessWork extends StatefulWidget {
  const ProcessWork({Key key}) : super(key: key);

  @override
  _ProcessWorkState createState() => _ProcessWorkState();
}

class _ProcessWorkState extends State<ProcessWork> {
  List<ProcessModel> process = [
    ProcessModel('Location A', '7.00', false, 8, 7, 'finished'),
    ProcessModel('Location B', '15.00', false, 8, 7, 'waiting'),
    ProcessModel('Location C', '17.00', true, 8, 7, 'todo'),
    ProcessModel('Location D', '19.00', true, 8, 7, 'success'),
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
                  _headerWidget('assets/images/list.png', 'ใบสั่งงาน'),
                  SizedBox(
                    height: 16,
                  ),
                  _workInfoBox(110.0),
                  SizedBox(
                    height: 10,
                  ),
                  _workListBox(process)
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

Container _workInfoBox(heigth) {
  return Container(
    height: heigth,
    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
    margin: EdgeInsets.only(left: 20.0, right: 20.0),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset(
              'assets/images/clipboard.png',
              height: 20,
              width: 20,
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
                child: Text(
              'TRIP_NAME',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: jobTitleProcessWordTextStyle,
            )),
            _statusBar('กำลังให้บริการ')
          ],
        ),
        Container(
          padding: EdgeInsets.only(left: 31.0, right: 15.0, top: 6),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    '• รับเข้า BP01 (สายบางปลา)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: workInfoFirstTextStyle,
                  ))
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text('• ทะเบียนรถ: 75-6097 (CB-20)',
                          style: workInfoTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis))
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text('• วันที่ปฏิบัติงาน: 02 ก.ค. 2564 08:00 น.',
                          style: workInfoTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis))
                ],
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Expanded _workListBox(process) {
  return Expanded(
      child: Container(
    padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
    margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Column(
      children: <Widget>[
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เลขไมล์เริ่มต้น : 5000'),
              Container(
                margin: EdgeInsets.only(top: 4, left: 5),
                child: Image.asset(
                  'assets/images/pencil.png',
                  height: 12,
                  width: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: ListView.builder(
                    key: PageStorageKey<String>('pageOne5'),
                    itemCount: process.length,
                    itemBuilder: (BuildContext context, int index) {
                      ProcessModel processList = process[index];
                      return Column(
                        children: <Widget>[getBox(processList.status, context)],
                      );
                    })))
      ],
    ),
  ));
}

Container _statusBar(text) {
  return Container(
    padding: EdgeInsets.only(left: 7, right: 7, bottom: 1.5),
    decoration: BoxDecoration(
        color: Color.fromRGBO(51, 154, 223, 1),
        borderRadius: BorderRadius.circular(8)),
    child: Center(
      child: Text(
        text,
        style: statusBarTextStyle,
      ),
    ),
  );
}

Widget getBox(status, context) {
  if (status == 'finished')
    return _finishedBox(context);
  else if (status == 'waiting')
    return _waitingBox(context);
  else if (status == 'todo')
    return _todoBox();
  else if (status == 'success') return _successBox(context);
}

GestureDetector _finishedBox(context) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context, 'finished');
    },
    child: Container(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _verticleWhiteLine(),
              _circleImage(10.0, 10.0, 'assets/images/correct.png',
                  Color.fromRGBO(92, 184, 92, 1)),
              _verticleLine()
            ],
          ),
          _processInfo(),
          _processTime()
        ],
      ),
    ),
  );
}

GestureDetector _waitingBox(context) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      _goCheckIn(context, 'non-success');
    },
    child: Container(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _verticleLine(),
              _circleImage(10.0, 10.0, 'assets/images/hourglass.png',
                  Color.fromRGBO(92, 184, 92, 1)),
              _verticleLine()
            ],
          ),
          _processInfo(),
          _processTime()
        ],
      ),
    ),
  );
}

Container _todoBox() {
  return Container(
    height: 70,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            _verticleLine(),
            _circleImage(10.0, 10.0, 'assets/images/pin.png', Colors.red),
            _verticleLine()
          ],
        ),
        _processInfo(),
        _processTime()
      ],
    ),
  );
}

GestureDetector _successBox(context) {
  return GestureDetector(
    onTap: () {
      _goCheckIn(context, 'success');
    },
    child: Container(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _verticleLine(),
              _circleImage(10.0, 10.0, 'assets/images/flag.png', Colors.red),
              _verticleWhiteLine()
            ],
          ),
          _processInfo(),
          _processTime()
        ],
      ),
    ),
  );
}

Container _circleImage(horizontal, verticle, imagePath, color) {
  return Container(
    width: 32,
    height: 32,
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: verticle),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Container(
      child: Image.asset(
        imagePath,
      ),
    ),
  );
}

Expanded _verticleLine() {
  return Expanded(
      child: Container(
          child: VerticalDivider(
    color: Colors.black,
    thickness: 3,
  )));
}

Expanded _verticleWhiteLine() {
  return Expanded(
      child: Container(
          child: VerticalDivider(
    color: Colors.white,
    thickness: 3,
  )));
}

Expanded _processInfo() {
  return Expanded(
      child: Container(
    padding: EdgeInsets.only(left: 10, top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'หอพักสุทินบางปลา',
          style: processBoxHeaderTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          'รับ 3 คน จาก 5 คน',
          style: processBoxSubHeaderTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
    ),
  ));
}

Container _processTime() {
  return Container(
    padding: EdgeInsets.only(top: 16),
    child: Text(
      'Checkin: TEST',
      style: timeTextStyle,
    ),
  );
}

void _goCheckIn(context, status) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckIn(),
      settings: RouteSettings(
        arguments: status,
      ),
    ),
  );
}

void _goScanAndList(context, status) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ScanAndList(),
      settings: RouteSettings(
        arguments: status,
      ),
    ),
  );
}
