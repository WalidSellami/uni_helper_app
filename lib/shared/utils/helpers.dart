import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/styles/Colors.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';

String getGreeting(context) {
    var now = DateTime.now();
    var hour = now.hour;

    if (hour < 12) {
      return S.of(context).good_morning;
    } else if (hour < 18) {
      return S.of(context).good_afternoon;
    } else {
      return S.of(context).good_evening;
    }
  }


  String displayName(String name) {
    if(name.contains(' ') && name.split(' ').length > 1) {
      return '${name.split(' ')[0]} ${name.split(' ')[1]}';
    } else {
      return name;
    }
  }


TextDirection getTextDirection(String text) {
  // Check if the text contains any Arabic characters
  return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
}



void micAnimationConfig(animationController, isStartListening) {
    if(!isStartListening) {
      animationController.repeat();
      animationController.animateTo(0.65);
    } else {
      animationController.reverse();
    }

  }


  Future<void> scrollToBottom(scrollController) async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut);
    }
  }

  void scrollToCurrentIndex(anotherScrollController, int globalIndex, int currentIndex, context) {
    if (anotherScrollController.hasClients) {
      final maxScroll = anotherScrollController.position.maxScrollExtent;
      final minScroll = anotherScrollController.position.minScrollExtent;
      final currentScroll = anotherScrollController.position.pixels;

      final bool canScroll = maxScroll > minScroll && currentScroll < maxScroll;

      if (canScroll) {
        double totalOffset = 0.0;
        for (int i = 0; i < globalIndex; i++) {
          int nbrItems = AppCubit.get(context).groupedChats.values.elementAt(i).length;
          totalOffset += 20.0; // Height of separator
          totalOffset += nbrItems * 50.0; // Height of chat items
        }
        totalOffset += currentIndex * 80.0; // Additional offset for currentIndex
        anotherScrollController.animateTo(
          totalOffset,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void handleAppLifecycleState(AppLifecycleState state, Future<void> Function() resetConfigurations, BuildContext context) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (CheckCubit.get(context).hasInternet) {
          AppCubit.get(context).userProfile();

          if(AppCubit.get(context).messages.isEmpty) {
            AppCubit.get(context).getChats(context);
          }
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        resetConfigurations();
        break;
      default:
        break;
    }
  }



  List<TextSpan> buildTextSpans(String inputText, isDarkTheme, context) {
    List<TextSpan> spans = [];
    int previousEnd = 0;

    List<Match> allMatches = [
      ...urlRegex.allMatches(inputText),
      ...titleRegex.allMatches(inputText),
      ...bulletRegex.allMatches(inputText),
      ...codeRegex.allMatches(inputText),
      ...emailRegex.allMatches(inputText),
      ...hashtagRegex.allMatches(inputText),
    ];

    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (Match match in allMatches) {
      if (match.start > previousEnd) {
        spans.add(
          TextSpan(
            text: inputText.substring(previousEnd, match.start),
            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          ),
        );
      }

      if (urlRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    if (CheckCubit.get(context).hasInternet) {
                      await HapticFeedback.vibrate();
                      String url = match.group(0) ?? '';
                      if (!url.contains('https') || !url.contains('http')) {
                        url = 'https://${match.group(0)}';
                      }
                      await lunchBaseUrl(url)
                          .then((value) {
                            showFlutterToast(
                              message: S.of(context).url_open,
                              state: ToastStates.success,
                              context: context,
                            );
                          })
                          .catchError((error) {
                            showFlutterToast(
                              message: S.of(context).error_message,
                              state: ToastStates.error,
                              context: context,
                            );
                          });
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
          ),
        );
      } else if (titleRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(text: match.group(1), style: TextStyle(color: blueColor)),
        );
      } else if (bulletRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(text: match.group(0), style: TextStyle(color: blueColor)),
        );
      } else if (codeRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(
            text: match.group(2),
            recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    if (match.group(2) != '' && match.group(2) != null) {
                      await Clipboard.setData(
                        ClipboardData(text: match.group(2)!),
                      );
                    }
                  },
            style: TextStyle(
              color: isDarkTheme ? Colors.blueGrey.shade200 : Colors.teal.shade900,
              fontSize: 14.0,
              backgroundColor:
                  isDarkTheme
                      ? Colors.grey.shade800.withPredefinedOpacity(0.5)
                      : Colors.grey.shade300,
              fontFamily: 'Inconsolata',
            ),
          ),
        );
      } else if (emailRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () async {
                    if (CheckCubit.get(context).hasInternet) {
                      String email = match.group(0) ?? '';
                      await sendMailMsg(isFeedback: false, recipient: email);
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
          ),
        );
      } else if (hashtagRegex.hasMatch(match.group(0)!)) {
        spans.add(
          TextSpan(text: match.group(0), style: TextStyle(color: blueColor)),
        );
      }

      previousEnd = match.end;
    }

    if (previousEnd < inputText.length) {
      spans.add(
        TextSpan(
          text: inputText.substring(previousEnd, inputText.length),
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
        ),
      );
    }

    return spans;
  }


  class NoScrollbarScrollBehavior extends MaterialScrollBehavior {
    @override
    Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
      return child; // Do not show the default Material scrollbar
    }
  }
