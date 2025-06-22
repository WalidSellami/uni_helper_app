
class UserModel {

  dynamic userId;
  String? fullName;
  String? imageProfile;
  String? registrationNumber;
  dynamic createdAt;

  UserModel({
    this.userId,
    this.fullName,
    this.imageProfile,
    this.registrationNumber,
    this.createdAt
});


  UserModel.fromJson(Map<String, dynamic> json) {

    userId = json['user_id'];
    fullName = json['full_name'];
    imageProfile = json['image_profile'];
    registrationNumber = json['registration_number'];
    createdAt = json['created_at'];

  }




}