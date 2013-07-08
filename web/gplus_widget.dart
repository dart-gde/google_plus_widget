import 'dart:html';
import 'package:web_ui/web_ui.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";
import "package:google_plus_v1_api/plus_v1_api_browser.dart";

// Simple Authentication class that takes the token from the Sign-in button
SimpleOAuth2 authenticationContext;

// initial value for click-counter
int startingCount = 5;

/**
 * Learn about the Web UI package by visiting
 * http://www.dartlang.org/articles/dart-web-components/.
 */
void main() {
  authenticationContext = new SimpleOAuth2(null);
  // Enable this to use Shadow DOM in the browser.
  //useShadowDom = true;
}
