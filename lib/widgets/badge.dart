import 'package:flutter/material.dart';
class Badge extends StatelessWidget {
  final double top;
  final double right;
  final Widget child; // our Badge widget will wrap this child widget
  final String value; // what displays inside the badge
  final Color color; // the  background color of the badge - default is red

Badge(
      {@required this.child,
      @required this.value,
      this.color,
      @required this.top,
      @required this.right});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: right,
          top: top,
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color != null ? color : Colors.red,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color:Colors.white
              ),
            ),
          ),
        )
      ],
    );
  }
}