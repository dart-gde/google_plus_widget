# google_plus_widget

### Description

### Usage

Import the pub package.

```
dependencies:
  google_plus_widget: any
```

In the html file import and include the google plus login web component.

```
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="gplus_widget.css">
    <!-- import the google plus login widget -->
    <link rel="import" href="packages/google_plus_widget/components/google_plus_login.html">
  </head>
  <body>
    <!-- Add a google plus signin widget -->
    <div is="x-google-plus-login"
         client-id="CLIENT_ID"
         theme="light"
         authentication-context="{{authenticationContext}}"
         sign-in-callback="{{onSignInCallback}}"
         sign-out-callback="{{onSignOutCallback}}"
         error-callback="{{onErrorCallback}}"></div>
    <script type="application/dart" src="gplus_widget.dart"></script>
    <script src="packages/browser/dart.js"></script>
    <script src="packages/browser/interop.js"></script>
  </body>
</html>
```

Include callback methods and authentication context.

```
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
```