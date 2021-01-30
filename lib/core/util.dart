import 'dart:io';

Future<bool> get hasInternet async {
  var result = [];
  try {
    result = await InternetAddress.lookup('google.com');
  } on SocketException catch (_) {
    return false;
  }
  if (result.isEmpty || result[0].rawAddress.isEmpty) return false;
  return true;
}
