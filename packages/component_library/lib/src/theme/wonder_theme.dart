import 'package:component_library/src/theme/wonder_theme_data.dart';
import 'package:flutter/material.dart';

class QuoterTheme extends InheritedWidget {
  const QuoterTheme({
    required Widget child,
    required this.lightTheme,
    required this.darkTheme,
    Key? key,
  }) : super(
          key: key,
          child: child,
        );

  final QuoterThemeData lightTheme;
  final QuoterThemeData darkTheme;

  @override
  bool updateShouldNotify(
    QuoterTheme oldWidget,
  ) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;

  static QuoterThemeData of(BuildContext context) {
    final QuoterTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<QuoterTheme>();
    assert(inheritedTheme != null, 'No WonderTheme found in context');
    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedTheme!.darkTheme
        : inheritedTheme!.lightTheme;
  }
}
