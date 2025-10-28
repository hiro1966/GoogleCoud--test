# iOS アプリ セットアップガイド

Firebase Data APIを使用するiOSアプリの詳細なセットアップ手順です。

## 📋 目次

1. [前提条件](#前提条件)
2. [Xcodeプロジェクトの作成](#xcodeプロジェクトの作成)
3. [ソースコードの追加](#ソースコードの追加)
4. [API URLの設定](#api-urlの設定)
5. [ビルドと実行](#ビルドと実行)
6. [動作確認](#動作確認)
7. [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

### 必要なもの

✅ **Mac**（macOS 13 Ventura以降推奨）  
✅ **Xcode 15.0以降**  
✅ **iOS 17.0以降のシミュレーターまたは実機**  
✅ **Firebase Data APIがデプロイ済み**

### Firebase Data APIの確認

1. APIがデプロイされているか確認
   ```bash
   gcloud functions list --region=asia-northeast1
   ```

2. APIのURLを取得
   ```bash
   gcloud functions describe firebase-data-api \
     --region=asia-northeast1 \
     --gen2 \
     --format='value(serviceConfig.uri)'
   ```

3. URLをメモ（例: `https://asia-northeast1-xxxxx.cloudfunctions.net/firebase-data-api`）

---

## Xcodeプロジェクトの作成

### ステップ1: Xcodeを起動

1. **Xcodeを開く**
   - Launchpadから「Xcode」を起動
   - または、Spotlight検索（Command + Space）で「Xcode」と入力

### ステップ2: 新しいプロジェクトを作成

1. **「Create a new Xcode project」をクリック**

2. **テンプレートを選択**
   - **iOS** タブを選択
   - **App** を選択
   - 「Next」をクリック

3. **プロジェクト情報を入力**
   ```
   Product Name: FirebaseDataApp
   Team: (個人の場合は "None" でOK)
   Organization Identifier: com.yourname (任意)
   Interface: SwiftUI
   Language: Swift
   Storage: None
   ```
   - 「Include Tests」のチェックは外してもOK
   - 「Next」をクリック

4. **保存先を選択**
   - プロジェクトを保存するフォルダを選択
   - 「Create」をクリック

### ステップ3: プロジェクトが開く

以下のようなプロジェクト構造が作成されます：

```
FirebaseDataApp/
├── FirebaseDataApp/
│   ├── FirebaseDataAppApp.swift
│   ├── ContentView.swift
│   └── Assets.xcassets
└── FirebaseDataApp.xcodeproj
```

---

## ソースコードの追加

### 方法1: ファイルをドラッグ&ドロップ（推奨）

1. **Finderでソースコードのフォルダを開く**
   - GitHubからクローンした場合: `ios-app/FirebaseDataApp/`
   - ダウンロードした場合: 解凍したフォルダ内

2. **以下のファイルを選択**
   - `Models.swift`
   - `APIClient.swift`
   - `ContentView.swift`

3. **Xcodeのプロジェクトナビゲーターにドラッグ**
   - 左側の「FirebaseDataApp」フォルダにドラッグ
   - 表示されるダイアログで以下を確認：
     - ✅ Copy items if needed
     - ✅ Create groups
     - ✅ FirebaseDataApp（ターゲット）にチェック
   - 「Finish」をクリック

4. **FirebaseDataAppApp.swiftを置き換え**
   - 既存の`FirebaseDataAppApp.swift`を削除
   - 新しい`FirebaseDataAppApp.swift`を追加

### 方法2: 手動でファイルを作成

各ファイルの内容をコピー&ペーストして作成することもできます。

1. **File → New → File...**
2. **Swift File** を選択
3. ファイル名を入力（例: `Models.swift`）
4. 内容をペースト

---

## API URLの設定

### ステップ1: APIClient.swiftを開く

Xcodeのプロジェクトナビゲーターで`APIClient.swift`をクリック

### ステップ2: baseURLを変更

13行目あたりにある`baseURL`を探す：

```swift
static let baseURL = "https://asia-northeast1-YOUR-PROJECT-ID.cloudfunctions.net/firebase-data-api"
```

### ステップ3: 実際のURLに置き換え

**YOUR-PROJECT-ID**の部分を実際のプロジェクトIDに置き換える：

```swift
// 例
static let baseURL = "https://asia-northeast1-my-project-123456.cloudfunctions.net/firebase-data-api"
```

### ステップ4: 保存

Command + S で保存

---

## ビルドと実行

### ステップ1: シミュレーターを選択

1. **Xcodeの上部ツールバー**を確認
2. **左側のデバイス選択メニュー**をクリック
3. **iPhone 15 Pro**（または任意のiPhoneシミュレーター）を選択

### ステップ2: ビルド

**方法1**: Command + B を押す  
**方法2**: Product → Build をクリック

ビルドが成功すると、左上に「Build Succeeded」と表示されます。

### ステップ3: 実行

**方法1**: Command + R を押す  
**方法2**: Product → Run をクリック  
**方法3**: 左上の▶️（再生）ボタンをクリック

シミュレーターが起動し、アプリが表示されます。

---

## 動作確認

### テスト1: データ送信

1. **「送信」タブを開く**

2. **データを入力**
   ```
   ID: test123456 (または自動生成ボタンをタップ)
   テキスト: テストデータ
   電話番号: 090-1234-5678
   ```

3. **「送信」ボタンをタップ**

4. **成功メッセージを確認**
   - 「送信完了」アラートが表示されればOK

### テスト2: データ取得

1. **「取得」タブを開く**

2. **IDを入力**
   ```
   ID: test123456 (先ほど送信したID)
   ```

3. **「取得」ボタンをタップ**

4. **データが表示されることを確認**

### テスト3: データ一覧

1. **「一覧」タブを開く**

2. **データリストが表示されることを確認**

3. **右上の更新ボタンをタップ**して最新データを取得

---

## トラブルシューティング

### ビルドエラー: "Cannot find 'XXX' in scope"

**原因**: ファイルが正しく追加されていない

**解決方法**:
1. プロジェクトナビゲーターでファイルを選択
2. 右側のインスペクターで「Target Membership」を確認
3. 「FirebaseDataApp」にチェックが入っているか確認

### ビルドエラー: "No such module 'XXX'"

**原因**: 外部ライブラリが必要だが追加されていない

**解決方法**:
このアプリは外部ライブラリを使用していないため、このエラーは発生しないはずです。

### 実行時エラー: "無効なURL"

**原因**: API URLが正しく設定されていない

**解決方法**:
1. `APIClient.swift`を開く
2. `baseURL`を確認
3. 正しいURLに変更して再ビルド

### 実行時エラー: "サーバーエラー"

**原因**: Firebase Data APIに問題がある

**解決方法**:
1. APIがデプロイされているか確認
   ```bash
   gcloud functions list --region=asia-northeast1
   ```

2. APIのログを確認
   ```bash
   gcloud functions logs read firebase-data-api \
     --region=asia-northeast1 \
     --gen2 \
     --limit=50
   ```

3. ブラウザで直接APIにアクセスしてみる
   ```
   https://YOUR-API-URL
   ```

### シミュレーターが起動しない

**原因**: Xcodeまたはシミュレーターの問題

**解決方法**:
1. Xcode → Window → Devices and Simulators
2. シミュレーターを選択して「Delete」
3. 「+」ボタンで新しいシミュレーターを追加
4. 再度実行

### アプリが真っ白になる

**原因**: ContentViewが正しく設定されていない

**解決方法**:
1. `FirebaseDataAppApp.swift`を確認
2. 以下のようになっているか確認：
   ```swift
   var body: some Scene {
       WindowGroup {
           ContentView()
       }
   }
   ```

---

## 実機でのテスト

### 前提条件

- Apple Developer アカウント（無料でOK）
- iPhoneとMacをUSBケーブルで接続

### ステップ1: 実機を信頼

1. iPhoneをMacに接続
2. iPhone画面で「このコンピュータを信頼しますか？」→「信頁」

### ステップ2: Signingを設定

1. Xcodeでプロジェクトを選択
2. 「Signing & Capabilities」タブを開く
3. 「Team」で自分のApple IDを選択
4. 「Automatically manage signing」にチェック

### ステップ3: 実機を選択して実行

1. デバイス選択メニューで実機を選択
2. Command + R で実行

### ステップ4: 実機で信頼

初回実行時、iPhoneで以下の操作が必要：

1. 設定 → 一般 → VPNとデバイス管理
2. 開発元アプリを選択
3. 「信頼」をタップ

---

## 次のステップ

### カスタマイズ

- UIのカスタマイズ（色、フォント、レイアウト）
- 追加機能の実装（編集、削除など）
- エラーハンドリングの強化

### デバッグ

- Xcodeのコンソールでログを確認
- ブレークポイントを設定してデバッグ

### App Storeへの公開

1. Apple Developer Programに登録（$99/年）
2. App Store Connect でアプリを登録
3. アプリをアーカイブ
4. App Store に提出

---

## 参考リンク

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)

## サポート

問題が発生した場合：

1. このガイドのトラブルシューティングを確認
2. Firebase Data APIのログを確認
3. GitHubのIssuesで質問

---

おめでとうございます！これでiOSアプリのセットアップが完了しました🎉
