// String verifyCustomerMutation(String contactNo) {
//   return '''
//     mutation VerifyCustomer(\$contactNo: String!) {
//       verifyCustomer(contactNo: \$contactNo) {
//         otp
//         token
//         b2cCustomerId
//         newCustomer
//         firstName
//         lastName
//         email
//         walletId
//       }
//     }
//   ''';
// }

// String upsertFNBCustomerMutation(Map<String, dynamic> userData) {
//   return '''
//     mutation {
//       upsertFNBCustomer(customer: {
//         b2cCustomerId: "${userData['b2cCustomerId']}",
//         firstName: "${userData['firstName']}",
//         lastName: "${userData['lastName']}",
//         mobileNo: "${userData['mobileNo']}",
//         email: "${userData['email']}"
//       }) {
//         status
//         message
//         b2cCustomerId
//       }
//     }
//   ''';
// }
