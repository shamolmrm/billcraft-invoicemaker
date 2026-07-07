import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/routes/app_router.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/client_provider.dart';
import 'providers/item_provider.dart';
import 'providers/business_provider.dart';

class BillCraftApp extends StatelessWidget {
  const BillCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, InvoiceProvider>(
          create: (_) => InvoiceProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? InvoiceProvider();
            provider.loadForUser(auth.isLoggedIn ? auth.userId : null);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ClientProvider>(
          create: (_) => ClientProvider(),
          update: (_, auth, prev) {
            final provider = prev ?? ClientProvider();
            provider.loadForUser(auth.isLoggedIn ? auth.userId : null);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'BillCraft',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}
