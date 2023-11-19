import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String text;
  final int selectedPage;
  final int pageNumber;
  final Function onPressed;
  final bool haveNumText;
  final String numText;
  final double fontSize;
  TabButton(
      {required this.text,
      required this.selectedPage,
      required this.pageNumber,
      required this.onPressed,
      required this.haveNumText,
      required this.numText,
      required this.fontSize});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed(),
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
        decoration: BoxDecoration(
          color: selectedPage == pageNumber ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(23.0),
          boxShadow: [
            BoxShadow(
              color: selectedPage == pageNumber
                  ? Color.fromRGBO(0, 0, 0, 0.1)
                  : Color.fromRGBO(0, 0, 0, 0),
              spreadRadius: selectedPage == pageNumber ? 0 : 0,
              blurRadius: selectedPage == pageNumber ? 18.91 : 0,
              offset: selectedPage == pageNumber
                  ? Offset(1.89, 5.67)
                  : Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              child: Text(
                text ?? 'Tab Button',
                style: TextStyle(
                    fontFamily: 'Athiti',
                    fontSize: fontSize,
                    color: selectedPage == pageNumber
                        ? Color.fromRGBO(75, 132, 241, 1)
                        : Color.fromRGBO(81, 82, 82, 1)),
              ),
            ),
            haveNumText
                ? Container(
                    margin: EdgeInsets.only(left: 5),
                    padding:
                        EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(92, 184, 92, 1),
                        borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      numText,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Athiti',
                          fontSize: 12),
                    ),
                  )
                : Container(width: 0, height: 0),
          ],
        ),
      ),
    );
  }
}
