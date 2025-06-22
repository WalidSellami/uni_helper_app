import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uni_helper/data/models/chatModel/ChatModel.dart';
import 'package:uni_helper/data/models/messageModel/MessageModel.dart';
import 'package:uni_helper/data/models/userModel/UserModel.dart';
import 'package:uni_helper/generated/l10n.dart';
import 'package:uni_helper/presentation/modules/startUpModule/signInScreen/SignInScreen.dart';
import 'package:uni_helper/presentation/webModules/startUpWebModule/signInWebScreen/SignInWebScreen.dart';
import 'package:uni_helper/shared/components/Components.dart';
import 'package:uni_helper/shared/cubits/appCubit/AppStates.dart';
import 'package:uni_helper/shared/network/local/CacheHelper.dart';
import 'package:uni_helper/shared/network/remote/DioHelper.dart';
import 'package:uni_helper/shared/utils/Constants.dart';

class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);


  String localeLang = 'en';

  Future<void> localeLangConfig(lang) async {
    localeLang = lang;
    await CacheHelper.saveCachedData(key: 'localeLang', value: lang).then((value) {
      localeLanguage = lang;
    });
    emit(LocaleLangConfigAppState());
  }


  int? globalIndex;
  int? innerIndex;
  int? selectInnerIndex;

  void changeIndexing(gIndex, iIndex) {
    globalIndex = gIndex;
    innerIndex = iIndex;

    emit(ChangeIndexingAppState());
  }

  // When chat is removed
  void selectAndChangeIndexing({
    required int gIndex,
    required int iIndex,
    bool canChange = false
  }) {
    if(globalIndex == gIndex) {
      selectInnerIndex = iIndex;

      if(canChange) {
        if(selectInnerIndex! < innerIndex!) {
          innerIndex = selectInnerIndex;
        }
      }
    }

    emit(SuccessSelectAndChangeIndexingAppState());
  }


  void clearIndexing() {
    globalIndex = null;
    innerIndex = null;
    selectInnerIndex = null;
    emit(ClearDataAppState());
  }


  UserModel? userModel;

  Future<void> userProfile() async {

    emit(LoadingProfileAppState());

    await DioHelper.getData(pathUrl: '/profile/$userId').then((value) {

      if(value?.data['user_id'] == userId) {
          userModel = UserModel.fromJson(value?.data);
        }

      emit(SuccessProfileAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in user profile');
      }

      String errorMessage = 'Something went wrong. Please try again later.';

      if (error is DioException) {
        if (kDebugMode) {
          print('DioException --> ${error.message}');
        }

        if (error.response != null) {
          final response = error.response!;
          // final statusCode = response.statusCode;
          final data = response.data;

          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          }

        } else {
          if (kDebugMode) {
            print('No response from server.');
          }
        }

      } else {
        if (kDebugMode) {
          print('Unknown error: $error');
        }
      }

      emit(ErrorProfileAppState(errorMessage));

    });

  }


  Future<void> signOut(context, isDarkTheme) async {

    showLoading(context, isDarkTheme);
    await CacheHelper.removeCachedData(key: 'userId').then((value) async {
      if(value = true) {
        userId = null;
      }

      await Future.delayed(Duration(milliseconds: 1500)).then((value) {
        Navigator.pop(context);
        if(kIsWeb) {
          navigateAndNotReturn(context: context, screen: SignInWebScreen());
        } else {
          navigateAndNotReturn(context: context, screen: SignInScreen());
        }
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          clearData();
        });
      });
    });
  }

  List<MessageModel> messages = [];


  Future<void> sendMessage({
    required String text,
    required dynamic chatId,
    required BuildContext context
}) async {

    if(messages.isEmpty) {

      List<dynamic> existedChats = await checkExistedChat(name: text);

      if(context.mounted) {

        if(existedChats.isEmpty) {

          await createChat(name: text, text: text, uId: userId, context: context);

        } else {

          await createChat(name: '$text (same_name)', text: text,
              uId: userId, context: context);

        }

      }

    } else {

      await addUserMsg(msgText: text, chatId: chatId).then((value) async {
        await getMessages(chatId: chatId);
      });

      if(context.mounted) {
        await retrieveOutput(text: text, chatId: chatId, context: context);
      }

    }

  }


  Future<void> createChat({
    required String name,
    required String text,
    required dynamic uId,
    required BuildContext context
}) async {

    emit(LoadingCreateChatAppState());

    await DioHelper.postData(
        pathUrl: '/create_chat',
        data: {
          'name': name,
          'name_lower': name.toLowerCase(),
          'user_id': uId
        }).then((value) async {

          dynamic chatId = value?.data['chat_id'];
          changeIndexing(0, 0);

          if(context.mounted) {
            await getChats(context);
          }

          await addUserMsg(msgText: text, chatId: chatId).then((value) async {
            await getMessages(chatId: chatId);
          });

          if(context.mounted) {
            await retrieveOutput(text: text, chatId: chatId, context: context);
          }


    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in create chat');
      }

      emit(ErrorCreateChatAppState(error));
    });

  }


  Future<List<dynamic>> checkExistedChat({
    required String name
}) async {

    emit(LoadingCheckExistedChatsAppState());

    List<dynamic> existedChats = [];

    await DioHelper.postData(
        pathUrl: '/check_existed_chats/$userId',
        data: {
          'name': name
        }).then((value) {

          existedChats = value?.data['chats'];

          emit(SuccessCheckExistedChatsAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in check existed chats');
      }

      emit(ErrorCheckExistedChatsAppState(error));

    });


    return existedChats;
  }



  List<ChatModel> chats = [];

  Map<String, List<ChatModel>> groupedChats = {};


  Future<void> getChats(context) async {

    emit(LoadingGetChatsAppState());

    await DioHelper.getData(
        pathUrl: '/chats/$userId').then((value) {

          chats = [];
          groupedChats = {};

          for (var chat in value?.data['chats']) {
            chats.add(ChatModel.fromJson(chat));
          }

          createChatGroups(chats: chats, context: context);

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in get chats');
      }

      emit(ErrorGetChatsAppState(error));
    });

  }


  void createChatGroups({
    required List<ChatModel> chats,
    required BuildContext context
}) {

    for(var chat in chats) {

      String status = categorizeDate(chat.createdAt, context);

      groupedChats.putIfAbsent(status, () => []);
      groupedChats[status]?.add(chat);

    }

    emit(SuccessCreateGroupedChatsAppState());

  }



  String categorizeDate(String date, context) {
    DateTime chatDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    Duration difference = now.difference(chatDate);

    if (difference.inDays >= 365) {
      return S.of(context).previous_year;
    }

    for (int i = 11; i >= 1; i--) {
      if (difference.inDays >= i * 30) {
        if (i == 1) {
          return S.of(context).previous_30_days;
        } else {
          DateTime targetDate = DateTime(now.year, now.month - i);
          return DateFormat.MMMM(localeLang).format(targetDate);
        }
      }
    }

    if (difference.inDays >= 15) {
      return S.of(context).previous_15_days;
    } else if (difference.inDays >= 7) {
      return S.of(context).previous_7_days;
    } else if (difference.inDays >= 3) {
      return S.of(context).previous_3_days;
    } else if (difference.inDays >= 1) {
      return S.of(context).yesterday;
    } else {
      return S.of(context).today;
    }
  }



  Future<void> editChat({
    required String name,
    required dynamic chatId,
    required BuildContext context
}) async {

    emit(LoadingEditChatAppState());

    await DioHelper.putData(
        pathUrl: '/update_chat/$userId/$chatId/$localeLang',
        data: {
          'name': name,
          'name_lower': name.toLowerCase(),
          'user_id': userId
        }).then((value) {

          if(context.mounted) {
            getChats(context);
          }

       emit(SuccessEditChatAppState(message: value?.data['message']));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in edit chat');
      }

      String errorMessage = '';

      if(context.mounted) {
        errorMessage = S.of(context).error_message;
      }

      emit(ErrorEditChatAppState(errorMessage));
    });

  }


  Future<void> deleteChat({
    required dynamic chatId,
    required BuildContext context,
    bool isChatSelected = false
  }) async {

    emit(LoadingDeleteChatAppState());

    await DioHelper.deleteData(
      pathUrl: '/delete_chat/$chatId/$localeLang').then((value) {

        if(context.mounted) {
          getChats(context);
        }

        if(isChatSelected) {
         getMessages(chatId: chatId);
        }

      emit(SuccessDeleteChatAppState(message: value?.data['message']));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in delete chat');
      }

      String errorMessage = '';

      if(context.mounted) {
        errorMessage = S.of(context).error_message;
      }

      emit(ErrorDeleteChatAppState(errorMessage));
    });

  }



  Future<void> addUserMsg({
    required String msgText,
    required dynamic chatId
  }) async {

    emit(LoadingAddUserMsgAppState());

    await DioHelper.postData(
        pathUrl: '/add_user_message',
        data: {
          'text': msgText,
          'chat_id': chatId
        }).then((value) {


      emit(SuccessAddUserMsgAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in add user msg');
      }

      emit(ErrorAddUserMsgAppState(error));

    });

  }



  Future<void> retrieveOutput({
    required String text,
    required dynamic chatId,
    required BuildContext context
}) async {

    emit(LoadingRetrieveOutputAppState());

    await DioHelper.postData(
        pathUrl: '/retrieve_output',
        data: {
          'text': text
        }).then((value) async {

          dynamic output = value?.data['output'];

          await addAiMsg(msgText: output, chatId: chatId).then((value) async {
            await getMessages(chatId: chatId, isUser: false);
          });


        }).catchError((error) {

          if(kDebugMode) {
            print('${error.toString()} --> in retrieve output');
          }

          String errorMessage = '';

          if(context.mounted) {
            errorMessage = S.of(context).error_message;
          }

       emit(ErrorRetrieveOutputAppState(errorMessage));
    });

  }


  Future<void> addAiMsg({
    required String msgText,
    required dynamic chatId
}) async {

    emit(LoadingAddAiMsgAppState());

    await DioHelper.postData(
        pathUrl: '/add_ai_message',
        data: {
          'text': msgText,
          'chat_id': chatId
        }).then((value) {

          emit(SuccessAddAiMsgAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in add ai msg');
      }

      emit(ErrorAddAiMsgAppState(error));

    });

  }




  Future<void> getMessages({
    required dynamic chatId,
    bool? isUser,
}) async {

    emit(LoadingGetMessagesAppState());

    await DioHelper.getData(pathUrl: '/messages/$chatId').then((value) {

      messages = [];

      for (var message in value?.data['messages']) {
        messages.add(MessageModel.fromJson(message));
      }


      // order messages as user -> ai (pairs)
      // reorderMessages(isUser);

      emit(SuccessGetMessagesAppState(isUser: isUser));


    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in get messages');
      }

      emit(ErrorGetMessagesAppState(error));
    });
    
  }


  dynamic reorderMessages(bool? isUser) {

    // Reorder to alternate user/ai
    List<MessageModel> reordered = [];
    List<MessageModel> remaining = List.from(messages);
    bool? expectUser = remaining.first.isUser;

    while (remaining.isNotEmpty) {
      final index = remaining.indexWhere((msg) => msg.isUser == expectUser);
      if (index != -1) {
        reordered.add(remaining.removeAt(index));
        expectUser = !expectUser!;
      } else {
        reordered.addAll(remaining);
        break;
      }
    }

    messages = reordered;

    emit(SuccessGetMessagesAppState(isUser: isUser));

  }


  Future<void> deleteMessage({
    required dynamic chatId,
    required dynamic msgId
  }) async {

    emit(LoadingDeleteMessageAppState());

    await DioHelper.deleteData(
        pathUrl: '/delete_message/$chatId/$msgId'
    ).then((value) async {

      await getMessages(chatId: chatId);
    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in delete messages');
      }

      emit(ErrorDeleteMessageAppState(error));
    });


  }

  
  Future<void> deleteMessages({
    required dynamic chatId
}) async {

    emit(LoadingDeleteAllMessagesAppState());
    
    await DioHelper.deleteData(
        pathUrl: '/delete_all_messages/$chatId'
    ).then((value) async {

      await getMessages(chatId: chatId);
    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in delete messages');
      }

      emit(ErrorDeleteAllMessagesAppState(error));
    });
    
    
  }






  void clearData({
    bool isNewChat = false
}) {

    if(isNewChat) {
      messages.clear();
      clearIndexing();
    } else {
      chats.clear();
      groupedChats.clear();
      messages.clear();
      clearIndexing();
      userModel = null;
    }

    emit(ClearDataAppState());

  }



}