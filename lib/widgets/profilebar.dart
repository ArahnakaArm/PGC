import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart' as badges;

class ProfileBar extends StatefulWidget {
  @override
  _ProfileBarState createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              CircleAvatar(
                radius: 23.0,
                backgroundImage: NetworkImage(
                    'https://s.isanook.com/ga/0/rp/rc/w700h366/yacxacm1w0/aHR0cHM6Ly9zLmlzYW5vb2suY29tL2dhLzAvdWQvMjIxLzExMDU0NzMvYmFhbF8yLmpwZw==.jpg'),
              ),
              SizedBox(width: 15),
              Text(
                'Raiden Shogun',
                style: profileNameStyle,
              ),
            ],
          ),
          Row(
            children: [
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -5, end: -6),
                toAnimate: false,
                shape: badges.BadgeShape.circle,
                badgeColor: Color.fromRGBO(255, 0, 0, 1),
                borderRadius: BorderRadius.circular(8),
                badgeContent: Container(
                  width: 8,
                  height: 8,
                  alignment: Alignment.center,
                  child: Text(
                    '14',
                    style: TextStyle(color: Colors.white, fontSize: 7),
                  ),
                ),
                child: Icon(
                  Icons.add_alert,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.settings,
                color: Colors.white,
                size: 35,
              ),
            ],
          ),
        ]);
  }
}
