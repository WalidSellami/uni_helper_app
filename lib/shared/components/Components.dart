import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_helper/data/models/messageModel/MessageModel.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/shared/adaptative/loadingIndicator/loadingIndicator.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppCubit.dart';
import 'package:uni_helper/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:uni_helper/shared/styles/Colors.dart';
import 'package:uni_helper/shared/utils/Constants.dart';
import 'package:uni_helper/shared/utils/Extensions.dart';
import 'package:uni_helper/shared/utils/helpers.dart';


navigateTo({required BuildContext context, required Widget screen}) =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );


navigateAndNotReturn({required BuildContext context, required Widget screen}) =>
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );


Route createRoute({required screen}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}


Route createSecondRoute({required screen}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}


Widget defaultFormField({
  required String label,
  required TextEditingController controller,
  required TextInputType type,
  required FocusNode focusNode,
  required String? Function(String?)? validate,
  bool isPassword = false,
  var maxLines = 1,
  double fontSize = 16.0,
  double radius = 18.0,
  IconData? prefixIcon,
  IconData? suffixIcon,
  void Function()? onPress,
  String? helperText,
  void Function(String)? onSubmit,
  void Function()? onComplete,
  void Function(String)? onChange,
  void Function()? onTap,
  required bool isDarkTheme,
  required BuildContext context,
}) => TextFormField(
  clipBehavior: Clip.antiAlias,
  controller: controller,
  keyboardType: type,
  textCapitalization: TextCapitalization.sentences,
  focusNode: focusNode,
  obscureText: isPassword,
  maxLines: maxLines,
  textDirection: getTextDirection(controller.text),
  textAlign: (localeLanguage != 'ar') ? TextAlign.left : TextAlign.right,
  style: const TextStyle(fontWeight: FontWeight.bold),
  decoration: InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontSize: fontSize,
      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
    ),
    helperText: (controller.text.isEmpty) ? helperText : null,
    helperMaxLines: 2,
    errorStyle: TextStyle(
      fontSize: (kIsWeb) ? 13.0 : 11.0,
      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
    ),
    helperStyle: TextStyle(
      fontSize: (kIsWeb) ? 13.0 : 11.0,
      letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
    ),
    errorMaxLines: 10,
    contentPadding: (kIsWeb) ? EdgeInsets.all(22.0) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(width: 2.0, color: Colors.pink.shade600),
    ),
    prefixIcon: (prefixIcon != null)
            ? FadeIn(
              duration: Duration(milliseconds: 200),
              child: Icon(prefixIcon),
            )
            : null,
    suffixIcon: (suffixIcon != null)
            ? ((controller.text.isNotEmpty)
                ? FadeIn(
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: IconButton(
                        onPressed: onPress,
                        icon: Icon(
                          suffixIcon,
                          color: isDarkTheme ?
                          Colors.white : Colors.black,)),
                  ),
                )
                : null)
            : null,
  ),
  validator: validate,
  onChanged: onChange,
  onFieldSubmitted: onSubmit,
  onTap: onTap,
  onEditingComplete: onComplete,
);


Widget defaultSearchFormField({
  required String label,
  required TextEditingController controller,
  required TextInputType type,
  required FocusNode focusNode,
  required String? Function(String)? onChange,
  Function? onPress,
  String? Function(String?)? onSubmit,
}) => TextFormField(
  controller: controller,
  keyboardType: TextInputType.text,
  style: const TextStyle(fontWeight: FontWeight.bold),
  decoration: InputDecoration(
    label: const Text('Type ...'),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(width: 2.0),
    ),
    prefixIcon: const Icon(EvaIcons.searchOutline),
    suffixIcon:
        (controller.text.isNotEmpty)
            ? IconButton(
              onPressed: () => onPress!(),
              icon: const Icon(Icons.close_rounded),
            )
            : null,
  ),
  onChanged: (value) {
    if (value.isNotEmpty) {
      onChange!(value);
    }
  },
  onFieldSubmitted: (value) {
    if (value.isNotEmpty) {
      onSubmit!(value);
    }
  },
);


Widget defaultButton({
  double width = double.infinity,
  double height = 48.0,
  double radius = 22.0,
  required String text,
  required Function onPress,
  required BuildContext context,
}) => SizedBox(
  width: width,
  child: MaterialButton(
    height: height,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius)),
    color: lightPrimary,
    onPressed: () {
      onPress();
    },
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.white,
        letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);


Widget defaultSecondButton({
  double height = 48.0,
  required String text,
  required Function onPress,
  required BuildContext context,
}) => SizedBox(
  width: 200.0,
  child: MaterialButton(
    height: height,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    color: lightPrimary,
    onPressed: () {
      onPress();
    },
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.white,
        letterSpacing: 0.5,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);


Widget defaultTextButton({required String text, required Function onPress}) =>
    TextButton(
      onPressed: () {
        onPress();
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
      ),
    );


Widget defaultIcon({
  double radius = 8.0,
  double padding = 10.0,
  double elevation = 0.0,
  required String text,
  required Color color,
  required double size,
  required IconData icon,
  required Color colorIcon,
  required Function onPress,
  required BuildContext context,
}) => Tooltip(
  enableFeedback: true,
  message: text,
  child: Material(
    color: color,
    elevation: elevation,
    borderRadius: BorderRadius.circular(radius),
    child: InkWell(
      onTap: () => onPress(),
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(icon, size: size, color: colorIcon),
      ),
    ),
  ),
);


defaultAppBar({
  required Function onPress,
  String? title,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
    onPressed: () {
      onPress();
    },
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    tooltip: 'Back',
  ),
  titleSpacing: 5.0,
  title: Text(
    title ?? '',
    maxLines: 1,
    style: const TextStyle(fontSize: 16.0, overflow: TextOverflow.ellipsis),
  ),
  actions: actions,
);

enum ToastStates { success, warning, error, normal }

void showFlutterToast({
  required String message,
  required ToastStates state,
  required BuildContext context,
  int seconds = 3,
}) => showToast(
  message,
  context: context,
  backgroundColor: chooseToastColor(s: state),
  animation: StyledToastAnimation.scale,
  reverseAnimation: StyledToastAnimation.fade,
  position: StyledToastPosition.bottom,
  animDuration: const Duration(milliseconds: 1500),
  duration: Duration(seconds: seconds),
  curve: Curves.elasticInOut,
  reverseCurve: Curves.linear,
);

Color chooseToastColor({required ToastStates s}) {
  return switch (s) {
    ToastStates.success => greenColor,
    ToastStates.warning => Colors.amber.shade900,
    ToastStates.error => Colors.red,
    ToastStates.normal => Colors.grey.shade800.withPredefinedOpacity(.7),
  };
}

dynamic showLoading(context, isDarkTheme) => showDialog(
  barrierDismissible: false,
  context: context,
  builder: (BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 300),
      child: PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(26.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              color: isDarkTheme ? darkColor1 : Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: (kIsWeb) ? SizedBox(
              width: 35.0,
              height: 35.0,
              child: LoadingIndicator(os: getOs())) : 
              LoadingIndicator(os: getOs()),
          ),
        ),
      ),
    );
  },
);


Widget shimmerImageLoading({
  required double width,
  required double height,
  required double radius,
  required ThemeData theme,
  required bool isDarkTheme,
}) => Shimmer.fromColors(
  baseColor: isDarkTheme ? darkShimmerColor
      : lightShimmerColor,
  highlightColor: isDarkTheme ? darkShimmerColor2
      : lightShimmerColor2,
  child: Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: theme.scaffoldBackgroundColor,
    ),
    clipBehavior: Clip.antiAlias,
  ),
);



Widget shimmerChatLoading({
  required double width,
  required double height,
  required double radius,
  required ThemeData theme,
  required bool isDarkTheme,
}) => FadeIn(
  duration: Duration(milliseconds: 300),
  child: Shimmer.fromColors(
      baseColor: isDarkTheme ? darkShimmerColor2
          : lightShimmerColor3,
      highlightColor: isDarkTheme ? darkShimmerColor
          : lightShimmerColor2,
      child: SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        physics: kIsWeb ? ClampingScrollPhysics() : BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: theme.scaffoldBackgroundColor,
              ),
              clipBehavior: Clip.antiAlias,
            ),
            14.0.vrSpace,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.antiAlias,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: theme.scaffoldBackgroundColor,
                  ),
                  clipBehavior: Clip.antiAlias,
                ),
              ),
              separatorBuilder: (context, index) => 12.0.vrSpace,
              itemCount: 5,
            ),
          ],
        ),
      ),),
);




dynamic showAlertSignOut(BuildContext context, void Function() onPress) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          clipBehavior: Clip.antiAlias,
          title: Text(
            S.of(context).sign_out_request,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                S.of(context).no,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onPress();
              },
              child: Text(
                S.of(context).yes,
                style: TextStyle(
                  color: redColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


dynamic showWebAlertSignOut(BuildContext context, void Function() onPress) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          clipBehavior: Clip.antiAlias,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).sign_out_qst,
                  style: TextStyle(
                    fontSize: 19.0,
                    letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.0.vrSpace,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45.0,
                  ),
                  child: Divider(
                    thickness: 1.5,
                  ),
                ),
              ],
            ),
          ),
          content: Text(
            S.of(context).sign_out_request,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                S.of(context).no,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onPress();
              },
              child: Text(
                S.of(context).yes,
                style: TextStyle(
                  color: redColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


dynamic showAlertCheckConnection(
  BuildContext context, {
  bool isSplashScreen = false,
}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              S.of(context).connection_status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              S.of(context).connection_status_1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.0, letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
              ),
            ),
            actions: [
              if (!isSplashScreen)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Wait',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  'Exit',
                  style: TextStyle(
                    color: redColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

dynamic showAlertEdit({
  required formKey,
  required chatNameController,
  required chatNameFocusNode,
  required context,
  required chatId,
  required chatName,
  required isDarkTheme,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      chatNameController.text = chatName;
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: AlertDialog(
            clipBehavior: Clip.antiAlias,
            title: TextFormField(
              controller: chatNameController,
              focusNode: chatNameFocusNode,
              keyboardType: TextInputType.text,
              maxLength: 30,
              clipBehavior: Clip.antiAlias,
              decoration: InputDecoration(
                hintText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: const BorderSide(width: 2.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(width: 2.0, color: Colors.pink.shade600),
                ),
                prefixIcon: const Icon(EvaIcons.editOutline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).chat_name_check;
                }
                if (value.length > 30) {
                  return S.of(context).chat_name_check_2;
                }
                return null;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: isDarkTheme ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FadeIn(
                duration: const Duration(milliseconds: 100),
                child: TextButton(
                  onPressed: () async {
                    chatNameFocusNode.unfocus();
                    if (CheckCubit.get(context).hasInternet) {
                      if (formKey.currentState!.validate()) {
                        String name = chatNameController.text;
                        Navigator.pop(dialogContext);
                        showLoading(context, isDarkTheme);
                        await AppCubit.get(context).editChat(
                          name: name,
                          chatId: chatId,
                          context: context,
                        );
                      }
                    } else {
                      showFlutterToast(
                        message: S.of(context).connection_status,
                        state: ToastStates.error,
                        context: context,
                      );
                    }
                  },
                  child: Text(
                    S.of(context).rename,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: greenColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


dynamic showWebAlertEdit({
  required formKey,
  required chatNameController,
  required chatNameFocusNode,
  required context,
  required chatId,
  required chatName,
  required isDarkTheme,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      chatNameController.text = chatName;
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 34.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: (MediaQuery.of(context).size.width > mobileBreakpoint) ?
              BoxConstraints(maxWidth: 550) : BoxConstraints(maxWidth: 350),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).rename_chat,
                        style: TextStyle(
                          fontSize: 19.0,
                          color: isDarkTheme ? Colors.white : Colors.black,
                          letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      8.0.vrSpace,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45.0,
                        ),
                        child: Divider(
                          color: isDarkTheme ? Colors.white : Colors.black,
                          thickness: 1.5,
                        ),
                      ),
                      16.0.vrSpace,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 120.0,
                          ),
                          child: TextFormField(
                            controller: chatNameController,
                            focusNode: chatNameFocusNode,
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                            clipBehavior: Clip.antiAlias,
                            decoration: InputDecoration(
                              hintText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(width: 1.0),
                              ),
                              prefixIcon: const Icon(EvaIcons.editOutline, size: 20.0,),
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).chat_name_check;
                              }
                              if (value.length > 30) {
                                return S.of(context).chat_name_check_2;
                              }
                              return null;
                            },
                            onFieldSubmitted: (v) async {
                              chatNameFocusNode.unfocus();
                              if (CheckCubit.get(context).hasInternet) {
                                if (formKey.currentState!.validate()) {
                                  String name = chatNameController.text;
                                  Navigator.pop(dialogContext);
                                  showLoading(context, isDarkTheme);
                                  await AppCubit.get(context).editChat(
                                    name: name,
                                    chatId: chatId,
                                    context: context,
                                  );
                                }
                              } else {
                                showFlutterToast(
                                  message: S.of(context).connection_status,
                                  state: ToastStates.error,
                                  context: context,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      26.0.vrSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: isDarkTheme ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              chatNameFocusNode.unfocus();
                              if (CheckCubit.get(context).hasInternet) {
                                if (formKey.currentState!.validate()) {
                                  String name = chatNameController.text;
                                  Navigator.pop(dialogContext);
                                  showLoading(context, isDarkTheme);
                                  await AppCubit.get(context).editChat(
                                    name: name,
                                    chatId: chatId,
                                    context: context,
                                  );
                                }
                              } else {
                                showFlutterToast(
                                  message: S.of(context).connection_status,
                                  state: ToastStates.error,
                                  context: context,
                                );
                              }
                            },
                            child: Text(
                              S.of(context).rename,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: greenColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // content: Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextFormField(
            //     controller: chatNameController,
            //     focusNode: chatNameFocusNode,
            //     keyboardType: TextInputType.text,
            //     maxLength: 30,
            //     clipBehavior: Clip.antiAlias,
            //     decoration: InputDecoration(
            //       hintText: '',
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10.0),
            //         borderSide: const BorderSide(width: 1.0),
            //       ),
            //       prefixIcon: const Icon(EvaIcons.editOutline, size: 20.0,),
            //     ),
            //     style: TextStyle(
            //       fontSize: 14.0,
            //       fontWeight: FontWeight.bold,
            //       color: isDarkTheme ? Colors.white : Colors.black,
            //     ),
            //     validator: (value) {
            //       if (value == null || value.isEmpty) {
            //         return S.of(context).chat_name_check;
            //       }
            //       if (value.length > 30) {
            //         return S.of(context).chat_name_check_2;
            //       }
            //       return null;
            //     },
            //     onFieldSubmitted: (v) async {
            //       chatNameFocusNode.unfocus();
            //       if (CheckCubit.get(context).hasInternet) {
            //         if (formKey.currentState!.validate()) {
            //           String name = chatNameController.text;
            //           Navigator.pop(dialogContext);
            //           showLoading(context, isDarkTheme);
            //           await AppCubit.get(context).editChat(
            //             name: name,
            //             chatId: chatId,
            //             context: context,
            //           );
            //         }
            //       } else {
            //         showFlutterToast(
            //           message: S.of(context).connection_status,
            //           state: ToastStates.error,
            //           context: context,
            //         );
            //       }
            //     },
            //   ),
            // ),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(dialogContext);
            //     },
            //     child: Text(
            //       S.of(context).cancel,
            //       style: TextStyle(
            //         fontSize: 15.0,
            //         color: isDarkTheme ? Colors.white : Colors.black,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            //   TextButton(
            //     onPressed: () async {
            //       chatNameFocusNode.unfocus();
            //       if (CheckCubit.get(context).hasInternet) {
            //         if (formKey.currentState!.validate()) {
            //           String name = chatNameController.text;
            //           Navigator.pop(dialogContext);
            //           showLoading(context, isDarkTheme);
            //           await AppCubit.get(context).editChat(
            //             name: name,
            //             chatId: chatId,
            //             context: context,
            //           );
            //         }
            //       } else {
            //         showFlutterToast(
            //           message: S.of(context).connection_status,
            //           state: ToastStates.error,
            //           context: context,
            //         );
            //       }
            //     },
            //     child: Text(
            //       S.of(context).rename,
            //       style: TextStyle(
            //         fontSize: 15.0,
            //         color: greenColor,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ],
          ),
        ),
      );
    },
  );
}


dynamic showAlertDelete({
  required context,
  required chatId,
  required isChatSelected,
  required isDarkTheme,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          clipBehavior: Clip.antiAlias,
          title: Text(
            S.of(context).delete_request,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              color: redColor.withPredefinedOpacity(0.9),
              letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                S.of(context).no,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (CheckCubit.get(context).hasInternet) {
                  if (isChatSelected) {
                    await AppCubit.get(context).deleteChat(
                      chatId: chatId,
                      isChatSelected: isChatSelected,
                      context: context,
                    );
                  } else {
                    await AppCubit.get(context)
                        .deleteChat(chatId: chatId, context: context);
                  }
                  if (dialogContext.mounted && context.mounted) {
                    Navigator.pop(dialogContext);
                    showLoading(context, isDarkTheme);
                  }
                } else {
                  Navigator.pop(dialogContext);
                  showFlutterToast(
                    message: S.of(context).connection_status,
                    state: ToastStates.error,
                    context: context,
                  );
                }
              },
              child: Text(
                S.of(context).yes,
                style: TextStyle(
                  color: redColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


dynamic showWebAlertDelete({
  required context,
  required chatId,
  required isChatSelected,
  required isDarkTheme,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      HapticFeedback.vibrate();
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          clipBehavior: Clip.antiAlias,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).delete_chat,
                style: TextStyle(
                  fontSize: 19.0,
                  color: redColor.withPredefinedOpacity(0.9),
                  letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.0.vrSpace,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 45.0,
                ),
                child: Divider(
                  color: redColor.withPredefinedOpacity(0.9),
                  thickness: 1.5,
                ),
              ),
            ],
          ),
          content: Text(
            S.of(context).delete_request,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              color: isDarkTheme ? Colors.white : Colors.black,
              letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                S.of(context).no,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (CheckCubit.get(context).hasInternet) {
                  if (dialogContext.mounted && context.mounted) {
                    Navigator.pop(dialogContext);
                    showLoading(context, isDarkTheme);
                  }
                  if (isChatSelected) {
                    await AppCubit.get(context).deleteChat(
                      chatId: chatId,
                      isChatSelected: isChatSelected,
                      context: context,
                    );
                  } else {
                    await AppCubit.get(context)
                        .deleteChat(chatId: chatId, context: context);
                  }
                } else {
                  Navigator.pop(dialogContext);
                  showFlutterToast(
                    message: S.of(context).connection_status,
                    state: ToastStates.error,
                    context: context,
                  );
                }
              },
              child: Text(
                S.of(context).yes,
                style: TextStyle(
                  color: redColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


defaultLanguageDropdown({
  required AppCubit appCubit,
  required CheckCubit checkCubit,
  required isDarkTheme,
  required context,
}) => DropdownButton(
  value: appCubit.localeLang,
  icon: Icon(
    Icons.keyboard_arrow_down_rounded,
    size: 26.0,
    color: isDarkTheme ? Colors.white : Colors.black,
  ),
  padding: EdgeInsets.all(4.0),
  borderRadius: BorderRadius.circular(12.0),
  dropdownColor: isDarkTheme ? ((kIsWeb) ? darkColor2 : darkColor1) : Colors.white,
  enableFeedback: true,
  underline: Container(
    height: 1.5,
    color: isDarkTheme ? Colors.white : Colors.black,
  ),
  items: [
    DropdownMenuItem(
      value: 'en',
      child: Text(
        'English',
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'ar',
      child: Text(
        'العربية',
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    ),
    DropdownMenuItem(
      value: 'fr',
      child: Text(
        'Français',
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
  onChanged: (v) {
    appCubit.localeLangConfig(v);
    if (checkCubit.hasInternet) {
      appCubit.getChats(context);
    }
  },
);


Widget defaultPopUpMenuOptions({
  required chatId,
  required chatName,
  required isChatSelected,
  required chatNameController,
  required chatNameFocusNode,
  required formKey,
  required context,
  required void Function() onOpen,
  required isDarkTheme,
}) => PopupMenuButton(
  enableFeedback: true,
  clipBehavior: Clip.antiAlias,
  color: isDarkTheme ? darkColor2 : Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
  elevation: 8.0,
  menuPadding: EdgeInsets.symmetric(
    vertical: 8.0,
  ),
  itemBuilder: (context) => [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(
                EvaIcons.edit2Outline,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
              12.0.hrSpace,
              Text(
                S.of(context).rename,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(EvaIcons.trash2Outline, color: redColor),
              12.0.hrSpace,
              Text(
                S.of(context).delete,
                style: TextStyle(fontSize: 15.0, color:redColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
  onOpened: onOpen,
  onSelected: (value) async {
    if (value == 'rename') {
      showWebAlertEdit(
        chatId: chatId,
        chatName: chatName,
        context: context,
        chatNameController: chatNameController,
        chatNameFocusNode: chatNameFocusNode,
        formKey: formKey,
        isDarkTheme: isDarkTheme,
      );
    } else if (value == 'delete') {
      showWebAlertDelete(
        context: context,
        chatId: chatId,
        isChatSelected: isChatSelected,
        isDarkTheme: isDarkTheme,
      );
    }
  },
);


Widget buildItemMessage(MessageModel msg, isDarkTheme, context) {
    return FadeIn(
      duration: Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Align(
          alignment:
              (msg.isUser == true)
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(12.0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border:
                  (msg.isUser == false) ? Border.all(
                        width: 1.5,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ) : null,
              color: (msg.isUser == true) ?
                  (Theme.of(context).colorScheme.primary.withPredefinedOpacity(.2)) :
                  (isDarkTheme
                          ? HexColor('303030').withPredefinedOpacity(0.8)
                          : Colors.grey.shade200),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.25,
            ),
            child: SelectableText.rich(
              textDirection: getTextDirection(msg.text?.trim() ?? ''),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: (MediaQuery.of(context).size.width > 450) ? 16.0 : 15.0,
                letterSpacing: (localeLanguage != 'ar') ? 0.6 : 0.0,
                fontWeight: FontWeight.bold,
              ),
              TextSpan(children: buildTextSpans(msg.text?.trim() ?? '', isDarkTheme, context)),
            ),
          ),
        ),
      ),
    );
  }