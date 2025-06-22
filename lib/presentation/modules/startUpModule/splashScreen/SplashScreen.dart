import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/adaptative/loadingIndicator/loadingIndicator.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';

class SplashScreen extends StatefulWidget {

  final Widget startWidget;
  const SplashScreen({super.key, required this.startWidget});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  bool isChecking = false;
  bool isDisconnected = false;
  bool isShowed = false;

  @override
  void initState() {
    super.initState();

    final startTime = DateTime.now();

    Future.delayed(const Duration(seconds: 1)).then((value) {
      if(!mounted) return;

      if(CheckCubit.get(context).hasInternet) {

        if(userId != null) AppCubit.get(context).userProfile();
        Future.delayed(const Duration(milliseconds: 800)).then((value) {
          if(!mounted) return;

          navigateAndNotReturn(context: context, screen: widget.startWidget);
          CheckCubit.get(context).changeStatus();

          setState(() {isChecking = false;});
        });

      } else {

        Future.delayed(const Duration(milliseconds: 1500)).then((v) {
          if(!isDisconnected) {
            setState(() {isChecking = true;});

            Future.delayed(const Duration(seconds: 5)).then((value) {
              if(!mounted) return;

              if(isChecking) {
                final elapsedTime = DateTime.now().difference(startTime).inSeconds;
                if(elapsedTime > 5) {
                  setState(() {
                    isChecking = false;
                    isShowed = true;
                  });
                  showAlertCheckConnection(context, isSplashScreen: true);
                }
              }
            });
          }
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {

        var checkCubit = CheckCubit.get(context);

        if(state is ConnectionCheckState) {
          if(!checkCubit.hasInternet) {
            Future.delayed(const Duration(milliseconds: 800)).then((value) {
              if(context.mounted) {
                setState(() {
                  isDisconnected = true;
                  if(isChecking) isChecking = false;
                });
                if(!isShowed) showAlertCheckConnection(context, isSplashScreen: true);
              }
            });
          }
        }

      },
      builder: (context, state) {

        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: ZoomIn(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 170.0,
                      height: 170.0,
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
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: AnimatedSize(
                  duration: Duration(microseconds: 700),
                  clipBehavior: Clip.antiAlias,
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(isChecking) ...[
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            S.of(context).connection_status_4,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        16.0.vrSpace,
                        FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            child: SizedBox(width: 25.0, height: 25.0,
                                child: LoadingIndicator(os: getOs(), strokeWidth: 2.5,))),
                        14.0.vrSpace,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
