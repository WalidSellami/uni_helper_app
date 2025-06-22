import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/presentation/webModules/chatWebModule/chatWebScreen/ChatWebScreen.dart';
import 'package:uni_helper/shared/adaptative/loadingIndicator/loadingIndicator.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInStates.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/styles/Colors.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';
import 'package:uni_helper/shared/utils/helpers.dart';

class SignInWebScreen extends StatefulWidget {
  const SignInWebScreen({super.key});

  @override
  State<SignInWebScreen> createState() => _SignInWebScreenState();
}

class _SignInWebScreenState extends State<SignInWebScreen> {

  final TextEditingController registrationNbrController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController scrollController = ScrollController();

  bool isPassword = true;

  bool isHovered1 = false;
  bool isHovered2 = false;


  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      setState(() {});
    });
  }


  @override
  void dispose() {
    super.dispose();
    registrationNbrController.dispose();
    passwordController.dispose();
    passwordController.removeListener(() {
      setState(() {});
    });
    focusNode.dispose();
    focusNode2.dispose();
    scrollController.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {


        final ThemeData theme = Theme.of(context);
        final bool isDarkTheme = theme.brightness == Brightness.dark;

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {},
          builder: (context, state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<SignInCubit, SignInStates>(
              listener: (context, state) {

                if(state is SuccessSignInState) {

                  if(state.status == 'success') {

                    showFlutterToast(
                        message: state.message.toString(),
                        state: ToastStates.success,
                        context: context);

                    CacheHelper.saveCachedData(key: 'userId', value: state.userId).then((value) {

                      userId = state.userId;

                      if(context.mounted) {
                        navigateAndNotReturn(context: context, screen: ChatWebScreen());
                      }

                    });


                  } else {

                    showFlutterToast(
                        message: state.message.toString(),
                        state: ToastStates.error,
                        context: context,
                        seconds: 5
                    );

                    userId = null;
                  }

                }

                if(state is ErrorSignInState) {

                  showFlutterToast(
                      message: state.error.toString(),
                      state: ToastStates.error,
                      context: context,
                      seconds: 5
                  );

                  userId = null;
                }


              },
              builder: (context, state) {

                var signInCubit = SignInCubit.get(context);

                return Scaffold(
                  backgroundColor: isDarkTheme ? darkBackground : lightBackground,
                  body: LayoutBuilder(
                    builder: (context, constraints) {

                      // print('constraints.maxWidth: ${constraints.maxWidth}');

                      double width = constraints.maxWidth / 2.3;

                      if(constraints.maxWidth < 1300) {
                        width = constraints.maxWidth / 2.1;
                      }

                      if(constraints.maxWidth < 1100) {
                        width = constraints.maxWidth / 1.8;
                      }

                      if(constraints.maxWidth < 900) {
                        width = constraints.maxWidth / 1.5;
                      }

                      if(constraints.maxWidth < 800) {
                        width = constraints.maxWidth / 1.35;
                      }

                      if(constraints.maxWidth < 700) {
                        width = constraints.maxWidth / 1.25;
                      }

                      if(constraints.maxWidth < 600) {
                        width = constraints.maxWidth / 1.15;
                      }

                      if(constraints.maxWidth <= 500) {
                        width = constraints.maxWidth;
                      }


                      return SafeArea(
                        child: Center(
                          child: ScrollConfiguration(
                            behavior: NoScrollbarScrollBehavior(),
                            child: Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              thickness: 2.0,
                              trackVisibility: false,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(22.0),
                                  child: ZoomIn(
                                    child: Container(
                                      // width: (constraints.maxWidth.toInt() > 900) ?
                                      // (constraints.maxWidth.toInt() / 2) : (constraints.maxWidth.toInt() / 1.25),
                                      width: width,
                                      height: (constraints.maxHeight / 1.2),
                                      padding: const EdgeInsets.all(26.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24.0),
                                        color: isDarkTheme ? darkColor1 : Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10.0,
                                              spreadRadius: 2.0,
                                              offset: Offset(0, 4),
                                            ),
                                          ]
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Center(
                                        child: Form(
                                          key: formKey,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    onHover: (_) {
                                                      setState(() {
                                                        isHovered1 = true;
                                                      });
                                                    },
                                                    onExit: (_) {
                                                      setState(() {
                                                        isHovered1 = false;
                                                      });
                                                    },
                                                    child: AnimatedScale(
                                                      duration: Duration(milliseconds: 500),
                                                      curve: Curves.easeInOut,
                                                      scale: isHovered1 ? 1.1 : 1.0,
                                                      child: ZoomIn(
                                                        child: Image.asset('assets/images/logo.png',
                                                          width: (constraints.maxWidth.toInt() > 900) ? 70.0 : 60.0,
                                                          height: (constraints.maxWidth.toInt() > 900) ? 70.0 : 60.0,
                                                          fit: BoxFit.contain,
                                                          filterQuality: FilterQuality.high,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  12.0.hrSpace,
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    onHover: (_) {
                                                      setState(() {
                                                        isHovered2 = true;
                                                      });
                                                    },
                                                    onExit: (_) {
                                                      setState(() {
                                                        isHovered2 = false;
                                                      });
                                                    },
                                                    child: AnimatedScale(
                                                      duration: Duration(milliseconds: 500),
                                                      curve: Curves.easeInOut,
                                                      scale: isHovered2 ? 1.1 : 1.0,
                                                      child: ZoomIn(
                                                        child: Image.asset('assets/images/flag.png',
                                                          width: (constraints.maxWidth.toInt() > 900) ? 70.0 : 60.0,
                                                          height: (constraints.maxWidth.toInt() > 900) ? 70.0 : 60.0,
                                                          fit: BoxFit.contain,
                                                          filterQuality: FilterQuality.high,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              12.0.vrSpace,
                                              FadeIn(
                                                child: AnimatedTextKit(
                                                  animatedTexts: [
                                                    TypewriterAnimatedText(
                                                      S.of(context).sign_in_title,
                                                      textStyle: TextStyle(
                                                        fontSize: 14.0,
                                                        fontFamily: 'Comfortaa',
                                                        letterSpacing: (localeLanguage != 'ar') ? 0.5 : 0.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      speed: const Duration(milliseconds: 75),
                                                    ),
                                                  ],
                                                  totalRepeatCount: 1,
                                                  pause: const Duration(milliseconds: 500),
                                                  displayFullTextOnTap: true,
                                                  stopPauseOnTap: true,
                                                ),
                                              ),
                                              65.0.vrSpace,
                                              FadeIn(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      S.of(context).sign_in_subtitle,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        letterSpacing: (localeLanguage != 'ar') ? 0.5 : 0.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    30.0.vrSpace,
                                                    defaultFormField(
                                                        label: S.of(context).registration_nbr,
                                                        controller: registrationNbrController,
                                                        type: TextInputType.number,
                                                        focusNode: focusNode,
                                                        radius: 14.0,
                                                        isDarkTheme: isDarkTheme,
                                                        prefixIcon: Icons.numbers_rounded,
                                                        onComplete: () {
                                                          FocusScope.of(context).requestFocus(focusNode2);
                                                        },
                                                        validate: (value) {
                                                          if(value == null || value.isEmpty) {
                                                            return S.of(context).registration_nbr_check_1;
                                                          }

                                                          bool validValue = registrationNbrRegExp.hasMatch(value);

                                                          if(!validValue) {
                                                            return S.of(context).registration_nbr_check_2;
                                                          }

                                                          return null;
                                                        },
                                                        context: context),
                                                    25.0.vrSpace,
                                                    defaultFormField(
                                                        label: S.of(context).password,
                                                        controller: passwordController,
                                                        type: TextInputType.visiblePassword,
                                                        focusNode: focusNode2,
                                                        radius: 14.0,
                                                        isPassword: isPassword,
                                                        isDarkTheme: isDarkTheme,
                                                        prefixIcon: Icons.lock_outline_rounded,
                                                        suffixIcon: isPassword ?
                                                        Icons.visibility_off_rounded :
                                                        Icons.visibility_rounded,
                                                        onPress: () {
                                                          setState(() {isPassword = !isPassword;});
                                                        },
                                                        onSubmit: (v) {
                                                          focusNode.unfocus();
                                                          focusNode2.unfocus();
                                                          if(checkCubit.hasInternet) {
                                                            if(formKey.currentState!.validate()) {
                                                              if(checkCubit.hasInternet) {
                                                                signInCubit.userSignIn(
                                                                    regNbr: registrationNbrController.text,
                                                                    password: passwordController.text,
                                                                    context: context
                                                                );
                                                              } else {
                                                                showFlutterToast(
                                                                    message: S.of(context).connection_status,
                                                                    state: ToastStates.error,
                                                                    context: context);
                                                              }
                                                            }
                                                          } else {
                                                            showFlutterToast(
                                                                message: S.of(context).connection_status,
                                                                state: ToastStates.error,
                                                                context: context);
                                                          }
                                                          return null;
                                                        },
                                                        validate: (value) {
                                                          if(value == null || value.isEmpty) {
                                                            return S.of(context).password_check_1;
                                                          }

                                                          if(value.length < 8) {
                                                            return S.of(context).password_check_2;
                                                          }

                                                          return null;
                                                        },
                                                        context: context),
                                                  ],
                                                ),
                                              ),
                                              45.0.vrSpace,
                                              ConditionalBuilder(
                                                condition: state is! LoadingSignInState,
                                                builder: (context) =>  FadeIn(
                                                  duration: Duration(milliseconds: 300),
                                                  child: defaultButton(
                                                      height: 57.0,
                                                      text: S.of(context).sign_in,
                                                      radius: 14.0,
                                                      onPress: () {
                                                        focusNode.unfocus();
                                                        focusNode2.unfocus();
                                                        if(formKey.currentState!.validate()) {
                                                          if(checkCubit.hasInternet) {
                                                            signInCubit.userSignIn(
                                                                regNbr: registrationNbrController.text,
                                                                password: passwordController.text,
                                                                context: context
                                                            );
                                                          } else {
                                                            showFlutterToast(
                                                                message: S.of(context).connection_status,
                                                                state: ToastStates.error,
                                                                context: context);
                                                          }
                                                        }
                                                      },
                                                      context: context),
                                                ),
                                                fallback: (context) => Center(child: LoadingIndicator(os: getOs())),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      }
    );
  }
}
