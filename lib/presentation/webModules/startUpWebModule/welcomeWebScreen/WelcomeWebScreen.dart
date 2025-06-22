import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/presentation/webModules/startUpWebModule/signInWebScreen/SignInWebScreen.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/styles/Colors.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';
import 'package:uni_helper/shared/utils/helpers.dart';

class WelcomeWebScreen extends StatefulWidget {
  const WelcomeWebScreen({super.key});

  @override
  State<WelcomeWebScreen> createState() => _WelcomeWebScreenState();
}

class _WelcomeWebScreenState extends State<WelcomeWebScreen> {

  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ?
                  darkGradient :
                  lightGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: LayoutBuilder(
                  builder: (context, constraints) {
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
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  children: [
                                    ZoomIn(
                                      child: Lottie.asset(
                                        isDark
                                            ? 'assets/animations/wave_hand_dark_mode.json'
                                            : 'assets/animations/wave_hand_light_mode.json',
                                        width:
                                            (constraints.maxWidth.toInt() <=
                                                    mobileBreakpoint)
                                                ? 180.0
                                                : 200.0,
                                        height:
                                            (constraints.maxWidth.toInt() <=
                                                    mobileBreakpoint)
                                                ? 180.0
                                                : 200.0,
                                      ),
                                    ),
                                    50.0.vrSpace,
                                    FadeInLeft(
                                      child: Column(
                                        children: [
                                          Text(
                                            S.of(context).welcome_title,
                                            style: TextStyle(
                                              fontSize:
                                                  (constraints.maxWidth.toInt() <=
                                                          mobileBreakpoint)
                                                      ? 24.0
                                                      : 28.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          14.0.vrSpace,
                                          Text(
                                            'UniHelper',
                                            style: TextStyle(
                                              fontSize:
                                                  (constraints.maxWidth.toInt() <= mobileBreakpoint)
                                                      ? 26.0
                                                      : 32.0,
                                              fontFamily: 'Comfortaa',
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          36.0.vrSpace,
                                          LayoutBuilder(
                                            builder: (context, bxConstraints) {
                                              final double fontSize = (bxConstraints.maxWidth.toInt() <= mobileBreakpoint)
                                                      ? 20.0
                                                      : 24.0;
                      
                                              return SizedBox(
                                                width: bxConstraints.maxWidth,
                                                child: MouseRegion(
                                                  cursor: SystemMouseCursors.click,
                                                  child: AnimatedTextKit(
                                                    key: ValueKey(fontSize),
                                                    animatedTexts: [
                                                      TypewriterAnimatedText(
                                                        S.of(context)
                                                            .welcome_description,
                                                        textStyle: TextStyle(
                                                          fontSize: fontSize,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        speed: const Duration(
                                                          milliseconds: 100,
                                                        ),
                                                      ),
                                                    ],
                                                    totalRepeatCount: 1,
                                                    pause: const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                    displayFullTextOnTap: true,
                                                    stopPauseOnTap: true,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    80.0.vrSpace,
                                    FadeInUp(
                                      child: AvatarGlow(
                                        startDelay: const Duration(
                                          milliseconds: 650,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 1300,
                                        ),
                                        glowColor:
                                            Theme.of(context).colorScheme.primary,
                                        glowShape: BoxShape.circle,
                                        animate: true,
                                        curve: Curves.fastOutSlowIn,
                                        glowRadiusFactor:
                                            (constraints.maxWidth.toInt() <= mobileBreakpoint)
                                                ? 0.35
                                                : 0.45,
                                        glowCount: 2,
                                        repeat: true,
                                        child: SizedBox(
                                          width:
                                              (constraints.maxWidth.toInt() <=
                                                      mobileBreakpoint)
                                                  ? 70.0
                                                  : 85.0,
                                          height:
                                              (constraints.maxWidth.toInt() <= mobileBreakpoint)
                                                  ? 70.0
                                                  : 85.0,
                                          child: FloatingActionButton(
                                            clipBehavior: Clip.antiAlias,
                                            enableFeedback: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                50.0,
                                              ),
                                            ),
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            onPressed: () async {
                                              await getStarted(context);
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Colors.white,
                                              size:
                                              (constraints.maxWidth.toInt() <= mobileBreakpoint)
                                                      ? 26.0
                                                      : 28.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    5.0.vrSpace,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getStarted(context) async {
    await CacheHelper.saveCachedData(key: 'isStarted', value: true).then((value) {
      if (value == true) {
        navigateAndNotReturn(context: context, screen: const SignInWebScreen());
      }
    });
  }
}
