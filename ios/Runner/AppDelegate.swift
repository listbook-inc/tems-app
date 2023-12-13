import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    } 
    
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let sandboxChannel = FlutterMethodChannel(name: "com.example.app/sandbox",
                                              binaryMessenger: controller.binaryMessenger)
    sandboxChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if call.method == "isSandbox" {
        result(self.isSandboxEnvironment())
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  private func isSandboxEnvironment() -> Bool {
    if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
       appStoreReceiptURL.lastPathComponent == "sandboxReceipt" {
      return true
    }
    return false
  }
}

