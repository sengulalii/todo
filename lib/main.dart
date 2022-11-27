import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:klocalizations_flutter/klocalizations_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:todo/notification/local_notification.dart';
import 'package:todo/services/abstract_create_service.dart';
import 'package:todo/services/abstract_db_service.dart';
import 'package:todo/services/abstract_login_service.dart';
import 'package:todo/services/firebase_create_service.dart';
import 'package:todo/services/firebase_db_service.dart';
import 'package:todo/services/firebase_login_service.dart';
import 'package:todo/view/auth_page.dart';
import 'package:todo/view/home_page.dart';
import 'package:todo/view_model/select_viewmodel.dart';
import 'package:todo/view_model/sf_calendar.dart';
import 'package:todo/view_model/task_crud_viewmodel.dart';
import 'package:todo/view_model/create_viewmodel.dart';
import 'package:todo/view_model/login_viewmodel.dart';
import 'package:timezone/data/latest.dart' as tz;

AbstractLoginService loginService = FirebaseLoginService();
AbstractCreateService createService = FirebaseCreateService();
AbstractDbService taskService = FirebaseDbService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<CreateViewModel>(create: (_) => CreateViewModel()),
      ChangeNotifierProvider<LoginViewModel>(create: (_) => LoginViewModel()),
      ChangeNotifierProvider<TaskViewModel>(create: (_) => TaskViewModel()),
      ChangeNotifierProvider<Notifications>(create: (_) => Notifications()),
      ChangeNotifierProvider<Meeting>(create: (_) => Meeting()),
      ChangeNotifierProvider<SelectItem>(create: (_) => SelectItem()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget homeWidget;
  @override
  void initState() {
    createHomeWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate, //cupertino çalıştırır
        // ... app-specific localization delegate[s] here
      ],
      //ignore: always_specify_types
      supportedLocales: const [
        Locale('tr'),
        // ... other locales the app supports
      ],
      locale: const Locale('tr'),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homeWidget,
    );
  }

  void createHomeWidget() {
    bool result =
        Provider.of<LoginViewModel>(context, listen: false).checkLogin();
    if (result == true) {
      homeWidget = const HomePage();
    } else {
      homeWidget = const AuthPage();
    }
  }
}
