CJWFacebookWrapper
==================

1. Download and install the Facebook SDK at Facebook [1].

2. In facebook-ios-sdk, open facebook-ios-sdk/src/facebook-ios-sdk.xcodeproj.

3. Build the project.

4. In your project, add the Facebook framework: facebook-ios-sdk/build/FacebookSDK.framework.

5. Register with Facebook and get a Facebook App ID and Facebook Secret ID.

6. Add two keys to Info.plist:
* FacebookAppID (from the Facebook registration)
* FacebookDisplayName (the name of your app as it will appear on the Facebook login page)

7. Add the CJWFacebookWrapper functions to the appropriate classes for AppDelegate and UIViewController.

[1]: http://developer.facebook.com