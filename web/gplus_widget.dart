import 'dart:html';
import 'package:web_ui/web_ui.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:google_plus_v1_api/plus_v1_api_browser.dart";

// Simple Authentication class that takes the token from the Sign-in button
SimpleOAuth2 authenticationContext;

onSignInCallback(SimpleOAuth2 authContext, [Map authResult]) {
  print("SignInCallback");
  print("authResult = $authResult");
}

onSignOutCallback() {
  print("onSignOutCallback");
}

onErrorCallback(error) {
  print("onErrorCallback($error)");
}

void main() {
  authenticationContext = new SimpleOAuth2(null);
}
