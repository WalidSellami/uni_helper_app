
class MessageModel {

  dynamic msgId;
  String? text;
  dynamic createdAt;
  dynamic chattId;
  bool? isUser;

  MessageModel({
    this.msgId,
    this.text,
    this.createdAt,
    this.chattId,
    this.isUser
  });

  MessageModel.fromJson(Map<String, dynamic> json) {

    msgId = json['msg_id'];
    text = json['msg_text'];
    createdAt = json['created_at'];
    chattId = json['chatt_id'];
    isUser = json['is_user'];

  }


}