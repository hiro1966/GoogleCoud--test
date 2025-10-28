# Firebase Data API - Cloud Functions

Firebase Firestoreを使用してデータを格納・取得するRESTful API

## 📋 機能

- ✅ データの作成（POST）
- ✅ データの取得（GET）- 単一/全件対応
- ✅ データの更新（PUT）
- ✅ データの削除（DELETE）
- ✅ データバリデーション
- ✅ CORS対応

## 📊 データモデル

```json
{
  "id": "1234567890",           // 10文字のテキスト（必須）
  "value1": "サンプルテキスト",  // 100文字以内のテキスト（必須）
  "value2": "090-1234-5678"      // 電話番号（必須）
}
```

### データ制約

- **ID**: 正確に10文字
- **Value1**: 最大100文字
- **Value2**: 有効な電話番号形式
  - 090-1234-5678（ハイフン付き）
  - 09012345678（ハイフンなし）
  - +81-90-1234-5678（国際形式）
  - 固定電話、携帯電話対応

## 🚀 API仕様

### ベースURL

```
https://REGION-PROJECT_ID.cloudfunctions.net/firebase-data-api
```

### 1. データ作成（POST）

**エンドポイント**: `POST /`

**リクエストボディ**:
```json
{
  "id": "1234567890",
  "value1": "テストデータ",
  "value2": "090-1234-5678"
}
```

**レスポンス（成功）**:
```json
{
  "success": true,
  "message": "Data stored successfully",
  "data": {
    "id": "1234567890",
    "value1": "テストデータ",
    "value2": "090-1234-5678"
  }
}
```

**curlコマンド例**:
```bash
curl -X POST https://YOUR-FUNCTION-URL/firebase-data-api \
  -H "Content-Type: application/json" \
  -d '{
    "id": "1234567890",
    "value1": "テストデータ",
    "value2": "090-1234-5678"
  }'
```

### 2. データ取得（GET）

#### 2.1 単一データ取得

**エンドポイント**: `GET /?id={ID}`

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "id": "1234567890",
    "value1": "テストデータ",
    "value2": "090-1234-5678",
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
}
```

**curlコマンド例**:
```bash
curl https://YOUR-FUNCTION-URL/firebase-data-api?id=1234567890
```

#### 2.2 全データ取得

**エンドポイント**: `GET /`

**レスポンス**:
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "1234567890",
      "value1": "データ1",
      "value2": "090-1111-1111",
      "created_at": "2024-01-01T00:00:00",
      "updated_at": "2024-01-01T00:00:00"
    },
    {
      "id": "9876543210",
      "value1": "データ2",
      "value2": "080-2222-2222",
      "created_at": "2024-01-01T00:00:00",
      "updated_at": "2024-01-01T00:00:00"
    }
  ]
}
```

**curlコマンド例**:
```bash
curl https://YOUR-FUNCTION-URL/firebase-data-api
```

### 3. データ更新（PUT）

**エンドポイント**: `PUT /`

**リクエストボディ**:
```json
{
  "id": "1234567890",
  "value1": "更新されたデータ",
  "value2": "080-9999-9999"
}
```

**レスポンス**:
```json
{
  "success": true,
  "message": "Data updated successfully",
  "data": {
    "id": "1234567890",
    "value1": "更新されたデータ",
    "value2": "080-9999-9999"
  }
}
```

**curlコマンド例**:
```bash
curl -X PUT https://YOUR-FUNCTION-URL/firebase-data-api \
  -H "Content-Type: application/json" \
  -d '{
    "id": "1234567890",
    "value1": "更新されたデータ",
    "value2": "080-9999-9999"
  }'
```

### 4. データ削除（DELETE）

**エンドポイント**: `DELETE /?id={ID}`

**レスポンス**:
```json
{
  "success": true,
  "message": "Data deleted successfully",
  "id": "1234567890"
}
```

**curlコマンド例**:
```bash
curl -X DELETE https://YOUR-FUNCTION-URL/firebase-data-api?id=1234567890
```

## ❌ エラーレスポンス

### バリデーションエラー

```json
{
  "error": "ID must be exactly 10 characters"
}
```

### データが見つからない

```json
{
  "error": "Data not found"
}
```

### サーバーエラー

```json
{
  "error": "Internal server error",
  "message": "詳細なエラーメッセージ"
}
```

## 🔧 ローカル開発

### 環境変数の設定

Firebase Admin SDKの認証情報が必要です。

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"
```

### ローカルサーバー起動

```bash
# 依存関係をインストール
pip install -r requirements.txt

# ローカルサーバーを起動
functions-framework --target=firebase_data_api --debug
```

### ローカルテスト

```bash
# データ作成
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"id": "test123456", "value1": "テスト", "value2": "090-1234-5678"}'

# データ取得
curl http://localhost:8080?id=test123456

# 全データ取得
curl http://localhost:8080
```

## 📦 デプロイ

### 前提条件

1. Google Cloudプロジェクトが作成されていること
2. Firebase Firestoreが有効化されていること
3. Cloud Functions APIが有効化されていること

### デプロイコマンド

#### Linux/Mac
```bash
./deploy.sh
```

または手動で:
```bash
gcloud functions deploy firebase-data-api \
  --gen2 \
  --runtime=python311 \
  --region=asia-northeast1 \
  --source=. \
  --entry-point=firebase_data_api \
  --trigger-http \
  --allow-unauthenticated
```

#### Windows
```cmd
deploy.bat
```

または手動で:
```cmd
gcloud functions deploy firebase-data-api ^
  --gen2 ^
  --runtime=python311 ^
  --region=asia-northeast1 ^
  --source=. ^
  --entry-point=firebase_data_api ^
  --trigger-http ^
  --allow-unauthenticated
```

### デプロイ後の確認

```bash
# URLを取得
gcloud functions describe firebase-data-api \
  --region=asia-northeast1 \
  --gen2 \
  --format='value(serviceConfig.uri)'

# テスト実行
curl -X POST YOUR-FUNCTION-URL \
  -H "Content-Type: application/json" \
  -d '{"id": "1234567890", "value1": "Hello", "value2": "090-1234-5678"}'
```

## 📚 詳細ドキュメント

- **FIREBASE_SETUP.md** - Firebase Firestoreのセットアップ手順
- **API_EXAMPLES.md** - 各言語でのAPI利用例
- **DEPLOYMENT_GUIDE.md** - 詳細なデプロイ手順

## 🔒 セキュリティ

### 本番環境での推奨設定

1. **認証の有効化**: `--allow-unauthenticated` を削除
2. **Firestore セキュリティルール**の設定
3. **APIキー**または**JWT認証**の追加
4. **レート制限**の設定

### Firestoreセキュリティルール例

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /data_records/{document} {
      // 認証済みユーザーのみ読み書き可能
      allow read, write: if request.auth != null;
    }
  }
}
```

## 💰 料金について

### Cloud Functions
- 月200万回の呼び出しまで無料
- 月40万GB秒のコンピューティング時間まで無料

### Firestore
- 月50,000回の読み取りまで無料
- 月20,000回の書き込みまで無料
- 1GBのストレージまで無料

通常の利用であれば、**無料枠内で運用可能**です。

## 🐛 トラブルシューティング

### Firestoreへの接続エラー

```
google.api_core.exceptions.PermissionDenied
```

**解決方法**:
1. Firebase Firestoreが有効化されているか確認
2. サービスアカウントに適切な権限があるか確認

### デプロイ時のエラー

```
ERROR: (gcloud.functions.deploy) OperationError
```

**解決方法**:
1. Cloud Functions APIが有効化されているか確認
2. Cloud Build APIが有効化されているか確認
3. 適切な権限があるか確認

## 📞 サポート

詳細なセットアップ手順は `FIREBASE_SETUP.md` を参照してください。
