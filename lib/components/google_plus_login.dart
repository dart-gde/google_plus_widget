import 'dart:html';
import 'dart:json' as JSON;
import "package:js/js.dart" as js;
import 'package:web_ui/web_ui.dart';
import "package:google_oauth2_client/google_oauth2_browser.dart";

/**
 * Sign-in callback signature. 
 */
typedef OnSignInCallback(SimpleOAuth2 authenticationContext, [Map authResult]);

/**
 * Sign-out callback signature.
 */
typedef OnSignOutCallback();

/**
 * On error signature.
 */
typedef OnErrorCallback(error);

/**
 * Google plus login web component.
 */
@observable
class GooglePlusLogin extends WebComponent {
  bool isConnected = false;
  
  // https://developers.google.com/+/web/signin/
  String scope = "https://www.googleapis.com/auth/plus.login";
  String requestvisibleactions = "http://schemas.google.com/AddActivity";
  String clientId = "YOUR_CLIENT_ID";
  String theme = "dark";
  String cookiepolicy = "single_host_origin";
  
  String width = "standard";
  String height = "standard";
  String approvalprompt = "auto";
  String accesstype = "online";
  
  // Following objects need to be assigned via web component
  OnSignInCallback signInCallback;
  OnSignOutCallback signOutCallback;
  OnErrorCallback errorCallback;
  SimpleOAuth2 authenticationContext;
  
  String _revokeJsonpCallback = "revokeJsonpCallback";
  ScriptElement _revokeScript;
  ScriptElement _plusoneScript;
  
  /**
   * Safe method for sending error callbacks.
   */
  _sendError(error) {
// TODO(adam): switch out to logging
    print("_sendError($error)");
    if (errorCallback != null) {
      errorCallback(error);
    }
  }
  
  /**
   * Internal signin callback method. 
   */
  void _onSignInCallback(Map authenticationResult) {
    // TODO(adam): switch out to logging
    print("authenticationResult = $authenticationResult");
    
    if (authenticationContext == null) {
      _sendError("authenticationContext is not binded to a object");
      return;
    }

    if (authenticationResult["access_token"] != null) {
      // Enable Authenticated requested with the granted token in the client libary
      authenticationContext.token = authenticationResult["access_token"];
      authenticationContext.tokenType = authenticationResult["token_type"];
      isConnected = true;
      print("isConnected = $isConnected");
      // Fire the signin callback
      if (signInCallback != null) {
        signInCallback(authenticationContext, authenticationResult);
      }
    } else if (authenticationResult["error"] != null) {
      // TODO(adam): switch out to logging
      isConnected = false;
      print("isConnected = $isConnected");
      print("There was an error: ${authenticationResult["error"]}");
      _sendError(authenticationResult["error"]);
    }
  }
  
  /**
   * Disconnect handler for disconnect button.
   */
  void disconnect(event) {
    _createJsSignOutCallback();
    _insertRevokeScript();
  }
  
  /**
   * Construct signin callback and insert plusone script when component is created.
   */
  void created() {
    _createJsSignInCallback();
    _insertPlusOneScript();
  }
  
  /**
   * Create javascript callbacks for signin.
   */
  _createJsSignInCallback() {
    js.scoped(() {
      var reviverOAuth = new js.Callback.many((key, value) {
        if (key == "g-oauth-window") {
          return "";
        } else if (key == "error") {
          // TODO(adam): use logging or handle exception.
          print("TODO(adam): key == error");
        }
  
        return value;
      });
      
      // Create a javascript signin callback proxy
      var jsSignInCallback = new js.Callback.many((js.Proxy jsAuthenticationResult) {
        // Create dart map of authentication result
        Map authenticationResult =
            JSON.parse(js.context["JSON"]["stringify"](jsAuthenticationResult, reviverOAuth));
        // Call internal signin callback
        _onSignInCallback(authenticationResult);
      });
      
      // Assign the callback to the javascript context
      js.context["onSignInCallback"] = jsSignInCallback;
    });
  }
  
  /**
   * Create the javascript signout callback.
   */
  _createJsSignOutCallback() {
    js.scoped(() {
      // JSONP workaround because the accounts.google.com endpoint doesn't allow CORS
      var jsRevokeJsonpCallback = new js.Callback.once(([jsonData]) {
        // disable authenticated requests in the client library
        authenticationContext.token = null;
        isConnected = false;
        print("isConnected = $isConnected");
        _removeScripts();
        _insertPlusOneScript();
        
        if (signOutCallback != null) {
          signOutCallback();
        }

      });
      
      js.context[_revokeJsonpCallback] = jsRevokeJsonpCallback;
    });
  }
  
  /**
   * Insert the google plus one script.
   */
  void _insertPlusOneScript() {
    _plusoneScript = new ScriptElement()
    ..async = true
    ..type = "text/javascript"
    ..src = "https://plus.google.com/js/client:plusone.js";
    document.body.children.add(_plusoneScript);
    // TODO(adam): try just adding it to this web component 
    // instead of the body of this web component.
  }
  
  /**
   * Insert a script to revoke access. Callback using JSONP.
   */
  _insertRevokeScript() {
    _revokeScript = new Element.tag("script")
    ..src = "https://accounts.google.com/o/oauth2/revoke?token=${authenticationContext.token}&callback=$_revokeJsonpCallback";
    document.body.children.add(_revokeScript);
  }
  
  _removeScripts() {
    _removeRevokeScript();
    _removePlusOneScript();
  }
  
  _removeRevokeScript() => document.body.children.remove(_revokeScript);
  _removePlusOneScript() => document.body.children.remove(_plusoneScript);
}