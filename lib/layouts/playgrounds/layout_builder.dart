import 'package:flutter/cupertino.dart';

class PlaygroundsResponsiveLayoutBuilder {
  final Widget mobileScaffold;
  final Widget tabletScaffold;
  final Widget desktopScaffold;

  PlaygroundsResponsiveLayoutBuilder({
    required this.mobileScaffold,
    required this.tabletScaffold,
    required this.desktopScaffold,
  });

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (constraints.maxWidth < 500) {
          //Mobile View
          return mobileScaffold;
        } else if (constraints.maxWidth < 1100) {
          //Tablet View
          return tabletScaffold;
        } else {
          return desktopScaffold;
        }
      },
    );
  }
}
