class CustomerModel {
  final int? otp;
  final String? token;
  final String? b2cCustomerId;
  final bool? newCustomer;
  final String? mobileNo;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? walletId;

  CustomerModel({
    this.otp,
    this.token,
    this.b2cCustomerId,
    this.newCustomer = false, // Default value added
    this.mobileNo,
    this.firstName,
    this.lastName,
    this.email,
    this.walletId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      otp: json['otp'],
      token: json['token'],
      b2cCustomerId: json['b2cCustomerId'],
      newCustomer: json['newCustomer'] ?? false, // Added null safety
      mobileNo: json['mobileNo'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      walletId: json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'token': token,
      'b2cCustomerId': b2cCustomerId,
      'newCustomer': newCustomer,
      'mobileNo': mobileNo,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'walletId': walletId,
    };
  }
}
