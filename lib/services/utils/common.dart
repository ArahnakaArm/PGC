import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/buslistinfo.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';

String ChangeFormatDateToTH(date) {
  var monthTh = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];

  var formatedMonth = monthTh[int.parse(date.toString().substring(5, 7)) - 1];

  var formatedYear =
      (int.parse(date.toString().substring(0, 4)) + 543).toString();

  var hour = date.toString().substring(11, 13);
  var addedHour = int.parse(hour) + 7;

  var day = date.toString().substring(8, 10);
  var addedDay;
  var formatedHour;
  if (addedHour > 24) {
    addedDay = int.parse(day) + 1;
    formatedHour = addedHour % 24;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  } else {
    addedDay = day;
    formatedHour = addedHour;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  }
  var formatedDay = addedDay.toString();
  var formatedMinute = date.toString().substring(14, 16);
  return '${formatedDay} ${formatedMonth} ${formatedYear} ${formatedHour}:${formatedMinute} น.';

/*   return formatedMonth; */
}

String ChangeFormaTimeDateTH(date) {
  var monthTh = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];

  var formatedMonth = monthTh[int.parse(date.toString().substring(5, 7)) - 1];

  var formatedYear =
      (int.parse(date.toString().substring(0, 4)) + 543).toString();

  var hour = date.toString().substring(11, 13);
  var addedHour = int.parse(hour) + 7;

  var day = date.toString().substring(8, 10);
  var addedDay;
  var formatedHour;
  if (addedHour > 24) {
    addedDay = int.parse(day) + 1;
    formatedHour = addedHour % 24;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  } else {
    addedDay = day;
    formatedHour = addedHour;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  }
  var formatedDay = addedDay.toString();
  var formatedMinute = date.toString().substring(14, 16);
  return '${formatedHour}:${formatedMinute} น.';

/*   return formatedMonth; */
}

String ChangeFormatDateToTHNoTime(date) {
  var monthTh = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];

  var formatedMonth = monthTh[int.parse(date.toString().substring(5, 7)) - 1];

  var formatedYear =
      (int.parse(date.toString().substring(0, 4)) + 543).toString();

  var hour = date.toString().substring(11, 13);
  var addedHour = int.parse(hour) + 7;

  var day = date.toString().substring(8, 10);
  var addedDay;
  var formatedHour;
  if (addedHour > 24) {
    addedDay = int.parse(day) + 1;
    formatedHour = addedHour % 24;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  } else {
    addedDay = day;
    formatedHour = addedHour;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  }
  var formatedDay = addedDay.toString();
  var formatedMinute = date.toString().substring(14, 16);
  return '${formatedDay} ${formatedMonth} ${formatedYear}';

/*   return formatedMonth; */
}

String ChangeFormatDateToTHLocal(date) {
  var monthTh = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];

  var monthThShort = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.'
  ];

  var formatedMonth =
      monthThShort[int.parse(date.toString().substring(5, 7)) - 1];

  var formatedYear =
      (int.parse(date.toString().substring(0, 4)) + 543).toString();

  var hour = date.toString().substring(11, 13);
  var addedHour = int.parse(hour);

  var day = date.toString().substring(8, 10);
  var addedDay;
  var formatedHour;
  if (addedHour > 24) {
    addedDay = int.parse(day) + 1;
    formatedHour = addedHour % 24;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  } else {
    addedDay = day;
    formatedHour = addedHour;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  }
  var formatedDay = addedDay.toString();
  var formatedMinute = date.toString().substring(14, 16);
  return '${formatedDay} ${formatedMonth} ${formatedYear} ${formatedHour}:${formatedMinute} น.';

/*   return formatedMonth; */
}

String ChangeFormateDateTimeToTime(dateTime) {
  var time = dateTime.toString().substring(11, 16);

  return time;
}

String ChangeFormateDateTimeToTimeAddHour(dateTime) {
  var time = dateTime.toString().substring(11, 16);
  var hour = dateTime.toString().substring(11, 13);
  var minute = dateTime.toString().substring(14, 16);
  var addedHour = int.parse(hour) + 7;

  var day = dateTime.toString().substring(8, 10);
  var addedDay;
  var formatedHour;
  if (addedHour > 24) {
    addedDay = int.parse(day);
    formatedHour = addedHour % 24;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  } else {
    addedDay = day;
    formatedHour = addedHour;
    if (formatedHour < 10) {
      formatedHour = "0" + formatedHour.toString();
    } else {
      formatedHour = formatedHour.toString();
    }
  }

  return formatedHour + ":" + minute;
}

List<ResultDatum> ChangeDateFormatBusInfoList(List<ResultDatum> list) {
  for (int i = 0; i < list.length; i++) {
    list[i].newDateFormat = ChangeFormatDateToTH(list[i].tripDatetime);
  }

  return list;
}

Future<String> getNotificationsCount() async {
  final storage = new FlutterSecureStorage();
  String token = await storage.read(key: 'token');
  String userId = await storage.read(key: 'userId');

  var queryString = "?is_read=false&receiver_id=${userId}";
  var getNotificationsCountUrl = Uri.parse(
      '${dotenv.env['BASE_API']}${dotenv.env['GET_NOTIFICATION']}${queryString}');

  var getNotificationsCountRes =
      await getHttpWithToken(getNotificationsCountUrl, token);

  var count = jsonDecode(getNotificationsCountRes)['rowCount'] as int;
  print(count.toString());
  return count.toString();
}

String convertToAgo(String input) {
  Duration diff = DateTime.now()
      .difference(DateTime.parse(input).add(new Duration(hours: 7)));

  if (diff.inDays >= 1) {
    return '${diff.inDays} วันที่แล้ว';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours} ชั่วโมงที่แล้ว';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} นาทีที่แล้ว';
  } else if (diff.inSeconds >= 1) {
    return '${diff.inSeconds} วินาทีที่แล้ว';
  } else {
    return 'เมื่อซักครู่';
  }
}
