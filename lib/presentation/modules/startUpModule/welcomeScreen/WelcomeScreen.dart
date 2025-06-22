import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/presentation/modules/startUpModule/signInScreen/SignInScreen.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {

        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {},
          builder: (context, state) {

            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ZoomIn(
                        child: Lottie.asset(
                          isDark ?
                          'assets/animations/wave_hand_dark_mode.json' :
                          'assets/animations/wave_hand_light_mode.json',
                          width: 180.0,
                          height: 180.0,
                        ),
                      ),
                      FadeInLeft(
                        child: Column(
                          children: [
                            Text(
                              S.of(context).welcome_title,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            14.0.vrSpace,
                            Text(
                              'UniHelper',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontFamily: 'Comfortaa',
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            24.0.vrSpace,
                            AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  S.of(context).welcome_description,
                                  textStyle: const TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  textAlign: TextAlign.center,
                                  speed: const Duration(milliseconds: 125),
                                ),
                              ],
                              totalRepeatCount: 1,
                              pause: const Duration(milliseconds: 500),
                              displayFullTextOnTap: true,
                              stopPauseOnTap: true,
                            ),
                          ],
                        ),
                      ),
                      10.0.vrSpace,
                      FadeInUp(
                        child: AvatarGlow(
                          startDelay: const Duration(milliseconds: 650),
                          duration: const Duration(milliseconds: 1300),
                          glowColor: Theme.of(context).colorScheme.primary,
                          glowShape: BoxShape.circle,
                          animate: true,
                          curve: Curves.fastOutSlowIn,
                          glowRadiusFactor: 0.6,
                          glowCount: 2,
                          repeat: true,
                          child: SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: FloatingActionButton(
                              clipBehavior: Clip.antiAlias,
                              enableFeedback: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              onPressed: () async {
                                await getStarted(context);
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
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
            );
          },
        );
      }
    );
  }

  Future<void> getStarted(context) async {
    await CacheHelper.saveCachedData(key: 'isStarted', value: true).then((value) {
      if(value == true) {
        navigateAndNotReturn(context: context, screen: const SignInScreen());
      }
    });
  }


}
