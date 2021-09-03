import 'package:pgc/responseModel/buslistinfo.dart';

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
  var formatedDay = date.toString().substring(8, 10);
  var formatedYear =
      (int.parse(date.toString().substring(0, 4)) + 543).toString();

  var formatedHour =
      (int.parse(date.toString().substring(11, 13)) + 7).toString();
  if (int.parse(formatedHour) < 10) {
    formatedHour = '0${formatedHour.toString()}';
  }

  var formatedMinute = date.toString().substring(14, 16);
  return '${formatedDay} ${formatedMonth} ${formatedYear} ${formatedHour}:${formatedMinute} น.';

/*   return formatedMonth; */
}

List<ResultDatum> ChangeDateFormatBusInfoList(List<ResultDatum> list) {
  for (int i = 0; i < list.length; i++) {
    list[i].newDateFormat = ChangeFormatDateToTH(list[i].tripDatetime);
  }

  return list;
}
