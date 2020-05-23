import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../routing/routeNames.dart';
import '../widgets/fabBottomAppBar.dart';
import '../models/textRes.dart';


class NavBarItem extends StatelessWidget {
  final String title;
  final String navigationPath;
  const NavBarItem(this.title, this.navigationPath);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // DON'T EVER USE A SERVICE DIRECTLY IN THE UI TO CHANGE ANY KIND OF STATE
        // SERVICES SHOULD ONLY BE USED FROM A VIEWMODEL
        locator<NavigationService>().navigateTo(navigationPath);
      },
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FAB_Bar();
    /*
    return ScreenTypeLayout(
      mobile: NavigationBarMobile(),
      tablet: NavigationBarTabletDesktop(),
    );
    */
  }
}

class FAB_Bar extends StatelessWidget {
  const FAB_Bar({Key key}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    List<FABBottomAppBarItem> children = [];
    for(int i = 0; i < Routes.length; i++) {
      children.add(FABBottomAppBarItem(iconData: Routes[i].iconData, text: Routes[i].label));  //children.add(SizedBox(width: 60,));
    }
    
    return FABBottomAppBar(
          //centerItemText: _fabText,
          backgroundColor: MEMO_COLORS[0],
          selectedBackgroundColor: MEMO_COLORS[2],
          selectedColor: Colors.black,
          color: Colors.black,
          //notchedShape: _isFabShow ? CircularNotchedRectangle() : null,
          
          onTabSelected: (_selectedTab) {
            //print('Selected Tab $_selectedTab');
            locator<NavigationService>().navigateTo('/'+Routes[_selectedTab].route);
            },
          items: children
        );
  }
}

class NavigationBarMobile extends StatelessWidget {
  const NavigationBarMobile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          NavBarLogo()
        ],
      ),
    );
  }
}

class NavigationBarTabletDesktop extends StatelessWidget {
  const NavigationBarTabletDesktop({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for(int i = 0; i < Routes.length; i++) {
      children.add(Expanded(flex: 1, child:NavBarItem(Routes[i].label, Routes[i].route)));
      //children.add(SizedBox(width: 60,));
    }
    return Container(
      height: 100,
      child: Row(
        children: children,
        /*
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          NavBarLogo(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        ],
        */
      ),
    );
  }
}

class NavBarLogo extends StatelessWidget {
  const NavBarLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 150,
      child: Image.asset('assets/logo.png'),
    );
  }
}