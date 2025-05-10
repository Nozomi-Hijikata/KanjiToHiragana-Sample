import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kana Form Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _kanjiCtrl = TextEditingController();
  final _kanaCtrl = TextEditingController();

  static const _kanaChannel = MethodChannel('kana_converter');

  @override
  void initState() {
    super.initState();
    // 漢字フィールド更新時にフリガナを反映
    _kanjiCtrl.addListener(_onKanjiChanged);
  }

  Future<String> _convertToKana(String kanji) async {
    final hiragana = await _kanaChannel.invokeMethod<String>('toHiragana', {
      'text': kanji,
    });
    return _kanaCtrl.text = hiragana ?? '';
  }

  void _onKanjiChanged() async {
    final kana = await _convertToKana(_kanjiCtrl.text);
    // TextEditingController 経由でフリガナ欄を更新
    _kanaCtrl.value = _kanaCtrl.value.copyWith(
      text: kana,
      selection: TextSelection.collapsed(offset: kana.length),
    );
  }

  @override
  void dispose() {
    _kanjiCtrl.dispose();
    _kanaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ふりがな自動入力デモ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kanjiCtrl,
              decoration: const InputDecoration(
                labelText: '姓・名（漢字）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kanaCtrl,
              readOnly: true, // ユーザ手入力させない場合
              decoration: const InputDecoration(
                labelText: 'フリガナ（自動入力）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
