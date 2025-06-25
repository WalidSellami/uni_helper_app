import 'package:avatar_glow/avatar_glow.dart';
import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
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

class ChatWebScreen extends StatefulWidget {
  const ChatWebScreen({super.key});

  @override
  State<ChatWebScreen> createState() => _ChatWebScreenState();
}

class _ChatWebScreenState extends State<ChatWebScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController msgController = TextEditingController();
  final TextEditingController chatNameController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final FocusNode keyboardListenerFocusNode = FocusNode();
  final FocusNode chatNameFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey globalIcBtnKey = GlobalKey();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late AnimationController animationController;

  bool isLoading = false;

  bool isLoadingMessages = false;
  bool isChatSelected = false;
  bool isChatEmpty = false;

  String textInput = '';

  bool isHovered = false;

  void handleKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent) {
      final isCtrlPressed = (event.logicalKey == LogicalKeyboardKey.enter) &&
          (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
              HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft)); // for Mac

      if (isCtrlPressed) {
        if(msgController.text.isNotEmpty && msgController.text.trim().isNotEmpty) {
          await sendMessage(AppCubit.get(context));
        }
      }
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
      focusNode.unfocus();
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
    scrollController.addListener(scrollListener);

    if (!isStartListening) {
      animationController.animateTo(0.65);
    }

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CheckCubit.get(context).hasInternet) {
        AppCubit.get(context).userProfile();
        AppCubit.get(context).getChats(context);
      }

      Future.delayed(Duration(milliseconds: 700)).then((v) {
        if(!mounted) return;
        FocusScope.of(context).requestFocus(focusNode);
      });
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
    scrollController.removeListener(scrollListener);
    focusNode.dispose();
    keyboardListenerFocusNode.dispose();
    chatNameFocusNode.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
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

                    Future.delayed(Duration(milliseconds: 300)).then((v) {
                      if(context.mounted) {
                        FocusScope.of(context).requestFocus(focusNode);
                      }
                    });
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await Future.delayed(Duration(milliseconds: 1200)).then((value) async {
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
                      if(MediaQuery.of(context).size.width <= mobileBreakpoint) {
                        Future.delayed(Duration(milliseconds: 100)).then((value) {
                          scaffoldKey.currentState?.closeDrawer();
                        });
                      }
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
                      chatId: appCubit.groupedChats.values.elementAt(
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
                          appCubit.deleteChat(
                                chatId: appCubit.groupedChats.
                                values.elementAt(0)[0].chatId,
                                context: context,
                              ).then((value) {
                                Future.delayed(Duration(seconds: 1)).then((value,) {
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

                  focusNode.unfocus();
                }

                if (state is SuccessEditChatAppState) {
                  showFlutterToast(
                    message: state.message.toString(),
                    state: ToastStates.success,
                    context: context,
                  );

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
                  setState(() {
                    isChatSelected = false;
                    isChatEmpty = false;
                  });
                }
              },
              builder: (context, state) {
                var appCubit = AppCubit.get(context);

                return LayoutBuilder(
                builder: (context, constraints) {

                  // print(constraints.maxWidth);

                  return buildResponsiveChatScreen(
                    appCubit,
                    checkCubit,
                    theme,
                    isDarkTheme,
                    constraints.maxWidth.toInt(),
                    state,
                  );
                },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildResponsiveChatScreen(
    AppCubit appCubit,
    CheckCubit checkCubit,
    ThemeData theme,
    isDarkTheme,
    sizeWidthScreen,
    state,
  ) {
    return (sizeWidthScreen > mobileBreakpoint)
        ? Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: (sizeWidthScreen > 1100) ? sizeWidthScreen / 4.2 : sizeWidthScreen / 3.2,
                  height: MediaQuery.of(context).size.height,
                  child: buildWebDrawer(
                    theme,
                    isDarkTheme,
                    appCubit,
                    checkCubit,
                    sizeWidthScreen,
                    state,
                  ),
                ),
                45.0.vrSpace,
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              FadeIn(
                                child: Text(
                                  'UniHelper',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: 'Comfortaa',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing:
                                        (localeLanguage != 'ar') ? 0.6 : 0.0,
                                  ),
                                ),
                              ),
                              Spacer(),
                              ZoomIn(
                                duration: Duration(milliseconds: 500),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message: displayName(
                                      appCubit.userModel?.fullName ?? '...',
                                    ),
                                    enableFeedback: true,
                                    textAlign: TextAlign.center,
                                    child: Container(
                                      width: 55.0,
                                      height: 55.0,
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
                                                  width: 55.0,
                                                  height: 55.0,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: sizeWidthScreen / 1.75,
                            child: ConditionalBuilder(
                              condition: !isLoadingMessages,
                              builder: (context) => ConditionalBuilder(
                                    condition: appCubit.messages.isNotEmpty,
                                    builder: (context) => Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        ScrollConfiguration(
                                          behavior: NoScrollbarScrollBehavior(),
                                          child: Scrollbar(
                                            controller: scrollController,
                                            thumbVisibility: true,
                                            thickness: 2.0,
                                            trackVisibility: false,
                                            child: ListView.separated(
                                                  controller: scrollController,
                                                  clipBehavior: Clip.antiAlias,
                                                  physics: ClampingScrollPhysics(),
                                                  padding: EdgeInsets.all(8.0),
                                                  itemBuilder: (context, index) => (buildItemMessage(
                                                            appCubit.messages[index],
                                                            isDarkTheme,
                                                            context,
                                                          )),
                                                  separatorBuilder: (context, index) => 16.0.vrSpace,
                                                  itemCount: appCubit.messages.length,
                                                ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: showScrollDownButton,
                                          child: FadeIn(
                                            duration: Duration(milliseconds: 300),
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
                                                    color: Colors.white,
                                                    size: 24.0,
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
                                                fontSize: 19.0,
                                                letterSpacing:
                                                    (localeLanguage != 'ar') ? 0.6 : 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: getGreeting(context),
                                                    style: TextStyle(
                                                      fontSize: 22.0,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ${displayName(appCubit.userModel?.fullName ?? '...')}',
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
                        ),
                        FadeInUp(
                          duration: Duration(milliseconds: 500),
                          child: SizedBox(
                            width: sizeWidthScreen / 1.75,
                            child: buildWebTextFormFiled(
                              theme,
                              isDarkTheme,
                              appCubit,
                              checkCubit,
                              sizeWidthScreen
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        : Scaffold(
          key: scaffoldKey,
          drawer: buildMobileWebDrawer(
            theme,
            isDarkTheme,
            appCubit,
            checkCubit,
            sizeWidthScreen,
            state,
          ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(85.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppBar(
                centerTitle: true,
                leading: FadeIn(
                  child: IconButton(
                    onPressed: () async {
                      scaffoldKey.currentState?.openDrawer();
                      await Future.delayed(Duration(milliseconds: 700)).then((
                        value,
                      ) async {
                        await appCubit.userProfile();
                        if (!mounted) return;
                        await appCubit.getChats(context);
                      });
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                      }
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
                      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                    ),
                  ),
                ),
                actions: [
                  ZoomIn(
                    duration: Duration(milliseconds: 500),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: displayName(
                          appCubit.userModel?.fullName ?? '...',
                        ),
                        enableFeedback: true,
                        textAlign: TextAlign.center,
                        child: Container(
                          width: 65.0,
                          height: 65.0,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.0,
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
                    ),
                  ),
                  8.0.hrSpace,
                ],
              ),
            ),
          ),
          body: Center(
            child: Column(
              children: [
                Expanded(
                  child: ConditionalBuilder(
                    condition: !isLoadingMessages,
                    builder: (context) => ConditionalBuilder(
                          condition: appCubit.messages.isNotEmpty,
                          builder: (context) => Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ScrollConfiguration(
                                behavior: NoScrollbarScrollBehavior(),
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  thickness: 2.0,
                                  trackVisibility: false,
                                  child: ListView.separated(
                                        controller: scrollController,
                                        clipBehavior: Clip.antiAlias,
                                        physics: ClampingScrollPhysics(),
                                        padding: EdgeInsets.all(8.0),
                                        itemBuilder:
                                            (context, index) => (buildItemMessage(
                                              appCubit.messages[index],
                                              isDarkTheme,
                                              context,
                                            )),
                                        separatorBuilder:
                                            (context, index) => 16.0.vrSpace,
                                        itemCount: appCubit.messages.length,
                                      ),
                                ),
                              ),
                              Visibility(
                                visible: showScrollDownButton,
                                child: FadeIn(
                                  duration: Duration(milliseconds: 300),
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
                                          color: Colors.white,
                                          size: 24.0,
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
                                      fontSize: 19.0,
                                      letterSpacing:
                                          (localeLanguage != 'ar') ? 0.6 : 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: getGreeting(context),
                                          style: TextStyle(
                                            fontSize: 22.0,
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
                    fallback: (context) =>
                        Center(child: LoadingIndicator(os: getOs())),
                  ),
                ),
                FadeInUp(
                  duration: Duration(milliseconds: 500),
                  child: buildWebTextFormFiled(
                    theme,
                    isDarkTheme,
                    appCubit,
                    checkCubit,
                    sizeWidthScreen
                  ),
                ),
              ],
            ),
          ),
        );
  }


  Widget buildWebTextFormFiled(ThemeData theme, isDarkTheme, AppCubit appCubit,
      CheckCubit checkCubit, sizeWidthScreen) => Material(
    color: theme.scaffoldBackgroundColor,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 26.0,
        horizontal: 22.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KeyboardListener(
            focusNode: keyboardListenerFocusNode,
            onKeyEvent: handleKeyEvent,
            child: TextFormField(
              controller: msgController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: S.of(context).ask,
                hintStyle: TextStyle(
                  fontSize: 16.0,
                  letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                  fontWeight: FontWeight.bold,
                ),
                errorMaxLines: 5,
                errorStyle: TextStyle(
                  fontSize: 13.0,
                  letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2.8,
                ),
                contentPadding: EdgeInsets.all(26.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(color: Colors.pink.shade600),
                ),
                suffixIcon: (msgController.text.length <= maxInputLength) ?
                FadeIn(
                  duration: Duration(milliseconds: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSize(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            if(!isLoading) ...[
                              Tooltip(
                                message: S.of(context).mic,
                                child: AvatarGlow(
                                  startDelay: const Duration(
                                    milliseconds: 500,
                                  ),
                                  duration: const Duration(
                                    milliseconds: 1300,
                                  ),
                                  glowColor:
                                  isStartListening
                                      ? HexColor('27cfcf')
                                      : theme.scaffoldBackgroundColor,
                                  glowShape: BoxShape.circle,
                                  animate: isStartListening,
                                  curve: Curves.fastOutSlowIn,
                                  glowRadiusFactor:
                                  isDarkTheme ? 0.18 : 0.26,
                                  glowCount: 2,
                                  repeat: true,
                                  child: InkWell(
                                    key: globalIcBtnKey,
                                    onTap: () async {
                                      if (checkCubit.hasInternet) {
                                        await Permission.microphone.request();

                                        if(await Permission.microphone.isGranted) {
                                          if (!isLangSelected) {
                                            if(!mounted) return;
                                            await showPopupMenuLangConfig(
                                                isDarkTheme,
                                                context);
                                          } else {
                                            await vocalConfig(langVocal);
                                          }
                                        }

                                      } else {
                                        showFlutterToast(
                                          message: S.of(context).connection_status,
                                          state: ToastStates.error,
                                          context: context,
                                        );
                                      }
                                    },
                                    borderRadius:
                                    BorderRadius.circular(
                                      50.0,
                                    ),
                                    child:
                                    isDarkTheme
                                        ? CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor:
                                      isStartListening
                                          ? theme.colorScheme.primary
                                          : theme.scaffoldBackgroundColor,
                                      child: CircleAvatar(
                                        radius: 22.0,
                                        backgroundColor:
                                        Colors.white,
                                        child: Lottie.asset(
                                          'assets/animations/microphone_v2.json',
                                          controller: animationController,
                                        ),
                                      ),
                                    ) : Padding(
                                      padding:
                                      const EdgeInsets.all(
                                        8.0,
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
                              8.0.hrSpace,
                            ],
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: Duration(
                          milliseconds: 200,
                        ),
                        curve: Curves.easeInOut,
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (checkCubit.hasInternet) ...[
                              if (!isLoading) ...[
                                if (msgController.text.isNotEmpty &&
                                    msgController.text.trim().isNotEmpty &&
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
                                      child:
                                      LoadingIndicator(
                                        os: getOs(),
                                        strokeWidth:
                                        3.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      14.0.hrSpace,
                    ],
                  ),
                ) : null,
              ),
              textDirection: getTextDirection(msgController.text),
              textAlign: (appCubit.localeLang != 'ar') ? TextAlign.left : TextAlign.right,
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
          12.0.vrSpace,
          Text(
            S.of(context).model_status,
            style: TextStyle(
              fontSize: 12.0,
              letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
            ),
          ),
        ],
      ),
    ),
  );


  // Web Drawer
  Widget buildWebDrawer(
    ThemeData theme,
    isDarkTheme,
    AppCubit appCubit,
    CheckCubit checkCubit,
    sizeWidthScreen,
    state,
  ) => SlideInLeft(
    duration: Duration(milliseconds: 500),
    child: Container(
      height: MediaQuery.of(context).size.height,
      color: isDarkTheme ? darkColor1 : lightBackground,
      child: buildExpandedWebDrawer(
                theme,
                isDarkTheme,
                appCubit,
                checkCubit,
                sizeWidthScreen,
                state,
              ),
    ),
  );


  Widget buildMobileWebDrawer(
    ThemeData theme,
    isDarkTheme,
    AppCubit appCubit,
    CheckCubit checkCubit,
    sizeWidthScreen,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MouseRegion(
                    onHover: (_) {
                      setState(() {
                        isHovered = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isHovered = false;
                      });
                    },
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      scale: isHovered ? 1.05 : 1.0,
                      child: ZoomIn(
                        duration: Duration(milliseconds: 500),
                        child: InkWell(
                          enableFeedback: true,
                          borderRadius: BorderRadius.circular(50.0),
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if(checkCubit.hasInternet) {
                              await Future.delayed(Duration(milliseconds: 700)).then((value) async {
                                await appCubit.userProfile();
                                if (!mounted) return;
                                if(appCubit.messages.isEmpty) {
                                  await appCubit.getChats(context);
                                }
                              });
                            }
                          },
                          child: Container(
                            width: 55.0,
                            height: 55.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 1.5,
                                color: isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              color: theme.scaffoldBackgroundColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 35.0,
                                height: 35.0,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if(frame == null) {
                                    return shimmerImageLoading(
                                      width: 60.0,
                                      height: 60.0,
                                      radius: 50.0,
                                      theme: theme,
                                      isDarkTheme: isDarkTheme,
                                    );
                                  }
                                  return FadeIn(
                                      duration: Duration(milliseconds: 300),
                                      child: child);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeIn(
                    child: IconButton(
                      enableFeedback: true,
                      tooltip: S.of(context).new_chat,
                      onPressed: () async {
                        if (checkCubit.hasInternet) {
                          appCubit.clearData(isNewChat: true);
                          if (sizeWidthScreen <= mobileBreakpoint) {
                            Future.delayed(Duration(milliseconds: 100)).then((value) {
                              scaffoldKey.currentState?.closeDrawer();
                            });
                          }
                        } else {
                          showFlutterToast(
                            message: S.of(context).connection_status,
                            state: ToastStates.error,
                            context: context,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color:
                            (appCubit.messages.isEmpty)
                                ? theme.colorScheme.primary.withPredefinedOpacity(.3)
                                : theme.colorScheme.primary,
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.scaffoldBackgroundColor,
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            width: 1.5,
                            color: (appCubit.messages.isEmpty)
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
                    ),
                  ),
                ],
              ),
              16.0.vrSpace,
              Expanded(
                child: ConditionalBuilder(
                  condition: appCubit.groupedChats.isNotEmpty,
                  builder: (context) => buildListOfChats(appCubit, theme, isDarkTheme, sizeWidthScreen),
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
              12.0.vrSpace,
              FadeIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    defaultIcon(
                      text: S.of(context).feedback,
                      color:
                          isDarkTheme
                              ? Colors.grey.shade800.withPredefinedOpacity(.7)
                              : Colors.grey.shade200,
                      size: 26.0,
                      radius: 50.0,
                      icon: Icons.feedback_rounded,
                      colorIcon: isDarkTheme ? Colors.white : Colors.black,
                      onPress: () async {
                        if (checkCubit.hasInternet) {
                          await sendMailMsg(isFeedback: true, recipient: devMail);
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
                      context: context,
                    ),
                  ],
                ),
              ),
              16.0.vrSpace,
              Align(
                alignment: Alignment.center,
                child: FadeIn(
                  child: ElevatedButton(
                    clipBehavior: Clip.antiAlias,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        theme.scaffoldBackgroundColor,
                      ),
                      enableFeedback: true,
                      padding: (sizeWidthScreen > mobileBreakpoint)
                              ? WidgetStatePropertyAll(EdgeInsets.all(16.0))
                              : null,
                      side: WidgetStatePropertyAll(
                        BorderSide(width: 1.5, color: redColor),
                      ),
                    ),
                    onPressed: () {
                      if (checkCubit.hasInternet) {
                        showWebAlertSignOut(context, () {
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
              8.0.vrSpace,
            ],
          ),
        ),
      ),
    ),
  );


  Widget buildExpandedWebDrawer(
    ThemeData theme,
    isDarkTheme,
    AppCubit appCubit,
    CheckCubit checkCubit,
    sizeWidthScreen,
    state,
  ) => Padding(
    padding: const EdgeInsets.all(22.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MouseRegion(
              onHover: (_) {
                setState(() {
                  isHovered = true;
                });
              },
              onExit: (_) {
                setState(() {
                  isHovered = false;
                });
              },
              child: AnimatedScale(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                scale: isHovered ? 1.05 : 1.0,
                child: ZoomIn(
                  duration: Duration(milliseconds: 500),
                  child: InkWell(
                    enableFeedback: true,
                    borderRadius: BorderRadius.circular(50.0),
                    onTap: () async {
                      if(checkCubit.hasInternet) {
                        await Future.delayed(Duration(milliseconds: 700)).then((value) async {
                          await appCubit.userProfile();
                          if (!mounted) return;
                          if(appCubit.messages.isEmpty) {
                            await appCubit.getChats(context);
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 75.0,
                      height: 75.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                        color: theme.scaffoldBackgroundColor,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 50.0,
                          height: 50.0,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if(frame == null) {
                              return shimmerImageLoading(
                                width: 75.0,
                                height: 75.0,
                                radius: 50.0,
                                theme: theme,
                                isDarkTheme: isDarkTheme,
                              );
                            }
                            return FadeIn(
                                duration: Duration(milliseconds: 300),
                                child: child);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FadeIn(
              child: IconButton(
                enableFeedback: true,
                tooltip: S.of(context).new_chat,
                onPressed: () async {
                  if (checkCubit.hasInternet) {
                    appCubit.clearData(isNewChat: true);
                    if (sizeWidthScreen <= mobileBreakpoint) {
                      Future.delayed(Duration(milliseconds: 100)).then((value) {
                        scaffoldKey.currentState?.closeDrawer();
                      });
                    }
                  } else {
                    showFlutterToast(
                      message: S.of(context).connection_status,
                      state: ToastStates.error,
                      context: context,
                    );
                  }
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: (appCubit.messages.isEmpty)
                          ? theme.colorScheme.primary.withPredefinedOpacity(.3)
                          : theme.colorScheme.primary,
                ),
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
              ),
            ),
          ],
        ),
        26.0.vrSpace,
        Expanded(
          child: ConditionalBuilder(
            condition: appCubit.groupedChats.isNotEmpty,
            builder: (context) => buildListOfChats(appCubit, theme, isDarkTheme, sizeWidthScreen),
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
        12.0.vrSpace,
        FadeIn(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeIn(
                child: IconButton(
                  enableFeedback: true,
                  padding: EdgeInsets.all(4.0),
                  tooltip: S.of(context).feedback,
                  onPressed: () async {
                    if (checkCubit.hasInternet) {
                      await sendMailMsg(isFeedback: true, recipient: devMail);
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.feedback_rounded,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      theme.scaffoldBackgroundColor,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        width: 1.0,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    enableFeedback: true,
                    overlayColor: WidgetStatePropertyAll(
                      Colors.grey.shade300.withPredefinedOpacity(.15),
                    ),
                  ),
                ),
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
                context: context,
              ),
            ],
          ),
        ),
        16.0.vrSpace,
        Align(
          alignment: Alignment.center,
          child: FadeIn(
            child: ElevatedButton(
              clipBehavior: Clip.antiAlias,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  theme.scaffoldBackgroundColor,
                ),
                enableFeedback: true,
                padding: (sizeWidthScreen > mobileBreakpoint)
                        ? WidgetStatePropertyAll(EdgeInsets.all(16.0))
                        : null,
                side: WidgetStatePropertyAll(
                  BorderSide(width: 1.5, color: redColor),
                ),
              ),
              onPressed: () {
                if (checkCubit.hasInternet) {
                  showWebAlertSignOut(context, () {
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
        8.0.vrSpace,
      ],
    ),
  );


  Widget buildListOfChats(AppCubit appCubit, ThemeData theme, isDarkTheme, sizeWidthScreen) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      color: theme.colorScheme.primary,
      backgroundColor: theme.scaffoldBackgroundColor,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2)).then((value) async {
          if (!mounted) return;
            if (CheckCubit.get(context).hasInternet) {
              if(AppCubit.get(context).messages.isEmpty) {
                await AppCubit.get(context).getChats(context);
              }
            }
        });
      },
      child: ScrollConfiguration(
        behavior: NoScrollbarScrollBehavior(),
        child: Scrollbar(
          controller: anotherScrollController,
          thumbVisibility: true,
          thickness: 2.0,
          child: ListView.separated(
            controller: anotherScrollController,
            clipBehavior: Clip.antiAlias,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.all(8.0),
            itemBuilder: (context, globalIndex) {
              final String status = appCubit.groupedChats.keys.elementAt(globalIndex);
              final List<ChatModel> chats = appCubit.groupedChats.values.elementAt(globalIndex);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeIn(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: (sizeWidthScreen > mobileBreakpoint) ? 15.0 : 13.0,
                        letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  4.0.vrSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: chats.asMap().entries.map((entry) {
                        int innerIndex = entry.key;
                        ChatModel chat = entry.value;

                        return buildItemChat(
                          chat,
                          globalIndex,
                          innerIndex,
                          isDarkTheme,
                          sizeWidthScreen,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => 12.0.vrSpace,
            itemCount: appCubit.groupedChats.length,
          ),
        ),
      ),
    );
  }


  // Chats
  Map<dynamic, bool> hoveredChats = {};

  Widget buildItemChat(ChatModel chat, int gIndex, int iIndex, isDarkTheme, sizeWidthScreen) {
    return FadeIn(
      duration: Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
        ),
        child: MouseRegion(
          onHover: (_) {
            setState(() {
              hoveredChats[chat.chatId] = true;
            });
          },
          onExit: (_) {
            setState(() {
              hoveredChats[chat.chatId] = false;
            });
          },
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
                  if(sizeWidthScreen <= mobileBreakpoint) {
                    await Future.delayed(Duration(milliseconds: 100)).then((value) {
                      scaffoldKey.currentState?.closeDrawer();
                    });
                  }
                  if (!mounted) return;
                  await AppCubit.get(context).getMessages(chatId: chat.chatId).then((value) {
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
              enableFeedback: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              selected: ((AppCubit.get(context).globalIndex == gIndex) &&
                          (AppCubit.get(context).innerIndex == iIndex))
                      ? true
                      : false,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                '${chat.name}',
                maxLines: 1,
                textDirection: getTextDirection(chat.name ?? ''),
                textAlign: (localeLanguage != 'ar') ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  fontSize: (sizeWidthScreen > mobileBreakpoint) ? 17.0 : 15.0,
                  letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Opacity(
                opacity: (hoveredChats[chat.chatId] ?? false) ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: (hoveredChats[chat.chatId] == false),
                  child: defaultPopUpMenuOptions(
                    chatId: chat.chatId,
                    chatName: chat.name,
                    chatNameController: chatNameController,
                    formKey: formKey,
                    isDarkTheme: isDarkTheme,
                    chatNameFocusNode: chatNameFocusNode,
                    isChatSelected: isChatSelected,
                    onOpen: () {
                      if (((AppCubit.get(context).globalIndex == gIndex) &&
                          (AppCubit.get(context).innerIndex == iIndex))) {
                        setState(() {
                          isChatSelected = true;
                        });
                      }
                      AppCubit.get(context).selectAndChangeIndexing(
                        gIndex: gIndex,
                        iIndex: iIndex,
                      );
                    },
                    context: context,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------------------- //

  // Vocal
  Future<void> showPopupMenuLangConfig(isDarkTheme, context) async {
    final RenderBox renderBox = globalIcBtnKey.currentContext?.findRenderObject() as RenderBox; // local coordinates
    final Offset position = renderBox.localToGlobal(Offset.zero); // global coordinates
    // final Size size = renderBox.size;

    final TextDirection currentDirection = Directionality.of(context);

    final selectedValue = await showMenu<String>(
      context: context,
      clipBehavior: Clip.antiAlias,
      color: isDarkTheme ? darkColor2 : Colors.white,
      position: RelativeRect.fromLTRB(
        (currentDirection == TextDirection.rtl) ? position.dx - 50.0 : position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'Arabic',
          child: Center(
            child: Text(
              S.of(context).lang_ar,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'English',
          child: Center(
            child: Text(
              S.of(context).lang_en,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'French',
          child: Center(
            child: Text(
              S.of(context).lang_fr,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      menuPadding: EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    // if (kDebugMode) {
    //   print(selectedValue);
    // }

    if (selectedValue != null) {
      if (selectedValue == 'Arabic') {
        setState(() {
          langVocal = 'ar-DZ';
          isLangSelected = true;
        });
    } else if (selectedValue == 'English') {
        setState(() {
          langVocal = 'en-US';
          isLangSelected = true;
        });
    } else if (selectedValue == 'French') {
        setState(() {
          langVocal = 'fr-FR';
          isLangSelected = true;
        });
      }
      await vocalConfig(langVocal);
    }

  }

}
