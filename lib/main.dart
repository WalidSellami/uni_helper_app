import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uni_helper/presentation/modules/chatModule/chatScreen/ChatScreen.dart';
import 'package:uni_helper/presentation/modules/startUpModule/signInScreen/SignInScreen.dart';
import 'package:uni_helper/presentation/modules/startUpModule/splashScreen/SplashScreen.dart';
import 'package:uni_helper/presentation/modules/startUpModule/welcomeScreen/WelcomeScreen.dart';
import 'package:uni_helper/presentation/webModules/chatWebModule/chatWebScreen/ChatWebScreen.dart';
import 'package:uni_helper/presentation/webModules/startUpWebModule/signInWebScreen/SignInWebScreen.dart';
import 'package:uni_helper/presentation/webModules/startUpWebModule/welcomeWebScreen/WelcomeWebScreen.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppCubit.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppStates.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/network/remote/DioHelper.dart';
import 'package:uni_helper/shared/simpleBlocObserver/SimpleBlocObserver.dart';
import 'package:uni_helper/shared/styles/Styles.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'generated/l10n.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = SimpleBlocObserver();

  await CacheHelper.init();

  DioHelper.init();

  localeLanguage = CacheHelper.getCachedData(key: 'localeLang');
  var isStarted = CacheHelper.getCachedData(key: 'isStarted');
  userId = CacheHelper.getCachedData(key: 'userId');
  Widget? defaultWidget;
  

  if(isStarted != null) {
    if(userId != null) {
      if(kIsWeb) {
        defaultWidget = ChatWebScreen();
      } else {
        defaultWidget = ChatScreen();
      }
    } else {
      if(kIsWeb) {
        defaultWidget = SignInWebScreen();
      } else {
        defaultWidget = SignInScreen();
      }
    }
  } else {
    if(kIsWeb) {
      defaultWidget = WelcomeWebScreen();
    } else {
      defaultWidget = WelcomeScreen();
    }
  }


  runApp(MyApp(
    localeLanguage: localeLanguage,
    startWidget: defaultWidget,
   ));
}

class MyApp extends StatelessWidget {

  final String? localeLanguage;
  final Widget? startWidget;

  const MyApp({super.key, this.localeLanguage, this.startWidget});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // Default device language
    deviceLocaleLang = PlatformDispatcher.instance.locales.first.languageCode;

    // if (kDebugMode) {
      // print('deviceLocaleLang: $deviceLocaleLang');
    // }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppCubit()..localeLangConfig(localeLanguage ?? deviceLocaleLang)),
        BlocProvider(create: (BuildContext context) => CheckCubit()..checkConnection()),
        BlocProvider(create: (BuildContext context) => SignInCubit()),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {

          var appCubit = AppCubit.get(context);

          return OverlaySupport.global(
            child: MaterialApp(
              locale: Locale(appCubit.localeLang),
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale != null) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                }
                return supportedLocales.first;
              },
              title: 'UniHelper Assistant',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              home: Builder(
                builder: (context) {

                  if(kIsWeb) {

                    Future.delayed(Duration(seconds: 3)).then((value) {
                      if(context.mounted) {
                        CheckCubit.get(context).changeStatus();
                      }
                    });

                    return startWidget!;
                  }

                  return SplashScreen(startWidget: startWidget!);
                }
              ),
            ),
          );
        },
      ),
    );
  }
}