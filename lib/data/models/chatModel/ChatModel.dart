
class ChatModel {

  dynamic chatId;
  String? name;
  String? nameLower;
  dynamic createdAt;
  dynamic uId;

  ChatModel({
    this.chatId,
    this.name,
    this.nameLower,
    this.createdAt,
    this.uId
});

  ChatModel.fromJson(Map<String, dynamic> json) {

    chatId = json['chat_id'];
    name = json['name'];
    nameLower = json['name'].toString().toLowerCase();
    createdAt = json['created_at'];
    uId = json['user_id'];

  }


}