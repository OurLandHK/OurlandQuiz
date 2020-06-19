import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/textRes.dart';
import '../models/userModel.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';

class AvatarMemo extends StatelessWidget {
  final User user;
  AvatarMemo(this.user);

   void _onTap() async {
      locator<NavigationService>().navigateTo('/${MainRoutes[3].route}/${user.id}');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double fontSize = 10;
    double smallFontSize = fontSize/2;
    List<Widget> widgets = [Icon(Icons.person, size: width/15)];
    widgets.add(Row(children:[Text(user.name, style: TextStyle(fontSize: fontSize))]));
    Widget rv = GestureDetector(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: MEMO_COLORS[user.id.hashCode % MEMO_COLORS.length],
                border: Border.all(width: 1, color: Colors.grey),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    offset: new Offset(0.0, 2.5),
                    blurRadius: 4.0,
                    spreadRadius: 0.0
                  )
                ],
                //borderRadius: BorderRadius.circular(6.0)
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets
              ),
            ),
          ),
        );
    return rv;
  }
}
