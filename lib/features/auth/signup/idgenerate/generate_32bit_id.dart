import 'package:uuid/uuid.dart';

String generateB2CCustomerId() {
  var uuid = Uuid();
  return uuid.v4().replaceAll('-', '').toUpperCase().substring(0, 32);
}
