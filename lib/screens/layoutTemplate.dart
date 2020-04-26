import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../locator.dart';
import '../routing/routeNames.dart';
import '../routing/router.dart';
import '../services/navigationService.dart';
import '../widgets/centeredView.dart';
import '../widgets/navigationBar.dart';
import '../widgets/navigationDrawer.dart';

class LayoutTemplate extends StatelessWidget {
  const LayoutTemplate({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) { 
        Scaffold scaffold = Scaffold(
          drawer: NavigationDrawer(),
          backgroundColor: Colors.white,
          body: CenteredView(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Navigator(
                    key: locator<NavigationService>().navigatorKey,
                    onGenerateRoute: generateRoute,
                    initialRoute: Routes[0],
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: sizingInformation.deviceScreenType == DeviceScreenType.Mobile ?
          NavigationBar(): null,
        );
        return scaffold;
      }
    );
  }
}