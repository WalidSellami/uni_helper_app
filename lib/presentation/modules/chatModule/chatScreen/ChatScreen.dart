import 'package:avatar_glow/avatar_glow.dart';
import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uni_helper/data/models/chatModel/ChatModel.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/adaptative/loadingIndicator/loadingIndicator.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppCubit.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppStates.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckStates.dart';
import 'package:uni_helper/shared/styles/Colors.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';
import 'package:uni_helper/shared/utils/helpers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController msgController = TextEditingController();
  final TextEditingController chatNameController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final FocusNode chatNameFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late AnimationController animationController;

  bool hasFocus = false;

  bool isLoading = false;

  bool isLoadingMessages = false;
  bool isChatSelected = false;
  bool isChatEmpty = false;

  String textInput = '';

  void checkFiledFocus() {
    if (focusNode.hasPrimaryFocus) {
      setState(() {
        hasFocus = true;
      });
    } else {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        setState(() {
          hasFocus = false;
        });
      });
    }
  }


  Future<void> sendMessage(AppCubit appCubit) async {
    focusNode.unfocus();
    textInput = msgController.text.trim();
    msgController.clear();
    setState(() {
      isLoading = true;
    });
    await appCubit.sendMessage(
      text: textInput,
      chatId: (appCubit.groupedChats.isNotEmpty)
          ? appCubit.groupedChats.values
          .elementAt(appCubit.globalIndex ?? 0,
      )[appCubit.innerIndex ?? 0].chatId : null,
      context: context,
    );
  }


  final SpeechToText speechToText = SpeechToText();

  bool isStartListening = false;

  bool isLangSelected = false;

  String langVocal = 'en-US';

  Future<void> startListening(langVocal) async {
    await HapticFeedback.vibrate();
    setState(() {
      isStartListening = true;
    });
    micAnimationConfig(animationController, isStartListening);

    var available = await speechToText.initialize(
      onError: (error) async {
        await stopListening();
      },
      onStatus: (status) async {
        if (status == 'notListening') {
          await stopListening();
        }
      },
    );

    if (available) {
      await speechToText.listen(
        localeId: langVocal,
        onResult: (value) {
          if (msgController.text.isEmpty) {
            setState(() {
              msgController.text = value.recognizedWords;
            });
          } else {
            setState(() {
              msgController.text = '${msgController.text} ${value.recognizedWords}';
            });
          }
        },
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.deviceDefault,
        ),
      );
    }
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      isStartListening = false;
    });
    micAnimationConfig(animationController, isStartListening);
  }

  Future<void> vocalConfig(langVocal) async {
    if (!isStartListening && speechToText.isNotListening) {
      await startListening(langVocal);
    } else {
      await stopListening();
    }
  }

  Future<void> resetConfigurations() async {
    if (isStartListening && speechToText.isListening) {
      await speechToText.stop();
    }
    setState(() {
      isStartListening = false;
      isLangSelected = false;
      langVocal = 'en-US';
      textInput = '';
      isLoadingMessages = false;
      isChatSelected = false;
      isChatEmpty = false;
    });
    micAnimationConfig(animationController, isStartListening);
  }

  bool canPop = false;

  void exitApp(DateTime timeBackPressed) {
    final difference = DateTime.now().difference(timeBackPressed);
    final isWarning = difference >= const Duration(milliseconds: 800);
    timeBackPressed = DateTime.now();

    if (isWarning) {
      showToast(
        S.of(context).exit,
        context: context,
        backgroundColor: Colors.grey.shade800,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.bottom,
        animDuration: const Duration(milliseconds: 1500),
        duration: const Duration(seconds: 3),
        curve: Curves.elasticInOut,
        reverseCurve: Curves.linear,
      );
      setState(() {
        canPop = false;
      });
    } else {
      setState(() {
        canPop = true;
      });
      SystemNavigator.pop();
    }
  }

  final ScrollController scrollController = ScrollController();
  final ScrollController anotherScrollController = ScrollController();

  bool showScrollDownButton = false;

  void scrollListener() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    bool canScrollMore = (maxScroll > 0) && (currentScroll < maxScroll);

    if (scrollController.hasClients && canScrollMore) {
      setState(() {
        showScrollDownButton = true;
      });
    } else {
      setState(() {
        showScrollDownButton = false;
      });
    }
  }

  late AppLifecycleListener appLifecycleListener;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    msgController.addListener(() {
      setState(() {});
    });
    focusNode.addListener(checkFiledFocus);
    scrollController.addListener(scrollListener);

    if (!isStartListening) {
      animationController.animateTo(0.65);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {

      Future.delayed(Duration(milliseconds: 700)).then((value) {
        if(!mounted) return;
        FocusScope.of(context).requestFocus(focusNode);
      });

      if (CheckCubit.get(context).hasInternet) {
        AppCubit.get(context).userProfile();
        AppCubit.get(context).getChats(context);
      }

    });

    appLifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        handleAppLifecycleState(state, resetConfigurations, context);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    scrollController.dispose();
    anotherScrollController.dispose();
    msgController.dispose();
    chatNameController.dispose();
    msgController.removeListener(() {
      setState(() {});
    });
    focusNode.dispose();
    chatNameFocusNode.dispose();
    focusNode.removeListener(checkFiledFocus);
    scrollController.removeListener(scrollListener);
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime timeBackPressed = DateTime.now();

    return Builder(
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final bool isDarkTheme = theme.brightness == Brightness.dark;

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {
            var checkCubit = CheckCubit.get(context);

            if (state is ConnectionCheckState) {
              if (checkCubit.hasInternet) {
                AppCubit.get(context).userProfile();
                if(AppCubit.get(context).messages.isEmpty) {
                  AppCubit.get(context).getChats(context);
                }
              } else {
                resetConfigurations();
              }
            }
          },
          builder: (context, state) {
            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<AppCubit, AppStates>(
              listener: (context, state) {
                var appCubit = AppCubit.get(context);

                if (state is SuccessGetMessagesAppState) {
                  if (state.isUser == false) {
                    setState(() {
                      isLoading = false;
                      textInput = '';
                    });

                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await Future.delayed(Duration(milliseconds: 1500)).then((value) async {
                      await scrollToBottom(scrollController);
                    });
                  });
                }

                if (state is SuccessDeleteChatAppState) {
                  if (!isChatEmpty) {
                    showFlutterToast(
                      message: state.message.toString(),
                      state: ToastStates.success,
                      context: context,
                    );

                    if (isChatSelected) {
                      appCubit.clearIndexing();
                      Future.delayed(Duration(milliseconds: 100)).then((value) {
                        scaffoldKey.currentState?.closeDrawer();
                      });
                      setState(() {
                        isChatSelected = false;
                      });
                    } else {
                      if (appCubit.globalIndex != null &&
                          appCubit.innerIndex != null &&
                          appCubit.selectInnerIndex != null) {
                        appCubit.selectAndChangeIndexing(
                          gIndex: AppCubit.get(context).globalIndex!,
                          iIndex: AppCubit.get(context).selectInnerIndex!,
                          canChange: true,
                        );
                      }
                    }

                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                }

                if (state is ErrorRetrieveOutputAppState ||
                    state is ErrorAddAiMsgAppState ||
                    state is ErrorAddUserMsgAppState ||
                    state is ErrorGetMessagesAppState) {
                  showFlutterToast(
                    message: S.of(context).error_message,
                    state: ToastStates.error,
                    context: context,
                    seconds: 5,
                  );

                  if (checkCubit.hasInternet) {
                    appCubit.deleteMessage(
                      chatId:
                          appCubit.groupedChats.values
                              .elementAt(
                                appCubit.globalIndex ?? 0,
                              )[appCubit.innerIndex ?? 0]
                              .chatId,
                      msgId: appCubit.messages.last.msgId,
                    );

                    Future.delayed(const Duration(seconds: 2)).then((value) {
                      if (appCubit.messages.isEmpty) {
                        setState(() {
                          isChatEmpty = true;
                        });
                        appCubit.clearIndexing();
                        if (context.mounted) {
                          appCubit.deleteChat(chatId:
                                    appCubit.groupedChats.values
                                        .elementAt(0)[0]
                                        .chatId,
                                context: context).then((value) {
                                Future.delayed(Duration(seconds: 1)).then((value) {
                                  setState(() {
                                    isChatEmpty = false;
                                  });
                                });
                              });
                        }
                      }
                    });
                  }

                  setState(() {
                    isLoading = false;
                    textInput = '';
                    isChatSelected = false;
                  });
                }

                if (state is SuccessEditChatAppState) {
                  showFlutterToast(
                    message: state.message.toString(),
                    state: ToastStates.success,
                    context: context,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                  chatNameController.clear();
                  setState(() {
                    isChatSelected = false;
                    isChatEmpty = false;
                  });
                }

                if (state is ErrorEditChatAppState) {
                  showFlutterToast(
                    message: S.of(context).error_message,
                    state: ToastStates.error,
                    context: context,
                    seconds: 5,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                  setState(() {
                    isChatSelected = false;
                    isChatEmpty = false;
                  });
                }

                if (state is ErrorDeleteChatAppState) {
                  showFlutterToast(
                    message: S.of(context).error_message,
                    state: ToastStates.error,
                    context: context,
                    seconds: 5,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                  setState(() {
                    isChatSelected = false;
                    isChatEmpty = false;
                  });
                }
              },
              builder: (context, state) {
                var appCubit = AppCubit.get(context);

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) async {
                    if (details.primaryVelocity != null) {
                      if ((details.primaryVelocity! > 0 &&
                              (appCubit.localeLang == 'en' ||
                                  appCubit.localeLang == 'fr')) ||
                          (details.primaryVelocity! < 0 &&
                              appCubit.localeLang == 'ar')) {
                        focusNode.unfocus();
                        scaffoldKey.currentState?.openDrawer();
                        await Future.delayed(Duration(milliseconds: 700)).then((value) async {
                          await appCubit.userProfile();
                          if (context.mounted) {
                            if(appCubit.messages.isEmpty) {
                              await appCubit.getChats(context);
                            }
                          }
                        });
                      }
                    }
                  },
                  child: PopScope(
                    canPop: canPop,
                    onPopInvokedWithResult: (didPop, result) => exitApp(timeBackPressed),
                    child: Scaffold(
                      key: scaffoldKey,
                      drawer: buildDrawer(
                        theme,
                        isDarkTheme,
                        appCubit,
                        checkCubit,
                        state,
                      ),
                      appBar: AppBar(
                        centerTitle: true,
                        leading: FadeIn(
                          child: IconButton(
                            onPressed: () async {
                              focusNode.unfocus();
                              scaffoldKey.currentState?.openDrawer();
                              await Future.delayed(Duration(milliseconds: 700))
                                  .then((value) async {
                                await appCubit.userProfile();
                                if (context.mounted) {
                                  if(appCubit.messages.isEmpty) {
                                    await appCubit.getChats(context);
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.menu_rounded, size: 26.0),
                          ),
                        ),
                        title: FadeIn(
                          child: Text(
                            'UniHelper',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Comfortaa',
                              letterSpacing:
                                  (localeLanguage != 'ar') ? 0.6 : 0.0,
                            ),
                          ),
                        ),
                        actions: [
                          FadeIn(
                            child: IconButton(
                              onPressed: () {
                                if (checkCubit.hasInternet) {
                                  if (!isLoadingMessages) {
                                    appCubit.clearData(isNewChat: true);
                                  }
                                } else {
                                  showFlutterToast(
                                    message: S.of(context).connection_status,
                                    state: ToastStates.error,
                                    context: context,
                                  );
                                }
                              },
                              tooltip: S.of(context).new_chat,
                              style: ButtonStyle(
                                enableFeedback: true,
                                iconColor: WidgetStatePropertyAll(
                                  (appCubit.messages.isEmpty ||
                                          isLoadingMessages)
                                      ? Theme.of(context).colorScheme.primary
                                          .withPredefinedOpacity(.3)
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              icon: Icon(Icons.add_circle_rounded, size: 26.0),
                            ),
                          ),
                          8.0.hrSpace,
                        ],
                      ),
                      body: Column(
                        children: [
                          Expanded(
                            child: ConditionalBuilder(
                              condition: !isLoadingMessages,
                              builder: (context) => ConditionalBuilder(
                                    condition: appCubit.messages.isNotEmpty,
                                    builder: (context) => Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        ListView.separated(
                                              controller: scrollController,
                                              clipBehavior: Clip.antiAlias,
                                              physics: BouncingScrollPhysics(),
                                              itemBuilder: (context, index) => (buildItemMessage(
                                                        appCubit.messages[index],
                                                        isDarkTheme,
                                                        context
                                                      )),
                                              separatorBuilder: (context, index) => 12.0.vrSpace,
                                              itemCount: appCubit.messages.length,
                                            ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Visibility(
                                            visible: showScrollDownButton,
                                            child: FadeIn(
                                              duration: Duration(milliseconds: 200),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child: FloatingActionButton(
                                                    elevation: 0.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50.0),
                                                    ),
                                                    onPressed: () async {
                                                      await scrollToBottom(scrollController);
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_downward_rounded,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    fallback: (context) => Center(
                                          child: FadeIn(
                                            child: Text.rich(
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 17.0,
                                                letterSpacing:
                                                    (localeLanguage != 'ar') ? 0.6 : 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: getGreeting(context),
                                                    style: TextStyle(
                                                      fontSize: 19.0,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' ${displayName(appCubit.userModel?.fullName ?? '...')}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  ),
                              fallback: (context) => Center(
                                child: LoadingIndicator(os: getOs()),
                              ),
                            ),
                          ),
                          FadeInUp(
                            duration: Duration(milliseconds: 500),
                            child: Material(
                              color: theme.scaffoldBackgroundColor,
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: msgController,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            textCapitalization: TextCapitalization.sentences,
                                            focusNode: focusNode,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null,
                                            textDirection: getTextDirection(msgController.text),
                                            textAlign: (appCubit.localeLang != 'ar') ? TextAlign.left : TextAlign.right,
                                            decoration: InputDecoration(
                                              hintText: S.of(context).ask,
                                              hintStyle: TextStyle(
                                                fontSize: 14.0,
                                                letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              errorMaxLines: 5,
                                              errorStyle: TextStyle(
                                                fontSize: 11.0,
                                                letterSpacing: (localeLanguage != 'ar') ? 0.5 : 0.0,
                                              ),
                                              constraints: BoxConstraints(
                                                maxHeight: MediaQuery.of(context).size.height / 3,
                                              ),
                                              contentPadding: EdgeInsets.all(
                                                21.0,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(32.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(32.0),
                                                borderSide: BorderSide(color: Colors.pink.shade600),
                                              ),
                                              suffixIcon: (msgController.text.length <= maxInputLength) ?
                                              Visibility(
                                                visible: !isLoading,
                                                child: FadeIn(
                                                  duration: Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Tooltip(
                                                        message: S.of(context).mic,
                                                        child: AvatarGlow(
                                                          startDelay: const Duration(
                                                                milliseconds: 500,
                                                              ),
                                                          duration: const Duration(
                                                                milliseconds: 1300,
                                                              ),
                                                          glowColor: isStartListening
                                                                  ? HexColor('27cfcf',)
                                                                  : theme.scaffoldBackgroundColor,
                                                          glowShape: BoxShape.circle,
                                                          animate: isStartListening,
                                                          curve: Curves.fastOutSlowIn,
                                                          glowRadiusFactor:
                                                              isDarkTheme ? 0.16 : 0.24,
                                                          glowCount: 2,
                                                          repeat: true,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              if (checkCubit.hasInternet) {
                                                                if (!isLangSelected) {
                                                                  await langConfig(theme);
                                                                } else {
                                                                  await vocalConfig(langVocal);
                                                                }
                                                              } else {
                                                                showFlutterToast(
                                                                  message: S.of(context,).connection_status,
                                                                  state: ToastStates.error,
                                                                  context: context,
                                                                );
                                                              }
                                                            },
                                                            borderRadius: BorderRadius.circular(50.0),
                                                            child:
                                                                isDarkTheme
                                                                    ? CircleAvatar(
                                                                      radius: 23.0,
                                                                      backgroundColor:
                                                                          isStartListening
                                                                              ? theme.colorScheme.primary
                                                                              : theme.scaffoldBackgroundColor,
                                                                      child: CircleAvatar(
                                                                        radius: 20.0,
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        child: Lottie.asset(
                                                                          'assets/animations/microphone_v2.json',
                                                                          controller:
                                                                              animationController,
                                                                        ),
                                                                      ),
                                                                    )
                                                                    : Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            6.0,
                                                                          ),
                                                                      child: Lottie.asset(
                                                                        'assets/animations/microphone_v2.json',
                                                                        controller:
                                                                            animationController,
                                                                      ),
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                      14.0.hrSpace,
                                                    ],
                                                  ),
                                                ),
                                              ) : null,
                                            ),
                                            style: TextStyle(
                                              letterSpacing:
                                                  (localeLanguage != 'ar') ? 0.6 : 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            validator: (v) {
                                              if(v != null && v.isNotEmpty && v.length > maxInputLength) {
                                                return S.of(context).input_length_check;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        6.0.hrSpace,
                                        AnimatedSize(
                                          duration: Duration(milliseconds: 350),
                                          curve: Curves.easeInOut,
                                          clipBehavior: Clip.antiAlias,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (checkCubit.hasInternet) ...[
                                                if (!isLoading) ...[
                                                  if (msgController.text.isNotEmpty &&
                                                      msgController.text.trim().isNotEmpty &&
                                                      msgController.text.length <= maxInputLength &&
                                                      !isStartListening) ...[
                                                    FadeIn(
                                                      duration: Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          await sendMessage(appCubit);
                                                        },
                                                        icon: Icon(
                                                          Icons.send_rounded,
                                                          size: 26.0,
                                                          color: theme.colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ] else ...[
                                                  FadeIn(
                                                    duration: Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                          ),
                                                      child: SizedBox(
                                                        width: 28.0,
                                                        height: 28.0,
                                                        child: LoadingIndicator(
                                                          os: getOs(),
                                                          strokeWidth: 3.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    12.0.vrSpace,
                                    Text(
                                      S.of(context).model_status,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        letterSpacing:
                                            (localeLanguage != 'ar')
                                                ? 0.6
                                                : 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Drawer
  Widget buildDrawer(
    ThemeData theme,
    isDarkTheme,
    AppCubit appCubit,
    CheckCubit checkCubit,
    state,
  ) => SafeArea(
    child: Drawer(
      clipBehavior: Clip.antiAlias,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius:
            (appCubit.localeLang != 'ar')
                ? BorderRadius.only(
                  topRight: Radius.circular(26.0),
                  bottomRight: Radius.circular(26.0),
                )
                : BorderRadius.only(
                  topLeft: Radius.circular(26.0),
                  bottomLeft: Radius.circular(26.0),
                ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SlideInLeft(
        duration: Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            children: [
              12.0.vrSpace,
              Row(
                children: [
                  ZoomIn(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      width: 65.0,
                      height: 65.0,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      child: Center(
                        child: Image.network(
                          appCubit.userModel?.imageProfile ?? imageProfile,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if(frame == null) {
                              return shimmerImageLoading(
                                width: 65.0,
                                height: 65.0,
                                radius: 50.0,
                                theme: theme,
                                isDarkTheme: isDarkTheme,
                              );
                            }
                            return FadeIn(
                                duration: Duration(milliseconds: 300),
                                child: child);
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: FadeIn(
                                duration: Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  12.0.hrSpace,
                  FadeIn(
                    child: Text(
                      displayName(appCubit.userModel?.fullName ?? '...'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16.0,
                        letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              12.0.vrSpace,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(thickness: 0.6),
              ),
              12.0.vrSpace,
              FadeIn(
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.add_circle_rounded,
                    color:
                        (appCubit.messages.isEmpty)
                            ? theme.colorScheme.primary.withPredefinedOpacity(.3)
                            : theme.colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (checkCubit.hasInternet) {
                      appCubit.clearData(isNewChat: true);
                      await Future.delayed(Duration(milliseconds: 100)).then((value) {
                        scaffoldKey.currentState?.closeDrawer();
                      });
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      theme.scaffoldBackgroundColor,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        width: 1.5,
                        color:
                            (appCubit.messages.isEmpty)
                                ? theme.colorScheme.primary
                                    .withPredefinedOpacity(.3)
                                : theme.colorScheme.primary,
                      ),
                    ),
                    enableFeedback: true,
                    overlayColor: WidgetStatePropertyAll(
                      Colors.grey.shade300.withPredefinedOpacity(.15),
                    ),
                  ),
                  label: Text(
                    S.of(context).new_chat,
                    style: TextStyle(
                      fontSize: 14.0,
                      color:
                          (appCubit.messages.isEmpty)
                              ? theme.colorScheme.primary.withPredefinedOpacity(.3)
                              : theme.colorScheme.primary,
                      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              16.0.vrSpace,
              Expanded(
                child: ConditionalBuilder(
                  condition: appCubit.groupedChats.isNotEmpty,
                  builder: (context) => RefreshIndicator(
                        key: refreshIndicatorKey,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        onRefresh: () async {
                          await Future.delayed(const Duration(seconds: 2)).then((value) {
                              if (context.mounted) {
                                if (CheckCubit.get(context).hasInternet) {
                                  if(AppCubit.get(context).messages.isEmpty) {
                                    AppCubit.get(context).getChats(context);
                                  }
                                }
                              }
                            },
                          );
                        },
                        child: ListView.separated(
                          controller: anotherScrollController,
                          clipBehavior: Clip.antiAlias,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, globalIndex) {
                            final String status = appCubit.groupedChats.keys.elementAt(globalIndex);
                            final List<ChatModel> chats = appCubit.groupedChats.values.elementAt(globalIndex);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    letterSpacing:
                                        (localeLanguage != 'ar') ? 0.6 : 0.0,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkTheme
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade600,
                                  ),
                                ),
                                8.0.vrSpace,
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, innerIndex) {
                                      return buildItemChat(
                                        chats[innerIndex],
                                        globalIndex,
                                        innerIndex,
                                        isDarkTheme,
                                      );
                                    },
                                    itemCount: chats.length,
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => 12.0.vrSpace,
                          itemCount: appCubit.groupedChats.length,
                        ),
                      ),
                  fallback: (context) => (state is LoadingGetChatsAppState)
                              ? shimmerChatLoading(
                                 width: double.infinity, height: 50.0, radius: 10.0,
                                 theme: theme, isDarkTheme: isDarkTheme)
                              : Center(
                                child: Text(
                                  S.of(context).no_chats,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    letterSpacing:
                                        (localeLanguage != 'ar') ? 0.6 : 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(thickness: 0.6),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FadeIn(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      defaultIcon(
                        text: S.of(context).feedback,
                        color: isDarkTheme
                                ? Colors.grey.shade800.withPredefinedOpacity(.7)
                                : Colors.grey.shade200,
                        size: 26.0,
                        radius: 50.0,
                        icon: Icons.feedback_rounded,
                        colorIcon: isDarkTheme ? Colors.white : Colors.black,
                        onPress: () {
                          if (checkCubit.hasInternet) {
                            scaffoldKey.currentState?.closeDrawer();
                            Future.delayed(Duration(milliseconds: 200)).then((v) {
                              sendMailMsg(isFeedback: true, recipient: devMail);
                            });
                          } else {
                            showFlutterToast(
                              message: S.of(context).connection_status,
                              state: ToastStates.error,
                              context: context,
                            );
                          }
                        },
                        context: context,
                      ),
                      26.0.hrSpace,
                      Container(
                        width: 0.75,
                        height: 40.0,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      26.0.hrSpace,
                      defaultLanguageDropdown(
                        appCubit: appCubit, 
                        checkCubit: checkCubit,
                         isDarkTheme: isDarkTheme,
                          context: context),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: FadeIn(
                  child: ElevatedButton(
                    clipBehavior: Clip.antiAlias,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        theme.scaffoldBackgroundColor,
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(width: 1.5, color: redColor),
                      ),
                    ),
                    onPressed: () {
                      if (checkCubit.hasInternet) {
                        showAlertSignOut(context, () {
                          appCubit.signOut(context, isDarkTheme);
                        });
                      } else {
                        showFlutterToast(
                          message: S.of(context).connection_status,
                          state: ToastStates.error,
                          context: context,
                        );
                      }
                    },
                    child: Text(
                      S.of(context).sign_out,
                      style: TextStyle(
                        fontSize: 17.0,
                        color: redColor,
                        letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );


  // Chats
  Widget buildItemChat(ChatModel chat, int gIndex, int iIndex, isDarkTheme) {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: ((AppCubit.get(context).globalIndex == gIndex) &&
                        (AppCubit.get(context).innerIndex == iIndex))
                    ? Theme.of(context).colorScheme.primary.withPredefinedOpacity(.2)
                    : null,
          ),
          child: ListTile(
            onTap: () async {
              if (CheckCubit.get(context).hasInternet) {
                setState(() {
                  isLoadingMessages = true;
                });
                AppCubit.get(context).changeIndexing(gIndex, iIndex);
                await Future.delayed(Duration(milliseconds: 100)).then((value) {
                  scaffoldKey.currentState?.closeDrawer();
                });
                if (!mounted) return;
                await AppCubit.get(
                  context,
                ).getMessages(chatId: chat.chatId).then((value) {
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    setState(() {
                      isLoadingMessages = false;
                    });
                  });
                });
              } else {
                showFlutterToast(
                  message: S.of(context).connection_status,
                  state: ToastStates.error,
                  context: context,
                );
              }
            },
            onLongPress: () async {
              if (CheckCubit.get(context).hasInternet) {
                if (!mounted) return;
                if (((AppCubit.get(context).globalIndex == gIndex) &&
                    (AppCubit.get(context).innerIndex == iIndex))) {
                  setState(() {
                    isChatSelected = true;
                  });
                }
                AppCubit.get(context)
                    .selectAndChangeIndexing(gIndex: gIndex, iIndex: iIndex);
                await showChatOptions(
                  chat.chatId,
                  chat.name,
                  isChatSelected,
                  isDarkTheme,
                );
              } else {
                showFlutterToast(
                  message: S.of(context).connection_status,
                  state: ToastStates.error,
                  context: context,
                );
              }
            },
            enableFeedback: true,
            selected: ((AppCubit.get(context).globalIndex == gIndex) &&
                        (AppCubit.get(context).innerIndex == iIndex))
                    ? true
                    : false,
            selectedColor: Theme.of(context).colorScheme.primary,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            leading: Icon(
              (localeLanguage != 'ar')
                  ? EvaIcons.chevronRightOutline
                  : EvaIcons.chevronLeftOutline,
            ),
            title: Text(
              '${chat.name}',
              maxLines: 1,
              textDirection: getTextDirection(chat.name ?? ''),
              textAlign: (localeLanguage != 'ar') ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: 14.0,
                letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showChatOptions(
    chatId,
    chatName,
    isChatSelected,
    isDarkTheme,
  ) => showModalBottomSheet(
    showDragHandle: true,
    enableDrag: false,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: FadeIn(
            child: Wrap(
              runSpacing: 2.0,
              clipBehavior: Clip.antiAlias,
              children: [
                ListTile(
                  onTap: () {
                    if (CheckCubit.get(context).hasInternet) {
                      setState(() {
                        isChatEmpty = false;
                      });
                      showAlertEdit(
                        context: context, 
                        chatId: chatId,
                        chatName: chatName, 
                        chatNameController: chatNameController,
                        chatNameFocusNode: chatNameFocusNode,
                        formKey: formKey,
                        isDarkTheme: isDarkTheme);
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: Icon(
                    EvaIcons.edit2Outline,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    S.of(context).rename,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isDarkTheme ? Colors.white : Colors.black,
                      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    if (CheckCubit.get(context).hasInternet) {
                      setState(() {
                        isChatEmpty = false;
                      });
                      showAlertDelete(
                        context: context,
                        chatId: chatId,
                        isChatSelected: isChatSelected,
                        isDarkTheme: isDarkTheme,
                      );
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  leading: Icon(EvaIcons.trash2Outline, color: redColor),
                  title: Text(
                    S.of(context).delete,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: redColor,
                      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );


  Future<dynamic> langConfig(ThemeData theme) => showModalBottomSheet(
    showDragHandle: true,
    enableDrag: false,
    isDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: '${S.of(context).lang_request} :',
                  style: TextStyle(
                    fontSize: 17.0,
                    letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              16.0.vrSpace,
              FadeIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          langVocal = 'ar-DZ';
                          isLangSelected = true;
                        });
                        Navigator.pop(context);
                        await vocalConfig(langVocal);
                      },
                      child: Text(
                        S.of(context).lang_ar,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          langVocal = 'en-US';
                          isLangSelected = true;
                        });
                        Navigator.pop(context);
                        await vocalConfig(langVocal);
                      },
                      child: Text(
                        S.of(context).lang_en,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          langVocal = 'fr-FR';
                          isLangSelected = true;
                        });
                        Navigator.pop(context);
                        await vocalConfig(langVocal);
                      },
                      child: Text(
                        S.of(context).lang_fr,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
