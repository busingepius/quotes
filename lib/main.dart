import 'dart:async';
import 'dart:isolate';
import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quoter/l10n/app_localizations.dart';
import 'package:quoter/routing_table.dart';
import 'package:routemaster/routemaster.dart';

import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:flutter/material.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:quoter/screen_view_observer.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart'; 

void main() {
  // Has to be late so it doesn't instantiate before the 'initializeMonitoringPackage()' call
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeMonitoringPackage();

      final remoteValueService = RemoteValueService();
      await remoteValueService.load();

      FlutterError.onError = errorReportingService.recordFlutterError;

      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await errorReportingService.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      runApp(
        Quoter(
          remoteValueService: remoteValueService,
        ),
      );
    },
    (error, stack) => errorReportingService.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class Quoter extends StatefulWidget {
  final RemoteValueService remoteValueService;

  const Quoter({required this.remoteValueService, super.key});

  @override
  State<Quoter> createState() => _QuoterState();
}

class _QuoterState extends State<Quoter> {
  final _keyValueStorage = KeyValueStorage();
  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();
  late final _favQsApi = FavQsApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );
  late final UserRepository _userRepository = UserRepository(
    remoteApi: _favQsApi,
    noSqlStorage: _keyValueStorage,
  );
  late final _quoteRepository = QuoteRepository(
    remoteApi: _favQsApi,
    keyValueStorage: _keyValueStorage,
  );
  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
    observers: [
      ScreenViewObserver(analyticsService: _analyticsService),
    ],
    routesBuilder: (context) {
      return RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          userRepository: _userRepository,
          quoteRepository: _quoteRepository,
          remoteValueService: widget.remoteValueService,
          dynamicLinkService: _dynamicLinkService,
        ),
      );
    },
  );

  final _lightTheme = LightQuoterThemeData();
  final _darkTheme = DarkQuoterThemeData();
  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();
    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _routerDelegate.push,
            );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DarkModePreference>(
      stream: _userRepository.getDarkModePreference(),
      builder: (context, snapshot) {
        final darkModePreference = snapshot.data;

        return QuoterTheme(
          lightTheme: _lightTheme,
          darkTheme: _darkTheme,
          child: MaterialApp.router(
            theme: _lightTheme.materialThemeData,
            darkTheme: _darkTheme.materialThemeData,
            themeMode: darkModePreference?.toThemeMode(),
            supportedLocales: const [
              Locale('en', ''),
              Locale('pt', 'BR'),
            ],
            localizationsDelegates: const[
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              AppLocalizations.delegate,
              ComponentLibraryLocalizations.delegate,
              ProfileMenuLocalizations.delegate,
              QuoteListLocalizations.delegate,
              SignInLocalizations.delegate,
              ForgotMyPasswordLocalizations.delegate,
              SignUpLocalizations.delegate,
              UpdateProfileLocalizations.delegate,
            ],
            routerDelegate: _routerDelegate,
            routeInformationParser: const RoutemasterParser(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}
