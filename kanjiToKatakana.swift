import Foundation

/// 漢字フルネーム → ひらがな
func kanjiToHiragana(_ text: String) -> String? {
    // ① Tokenizer を準備
    let cfText   = text as CFString
    let fullRange = CFRange(location: 0, length: CFStringGetLength(cfText))
    guard let tokenizer = CFStringTokenizerCreate(
            nil, cfText, fullRange,
            kCFStringTokenizerUnitWord,
            Locale(identifier: "ja") as CFLocale)
    else { return nil }

    // ② 各トークンのローマ字を取得
    var latinPieces: [String] = []
    var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
    while tokenType.rawValue != 0 {
        if let latinObj = CFStringTokenizerCopyCurrentTokenAttribute(
              tokenizer, kCFStringTokenizerAttributeLatinTranscription) {
            let latin = latinObj as! String        // ←★ ここで String にブリッジ
            latinPieces.append(latin)
        }
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
    }
    let latinAll = latinPieces.joined()

    // ③ Latin → ひらがな → カタカナ
    let mutable = NSMutableString(string: latinAll) as CFMutableString
    CFStringTransform(mutable, nil, kCFStringTransformLatinHiragana, false)
    return mutable as String
}

// ------------------ 動作確認 ------------------
["山田太郎", "佐々木志乃", "一二三太郎", "伊集院静", "John Doe", "タナカタロウ"].forEach { name in
    print(name, "→", kanjiToKatakana(name) ?? "変換失敗")
}
