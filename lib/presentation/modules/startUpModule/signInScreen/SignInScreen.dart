import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/presentation/modules/chatModule/chatScreen/ChatScreen.dart';
import 'package:uni_helper/shared/adaptative/loadingIndicator/loadingIndicator.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:uni_helper/shared/cubits/signInCubit/SignInStates.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController registrationNbrController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPassword = true;


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
                          navigateAndNotReturn(context: context, screen: ChatScreen());
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
                  appBar: AppBar(),
                  body: Center(
                    child: SingleChildScrollView(
                      clipBehavior: Clip.antiAlias,
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ZoomIn(
                                    child: Image.asset('assets/images/logo.png',
                                      width: 70.0,
                                      height: 70.0,
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if(frame == null) {
                                          return SizedBox.shrink();
                                        }
                                        return FadeIn(
                                            duration: Duration(milliseconds: 300),
                                            child: child);
                                      },
                                    ),
                                  ),
                                  12.0.hrSpace,
                                  ZoomIn(
                                    child: Image.asset('assets/images/flag.png',
                                      width: 70.0,
                                      height: 70.0,
                                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                        if(frame == null) {
                                          return SizedBox.shrink();
                                        }
                                        return FadeIn(
                                            duration: Duration(milliseconds: 300),
                                            child: child);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              12.0.vrSpace,
                              // FadeIn(
                              //   child: Text(
                              //     S.of(context).sign_in_title,
                              //     style: TextStyle(
                              //       fontSize: 14.0,
                              //       letterSpacing: 0.5,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              FadeIn(
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      S.of(context).sign_in_title,
                                      textStyle: const TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'Comfortaa',
                                        letterSpacing: 0.5,
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
                                  children: [
                                    Text(
                                      S.of(context).sign_in_subtitle,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    30.0.vrSpace,
                                    defaultFormField(
                                        label: S.of(context).registration_nbr,
                                        controller: registrationNbrController,
                                        type: TextInputType.number,
                                        focusNode: focusNode,
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
                                      text: S.of(context).sign_in,
                                      isDarkTheme: isDarkTheme,
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
                );
              },
            );
          },
        );
      }
    );
  }
}
