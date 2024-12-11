import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quoter/l10n/app_localizations.dart';
import 'package:routemaster/routemaster.dart';

class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabState = CupertinoTabPage.of(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            label: l10n.quotesBottomNavigationBarItemLabel,
            icon: const Icon(Icons.format_quote),
          ),
          BottomNavigationBarItem(
            label: l10n.profileBottomNavigationBarItemLabel,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      tabBuilder: tabState.tabBuilder,
      controller: tabState.controller,
    );
  }
}
