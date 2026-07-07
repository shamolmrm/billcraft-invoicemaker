import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/invoices/invoice_list_screen.dart';
import '../../screens/invoices/create_invoice_screen.dart';
import '../../screens/invoices/invoice_detail_screen.dart';
import '../../screens/invoices/invoice_preview_screen.dart';
import '../../screens/estimates/estimate_list_screen.dart';
import '../../screens/estimates/create_estimate_screen.dart';
import '../../screens/estimates/estimate_detail_screen.dart';
import '../../screens/clients/client_list_screen.dart';
import '../../screens/clients/add_client_screen.dart';
import '../../screens/clients/client_detail_screen.dart';
import '../../screens/items/item_list_screen.dart';
import '../../screens/items/add_item_screen.dart';
import '../../screens/templates/template_picker_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/business_profile_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/more/more_screen.dart';
import '../../screens/language/language_select_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.languageSelect,
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: RouteNames.main,
          redirect: (_, __) => RouteNames.dashboard,
        ),
        GoRoute(
          path: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.invoiceList,
          builder: (context, state) => const InvoiceListScreen(),
        ),
        GoRoute(
          path: RouteNames.estimateList,
          builder: (context, state) => const EstimateListScreen(),
        ),
        GoRoute(
          path: RouteNames.clientList,
          builder: (context, state) => const ClientListScreen(),
        ),
        GoRoute(
          path: RouteNames.itemList,
          builder: (context, state) => const ItemListScreen(),
        ),
        GoRoute(
          path: RouteNames.more,
          builder: (context, state) => const MoreScreen(),
        ),
        GoRoute(
          path: RouteNames.reports,
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.createInvoice,
      builder: (context, state) => const CreateInvoiceScreen(),
    ),
    GoRoute(
      path: '${RouteNames.editInvoice}/:id',
      builder: (context, state) =>
          CreateInvoiceScreen(invoiceId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '${RouteNames.invoiceDetail}/:id',
      builder: (context, state) =>
          InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RouteNames.invoicePreview,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return InvoicePreviewScreen(invoiceId: extra?['invoiceId'] ?? '');
      },
    ),
    GoRoute(
      path: RouteNames.createEstimate,
      builder: (context, state) => const CreateEstimateScreen(),
    ),
    GoRoute(
      path: '${RouteNames.estimateDetail}/:id',
      builder: (context, state) =>
          EstimateDetailScreen(estimateId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RouteNames.addClient,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddClientScreen(clientId: extra?['clientId']);
      },
    ),
    GoRoute(
      path: '${RouteNames.clientDetail}/:id',
      builder: (context, state) =>
          ClientDetailScreen(clientId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: RouteNames.addItem,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddItemScreen(itemId: extra?['itemId']);
      },
    ),
    GoRoute(
      path: RouteNames.templatePicker,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return TemplatePickerScreen(
          currentTemplate: extra?['currentTemplate'] ?? 'modern',
          onTemplateSelected: extra?['onTemplateSelected'],
        );
      },
    ),
    GoRoute(
      path: RouteNames.businessProfile,
      builder: (context, state) => const BusinessProfileScreen(),
    ),
  ],
);
