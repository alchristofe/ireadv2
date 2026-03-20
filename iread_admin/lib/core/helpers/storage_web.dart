import 'dart:html' as html;

Future<void> saveLoginState(bool isLoggedIn) async {
  html.window.localStorage['isLoggedIn'] = isLoggedIn.toString();
}

Future<bool> getLoginState() async {
  return html.window.localStorage['isLoggedIn'] == 'true';
}

Future<void> clearLoginState() async {
  html.window.localStorage.remove('isLoggedIn');
}
