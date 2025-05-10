import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let kanaConverterChannel = FlutterMethodChannel(name:  "kana_converter", binaryMessenger: controller as! FlutterBinaryMessenger)
    kanaConverterChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "toHiragana":
        guard
          let args = call.arguments as? [String: Any],
          let text = args["text"] as? String
        else {
          result(FlutterError(code: "BAD_ARGS",
                              message: "Expected {text:String}",
                              details: nil))
          return
        }
        if let hira = kanjiToHiragana(text) {
          result(hira)
        } else {
          result(FlutterError(code: "CONVERT_FAIL",
                              message: "Conversion failed",
                              details: nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }



    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


func kanjiToHiragana(_ text: String) -> String? {
    let cfText   = text as CFString
    let fullRange = CFRange(location: 0, length: CFStringGetLength(cfText))
    guard let tokenizer = CFStringTokenizerCreate(
        nil, cfText, fullRange,
        kCFStringTokenizerUnitWord,
        Locale(identifier: "ja") as CFLocale)
    else { return nil }

    var latinPieces: [String] = []
    var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
    while tokenType.rawValue != 0 {
        if let latinObj = CFStringTokenizerCopyCurrentTokenAttribute(
              tokenizer, kCFStringTokenizerAttributeLatinTranscription) {
            let latin = latinObj as! String
            latinPieces.append(latin)
        }
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
    }
    let latinAll = latinPieces.joined()

    let mutable = NSMutableString(string: latinAll) as CFMutableString
    CFStringTransform(mutable, nil, kCFStringTransformLatinHiragana, false)
    return mutable as String
}
