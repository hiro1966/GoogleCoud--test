# Firebase Firestore セットアップガイド

このガイドでは、Firebase FirestoreをCloud Functionsと連携させる手順を説明します。

## 🎯 概要

このAPIは、Google Cloud FunctionsとFirebase Firestoreを連携して動作します。
Firestoreは、Google Cloudプロジェクトで自動的に利用可能になります。

## 📋 セットアップ手順

### ステップ1: Google Cloudプロジェクトの準備

1. **Google Cloud Consoleにアクセス**
   - https://console.cloud.google.com/

2. **プロジェクトを選択または作成**
   - 既存のプロジェクトを使用する、または新規作成

### ステップ2: Firestore データベースの有効化

#### Web UI（推奨）

1. **Firestoreページに移動**
   - https://console.cloud.google.com/firestore
   - または、左メニュー → Firestore

2. **データベースを作成**
   - 「データベースを作成」ボタンをクリック

3. **モードを選択**
   - **本番モード**を選択（推奨）
   - または「テストモード」（開発時のみ）
   - 「次へ」をクリック

4. **ロケーションを選択**
   - **asia-northeast1 (東京)** を推奨
   - 「有効にする」をクリック

5. **完了を待つ**
   - 数分でデータベースが作成されます

#### gcloud CLI

```bash
# Firestore APIを有効化
gcloud services enable firestore.googleapis.com

# Firestoreデータベースを作成
gcloud firestore databases create --location=asia-northeast1
```

### ステップ3: Firestoreセキュリティルールの設定

#### 開発環境用（テストモード）

**注意**: 開発時のみ使用してください。本番環境では使用しないでください。

1. Firestore Console → ルール
2. 以下のルールを設定:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

3. 「公開」をクリック

#### 本番環境用（推奨）

1. Firestore Console → ルール
2. 以下のルールを設定:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // data_records コレクションのルール
    match /data_records/{recordId} {
      // 認証済みユーザーのみ読み書き可能
      allow read, write: if request.auth != null;
      
      // または、Cloud Functionsからのみアクセス許可
      // allow read, write: if request.auth.token.email.matches('.*@.*\\.iam\\.gserviceaccount\\.com$');
    }
  }
}
```

3. 「公開」をクリック

### ステップ4: 必要なAPIの有効化

以下のAPIが有効になっているか確認してください：

1. **Cloud Firestore API**
   - https://console.cloud.google.com/apis/library/firestore.googleapis.com

2. **Cloud Functions API**
   - https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com

3. **Cloud Build API**
   - https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com

#### gcloud CLIで有効化

```bash
gcloud services enable firestore.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### ステップ5: サービスアカウント権限の確認

Cloud Functionsは自動的にサービスアカウントを使用します。
適切な権限があることを確認してください。

1. **IAMページに移動**
   - https://console.cloud.google.com/iam-admin/iam

2. **サービスアカウントを確認**
   - `PROJECT_ID@appspot.gserviceaccount.com` が存在することを確認
   - 以下のロールがあることを確認:
     - Cloud Functions Developer
     - Cloud Datastore User（または Owner）

3. **権限がない場合は追加**
   - 「メンバーを追加」をクリック
   - サービスアカウントのメールアドレスを入力
   - ロールを選択して保存

## 🚀 Cloud Functionsのデプロイ

### 前提条件の確認

```bash
# 現在のプロジェクトを確認
gcloud config get-value project

# Firestoreデータベースが存在するか確認
gcloud firestore databases list
```

### デプロイ実行

#### 自動デプロイスクリプト（推奨）

**Linux/Mac**:
```bash
cd cloud-functions/firebase-data-api
./deploy.sh
```

**Windows**:
```cmd
cd cloud-functions\firebase-data-api
deploy.bat
```

#### 手動デプロイ

**Linux/Mac**:
```bash
cd cloud-functions/firebase-data-api

gcloud functions deploy firebase-data-api \
  --gen2 \
  --runtime=python311 \
  --region=asia-northeast1 \
  --source=. \
  --entry-point=firebase_data_api \
  --trigger-http \
  --allow-unauthenticated
```

**Windows**:
```cmd
cd cloud-functions\firebase-data-api

gcloud functions deploy firebase-data-api ^
  --gen2 ^
  --runtime=python311 ^
  --region=asia-northeast1 ^
  --source=. ^
  --entry-point=firebase_data_api ^
  --trigger-http ^
  --allow-unauthenticated
```

## 🧪 デプロイ後のテスト

### 1. URLの取得

```bash
gcloud functions describe firebase-data-api \
  --region=asia-northeast1 \
  --gen2 \
  --format='value(serviceConfig.uri)'
```

URLをメモしておいてください（例: `https://asia-northeast1-PROJECT_ID.cloudfunctions.net/firebase-data-api`）

### 2. データ作成テスト

```bash
curl -X POST YOUR-FUNCTION-URL \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test123456",
    "value1": "テストデータ",
    "value2": "090-1234-5678"
  }'
```

**期待される結果**:
```json
{
  "success": true,
  "message": "Data stored successfully",
  "data": {
    "id": "test123456",
    "value1": "テストデータ",
    "value2": "090-1234-5678"
  }
}
```

### 3. データ取得テスト

```bash
curl YOUR-FUNCTION-URL?id=test123456
```

**期待される結果**:
```json
{
  "success": true,
  "data": {
    "id": "test123456",
    "value1": "テストデータ",
    "value2": "090-1234-5678",
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
}
```

### 4. Firestore Consoleで確認

1. Firestore Console → データ
   - https://console.cloud.google.com/firestore/data

2. `data_records` コレクションを確認

3. `test123456` ドキュメントが存在することを確認

## 🔍 データの確認と管理

### Web UIでデータを確認

1. **Firestoreコンソールを開く**
   - https://console.cloud.google.com/firestore/data

2. **コレクションを選択**
   - `data_records` コレクションをクリック

3. **ドキュメントを表示**
   - 各ドキュメントのIDと内容を確認できます

4. **データの編集・削除**
   - ドキュメントをクリックして編集
   - ゴミ箱アイコンで削除

### gcloud CLIでデータを確認

```bash
# コレクション内のドキュメント一覧
gcloud firestore documents list \
  --collection-ids=data_records \
  --format="table(name)"

# 特定のドキュメントの内容を表示
gcloud firestore documents describe \
  projects/PROJECT_ID/databases/(default)/documents/data_records/test123456
```

## 🔒 セキュリティ設定

### 本番環境への移行

開発が完了したら、以下の設定を行ってください：

#### 1. 認証の有効化

Cloud Functionsの認証を有効にする:

```bash
# 既存の関数から認証なしアクセスを削除
gcloud functions remove-iam-policy-binding firebase-data-api \
  --region=asia-northeast1 \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --gen2

# 特定のサービスアカウントにのみアクセスを許可
gcloud functions add-iam-policy-binding firebase-data-api \
  --region=asia-northeast1 \
  --member="serviceAccount:YOUR-SERVICE-ACCOUNT@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudfunctions.invoker" \
  --gen2
```

#### 2. Firestoreセキュリティルールの強化

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /data_records/{recordId} {
      // 読み取り: 認証済みユーザー
      allow read: if request.auth != null;
      
      // 書き込み: 認証済みかつデータ検証
      allow write: if request.auth != null 
        && validateData(request.resource.data);
    }
  }
  
  function validateData(data) {
    return data.keys().hasAll(['id', 'value1', 'value2'])
      && data.id is string
      && data.id.size() == 10
      && data.value1 is string
      && data.value1.size() <= 100
      && data.value2 is string;
  }
}
```

#### 3. APIキーの追加（オプション）

main.pyに以下を追加:

```python
import os

API_KEY = os.environ.get('API_KEY', 'your-secret-key')

def check_api_key(request):
    api_key = request.headers.get('X-API-Key')
    if api_key != API_KEY:
        return False
    return True

# 各エンドポイントの先頭に追加
if not check_api_key(request):
    return (jsonify({'error': 'Invalid API key'}), 401, headers)
```

## 💰 料金の確認

### Firestore使用量の確認

1. **Firestore使用量ページ**
   - https://console.cloud.google.com/firestore/usage

2. **確認項目**
   - 読み取り回数
   - 書き込み回数
   - 削除回数
   - ストレージ使用量

### Cloud Functions使用量の確認

1. **Cloud Functionsダッシュボード**
   - https://console.cloud.google.com/functions/list

2. **関数を選択**
   - `firebase-data-api` をクリック

3. **メトリクスタブ**
   - 呼び出し回数
   - 実行時間
   - メモリ使用量

## 🐛 トラブルシューティング

### エラー: Permission denied

**症状**:
```
google.api_core.exceptions.PermissionDenied: 403
```

**解決方法**:
1. Firestore APIが有効化されているか確認
2. サービスアカウントに適切な権限があるか確認
3. Firestoreセキュリティルールを確認

### エラー: Database not found

**症状**:
```
Database not found
```

**解決方法**:
1. Firestoreデータベースが作成されているか確認
2. 正しいプロジェクトで作業しているか確認

```bash
gcloud config get-value project
gcloud firestore databases list
```

### データが保存されない

**症状**:
APIから200が返るが、Firestoreにデータが表示されない

**解決方法**:
1. Firestoreセキュリティルールを確認（テストモードに変更）
2. Cloud Functionsのログを確認

```bash
gcloud functions logs read firebase-data-api \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50
```

## 📚 参考リンク

- [Firebase Firestore ドキュメント](https://firebase.google.com/docs/firestore)
- [Cloud Functions ドキュメント](https://cloud.google.com/functions/docs)
- [Firestore セキュリティルール](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore 料金](https://firebase.google.com/pricing)

## ✅ チェックリスト

セットアップ完了の確認:
- [ ] Google Cloudプロジェクトが作成されている
- [ ] Firestoreデータベースが有効化されている
- [ ] 必要なAPIが有効化されている
- [ ] Cloud Functionsがデプロイされている
- [ ] テストでデータが正常に作成・取得できる
- [ ] Firestore Consoleでデータを確認できる
- [ ] セキュリティルールが設定されている（本番環境）

すべてチェックが入ったら、本番運用の準備完了です！
