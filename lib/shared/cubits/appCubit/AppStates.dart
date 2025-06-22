abstract class AppStates {}

class InitialAppState extends AppStates {}


// Lang Detection
class LocaleLangConfigAppState extends AppStates {}


// WebDrawer
class ChangeWebDrawerStateAppState extends AppStates {}


// Change Indexing
class ChangeIndexingAppState extends AppStates {}

class SuccessSelectAndChangeIndexingAppState extends AppStates {}


// Data Profile
class LoadingProfileAppState extends AppStates {}

class SuccessProfileAppState extends AppStates {}

class ErrorProfileAppState extends AppStates {
  dynamic error;

  ErrorProfileAppState(this.error);
}


// Create Chat
class LoadingCreateChatAppState extends AppStates {}

class SuccessCreateChatAppState extends AppStates {}

class ErrorCreateChatAppState extends AppStates {
  dynamic error;

  ErrorCreateChatAppState(this.error);
}


// Create Grouped Chats
class SuccessCreateGroupedChatsAppState extends AppStates {}


// Get Chats
class LoadingGetChatsAppState extends AppStates {}

class SuccessGetChatsAppState extends AppStates {}

class ErrorGetChatsAppState extends AppStates {
  dynamic error;

  ErrorGetChatsAppState(this.error);
}


// Check Existed Chats
class LoadingCheckExistedChatsAppState extends AppStates {}

class SuccessCheckExistedChatsAppState extends AppStates {}

class ErrorCheckExistedChatsAppState extends AppStates {
  dynamic error;

  ErrorCheckExistedChatsAppState(this.error);
}


// Edit Chat
class LoadingEditChatAppState extends AppStates {}

class SuccessEditChatAppState extends AppStates {
  final String message;
  SuccessEditChatAppState({required this.message});
}

class ErrorEditChatAppState extends AppStates {
  dynamic error;

  ErrorEditChatAppState(this.error);
}


// Delete Chat
class LoadingDeleteChatAppState extends AppStates {}

class SuccessDeleteChatAppState extends AppStates {
  final String message;
  SuccessDeleteChatAppState({required this.message});
}

class ErrorDeleteChatAppState extends AppStates {
  dynamic error;

  ErrorDeleteChatAppState(this.error);
}


// Send Message
class ErrorSendMsgAppState extends AppStates {
  dynamic error;

  ErrorSendMsgAppState(this.error);
}


// Add User Message
class LoadingAddUserMsgAppState extends AppStates {}

class SuccessAddUserMsgAppState extends AppStates {}

class ErrorAddUserMsgAppState extends AppStates {
  dynamic error;

  ErrorAddUserMsgAppState(this.error);
}


// Retrieve Output
class LoadingRetrieveOutputAppState extends AppStates {}

class SuccessRetrieveOutputAppState extends AppStates {}

class ErrorRetrieveOutputAppState extends AppStates {
  dynamic error;

  ErrorRetrieveOutputAppState(this.error);
}

// Add Ai Message
class LoadingAddAiMsgAppState extends AppStates {}

class SuccessAddAiMsgAppState extends AppStates {}

class ErrorAddAiMsgAppState extends AppStates {
  dynamic error;

  ErrorAddAiMsgAppState(this.error);
}


// Get Messages
class LoadingGetMessagesAppState extends AppStates {}

class SuccessGetMessagesAppState extends AppStates {

  final bool? isUser;
  SuccessGetMessagesAppState({this.isUser});

}

class ErrorGetMessagesAppState extends AppStates {
  dynamic error;

  ErrorGetMessagesAppState(this.error);
}


// Delete Messages
class LoadingDeleteMessageAppState extends AppStates {}

class SuccessDeleteMessageAppState extends AppStates {}

class ErrorDeleteMessageAppState extends AppStates {
  dynamic error;

  ErrorDeleteMessageAppState(this.error);
}

// Delete All Messages
class LoadingDeleteAllMessagesAppState extends AppStates {}

class SuccessDeleteAllMessagesAppState extends AppStates {}

class ErrorDeleteAllMessagesAppState extends AppStates {
  dynamic error;

  ErrorDeleteAllMessagesAppState(this.error);
}


// Clear Data
class ClearDataAppState extends AppStates {}