// import 'dart:convert'; // For JSON encoding and decoding
//
// class UserModel {
//   final String uid;
//   final String phoneNumber;
//   final String userName;
//
//   UserModel({
//     required this.uid,
//     required this.phoneNumber,
//     required this.userName,
//   });
//
//   // Factory method to create a UserModel from a Map (deserialization)
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       uid: map['uid'],
//       phoneNumber: map['phoneNumber'],
//       userName: map['userName'],
//     );
//   }
//
//   // Method to convert UserModel to a Map (serialization)
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'phoneNumber': phoneNumber,
//       'userName': userName,
//     };
//   }
//
//   // Factory method to create a UserModel from a JSON string (deserialization)
//   factory UserModel.fromJson(String source) {
//     return UserModel.fromMap(json.decode(source));
//   }
//
//   // Method to convert UserModel to a JSON string (serialization)
//   String toJson() {
//     return json.encode(toMap());
//   }
// }
