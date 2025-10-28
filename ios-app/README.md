# Firebase Data App - iOS

Firebase Data APIと連携するiOS (iPhone) アプリケーションです。

## 📱 機能

- ✅ データの作成と送信
- ✅ IDによるデータ取得
- ✅ 全データ一覧表示
- ✅ ID自動生成
- ✅ 入力バリデーション
- ✅ エラーハンドリング
- ✅ ローディング表示

## 📋 データモデル

アプリで扱うデータ：

```swift
struct DataRecord {
    var id: String          // 10文字の一意なID
    var value1: String      // 100文字以内のテキスト
    var value2: String      // 電話番号
}
```

### バリデーションルール

- **ID**: 正確に10文字
- **Value1**: 最大100文字、空でないこと
- **Value2**: 有効な電話番号形式
  - `090-1234-5678`（ハイフン付き）
  - `09012345678`（ハイフンなし）
  - `+81-90-1234-5678`（国際形式）

## 🚀 セットアップ

### 前提条件

- macOS with Xcode 15.0以降
- iOS 17.0以降
- Firebase Data APIがデプロイ済み

### ステップ1: プロジェクトを開く

1. **Xcodeを起動**

2. **新しいプロジェクトを作成**
   - File → New → Project
   - iOS → App を選択
   - Product Name: `FirebaseDataApp`
   - Interface: SwiftUI
   - Language: Swift

3. **ファイルを追加**
   
   プロジェクトに以下のファイルをドラッグ&ドロップ：
   - `Models.swift`
   - `APIClient.swift`
   - `ContentView.swift`
   - `FirebaseDataAppApp.swift`（既存のものを置き換え）

### ステップ2: API URLの設定

`APIClient.swift`を開いて、APIのURLを設定：

```swift
// 13行目あたり
static let baseURL = "https://asia-northeast1-YOUR-PROJECT-ID.cloudfunctions.net/firebase-data-api"
```

**YOUR-PROJECT-ID**を実際のプロジェクトIDに置き換えてください。

### ステップ3: ビルドと実行

1. **シミュレーターを選択**
   - iPhone 15 Pro（推奨）

2. **ビルド**
   - Command + B

3. **実行**
   - Command + R

## 📱 使い方

### データ送信

1. **「送信」タブを選択**

2. **データを入力**
   - **ID**: 10文字入力（または自動生成）
   - **テキスト**: 100文字以内で入力
   - **電話番号**: 電話番号を入力（例: 090-1234-5678）

3. **「送信」ボタンをタップ**
   - データがFirestoreに保存されます

### データ取得

1. **「取得」タブを選択**

2. **IDを入力**
   - 取得したいデータの10文字のID

3. **「取得」ボタンをタップ**
   - データが表示されます

### データ一覧

1. **「一覧」タブを選択**

2. **自動的に全データを取得**
   - リストで表示されます

3. **更新ボタン**
   - 右上の更新アイコンで最新データを取得

## 🏗️ プロジェクト構造

```
FirebaseDataApp/
├── FirebaseDataAppApp.swift    # アプリのエントリーポイント
├── ContentView.swift            # メインビュー（タブビュー）
│   ├── CreateDataView          # データ送信画面
│   ├── FetchDataView           # データ取得画面
│   └── DataListView            # データ一覧画面
├── APIClient.swift              # API通信クライアント
└── Models.swift                 # データモデル定義
```

## 🔧 カスタマイズ

### APIエンドポイントの変更

`APIClient.swift`の`baseURL`を変更：

```swift
static let baseURL = "https://YOUR-NEW-ENDPOINT/firebase-data-api"
```

### UI のカスタマイズ

各View（`CreateDataView`、`FetchDataView`、`DataListView`）は独立しているため、個別にカスタマイズ可能です。

### バリデーションルールの変更

`Models.swift`の`DataRecord`拡張で変更：

```swift
extension DataRecord {
    var isValidID: Bool {
        // カスタムロジック
    }
}
```

## 🐛 トラブルシューティング

### エラー: "無効なURL"

**原因**: API URLが正しく設定されていない

**解決方法**:
1. `APIClient.swift`を開く
2. `baseURL`を確認
3. Firebase Data APIがデプロイされているか確認

### エラー: "サーバーエラー: ID must be exactly 10 characters"

**原因**: IDが10文字でない

**解決方法**:
- IDが正確に10文字であることを確認
- ID自動生成機能を使用

### エラー: "データが見つかりません"

**原因**: 指定したIDのデータが存在しない

**解決方法**:
1. 「一覧」タブで既存のデータを確認
2. 正しいIDを入力

### ビルドエラー

**原因**: ファイルがプロジェクトに正しく追加されていない

**解決方法**:
1. Project Navigator でファイルを確認
2. 必要に応じてファイルを再度追加
3. Target Membership を確認

## 📚 API仕様

このアプリは以下のAPIエンドポイントを使用します：

### POST - データ作成
```
POST /firebase-data-api
Body: {"id": "1234567890", "value1": "テキスト", "value2": "090-1234-5678"}
```

### GET - データ取得（単一）
```
GET /firebase-data-api?id=1234567890
```

### GET - データ取得（全件）
```
GET /firebase-data-api
```

詳細は`cloud-functions/firebase-data-api/README.md`を参照してください。

## 🔒 セキュリティに関する注意

### 本番環境での推奨事項

1. **API認証の追加**
   - 現在は認証なしでアクセス可能
   - 本番環境では認証を実装

2. **HTTPSの使用**
   - 必ずHTTPSを使用（デフォルトで有効）

3. **APIキーの管理**
   - ハードコーディングを避ける
   - 環境変数や設定ファイルを使用

4. **入力サニタイゼーション**
   - アプリ側でも入力を検証
   - SQLインジェクション等の対策

## 🎨 スクリーンショット

（実機またはシミュレーターで実行後、スクリーンショットを追加）

### 送信画面
- ID入力（自動生成オプション付き）
- テキスト入力（文字数カウント）
- 電話番号入力

### 取得画面
- ID入力
- 取得結果表示

### 一覧画面
- 全データのリスト表示
- 更新ボタン

## 📝 今後の機能追加案

- [ ] データの編集機能
- [ ] データの削除機能
- [ ] 検索機能
- [ ] ソート機能
- [ ] オフライン対応
- [ ] ダークモード対応
- [ ] iPad対応
- [ ] watchOS対応

## 🔗 関連リンク

- [Firebase Data API](../cloud-functions/firebase-data-api/README.md)
- [Firebase Setup Guide](../cloud-functions/firebase-data-api/FIREBASE_SETUP.md)
- [API Examples](../cloud-functions/firebase-data-api/API_EXAMPLES.md)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 コントリビューション

プルリクエストを歓迎します！

## 📞 サポート

問題が発生した場合は、GitHubのIssuesで報告してください。
