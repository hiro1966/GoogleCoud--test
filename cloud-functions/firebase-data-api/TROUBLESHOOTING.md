# トラブルシューティングガイド

Firebase Data APIのデプロイや実行で問題が発生した場合の解決方法をまとめています。

## 🪟 Windows: deploy.bat が途中で止まる

### 症状
```
Firestoreデータベースを確認しています...
```
の後にコマンドプロンプトに戻ってしまう。

### 原因
1. `gcloud firestore databases list` コマンドがエラーを返している
2. Firestore APIが有効化されていない
3. Firestoreデータベースがまだ作成されていない
4. プロジェクトに適切な権限がない

### 解決方法

#### 方法1: Firestore APIを手動で有効化

1. **ブラウザでFirestore APIを有効化**
   ```
   https://console.cloud.google.com/apis/library/firestore.googleapis.com
   ```
   「有効にする」をクリック

2. **Firestoreデータベースを作成**
   ```
   https://console.cloud.google.com/firestore
   ```
   - 「データベースを作成」をクリック
   - モード: 本番モード（推奨）
   - ロケーション: asia-northeast1 (東京)
   - 「有効にする」をクリック

3. **deploy.batを再実行**

#### 方法2: gcloudコマンドで有効化

コマンドプロンプトで以下を実行:

```cmd
REM プロジェクトIDを設定
set PROJECT_ID=your-project-id

REM Firestore APIを有効化
gcloud services enable firestore.googleapis.com --project=%PROJECT_ID%

REM 有効化を確認
gcloud services list --enabled --project=%PROJECT_ID% | findstr firestore
```

#### 方法3: Firestoreチェックをスキップして続行

deploy.batを実行して、Firestoreの確認で警告が出たら「y」を入力して続行します。

### 修正版deploy.batの特徴

最新版のdeploy.batでは以下が改善されています：

1. **エラー処理の改善**
   - エラーコードを正しくキャプチャ
   - 詳細なエラーメッセージを表示

2. **ユーザー選択の追加**
   - Firestoreが見つからない場合でも続行可能
   - 詳細な対処方法を表示

3. **変数展開の修正**
   - `%VAR%` から `!VAR!` に変更（遅延展開）

---

## 🔐 権限エラー

### 症状
```
ERROR: (gcloud.functions.deploy) PERMISSION_DENIED
```

### 原因
- アカウントに適切な権限がない
- サービスアカウントに権限がない

### 解決方法

1. **現在のアカウントを確認**
   ```bash
   gcloud auth list
   ```

2. **プロジェクトのIAM権限を確認**
   - https://console.cloud.google.com/iam-admin/iam
   - 自分のアカウントに以下の権限があるか確認:
     - Cloud Functions Developer
     - Service Account User
     - Cloud Build Editor

3. **必要な権限を追加**
   ```bash
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="user:YOUR-EMAIL@gmail.com" \
     --role="roles/cloudfunctions.developer"
   ```

---

## 💳 課金エラー

### 症状
```
ERROR: Billing account is not enabled
```

### 原因
- プロジェクトに課金アカウントがリンクされていない

### 解決方法

1. **課金ページにアクセス**
   ```
   https://console.cloud.google.com/billing
   ```

2. **課金アカウントを作成**
   - 「課金アカウントを作成」をクリック
   - クレジットカード情報を入力
   - 初回は$300の無料クレジット付き

3. **プロジェクトにリンク**
   - 課金アカウント作成後、プロジェクトを選択
   - 「プロジェクトをリンク」をクリック

---

## 🔌 API有効化エラー

### 症状
```
ERROR: API [cloudfunctions.googleapis.com] not enabled
```

### 原因
- 必要なAPIが有効化されていない

### 解決方法

#### Web UI で有効化

以下のリンクをクリックして「有効にする」:

1. [Cloud Functions API](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com)
2. [Cloud Build API](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)
3. [Artifact Registry API](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com)
4. [Firestore API](https://console.cloud.google.com/apis/library/firestore.googleapis.com)

#### gcloud CLI で有効化

```bash
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable firestore.googleapis.com
```

---

## 🗄️ Firestoreデータベースが見つからない

### 症状
```
Database not found
```

### 原因
- Firestoreデータベースが作成されていない

### 解決方法

#### Web UI で作成（推奨）

1. **Firestoreコンソールにアクセス**
   ```
   https://console.cloud.google.com/firestore
   ```

2. **データベースを作成**
   - 「データベースを作成」をクリック
   - **モード**: 本番モード（推奨）
   - **ロケーション**: asia-northeast1 (東京)
   - 「有効にする」をクリック

3. **完了を待つ**
   - 数分でデータベースが作成されます

#### gcloud CLI で作成

```bash
# Firestore APIを有効化
gcloud services enable firestore.googleapis.com

# データベースを作成
gcloud firestore databases create --location=asia-northeast1
```

---

## 🔒 Firestoreセキュリティルールエラー

### 症状
```
PERMISSION_DENIED: Missing or insufficient permissions
```

APIからデータを書き込もうとしたときに403エラーが返る。

### 原因
- Firestoreのセキュリティルールが厳しすぎる

### 解決方法（開発環境）

1. **Firestoreコンソールにアクセス**
   ```
   https://console.cloud.google.com/firestore/rules
   ```

2. **ルールを以下に変更**
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

3. **「公開」をクリック**

**⚠️ 警告**: このルールは開発環境のみで使用してください！本番環境では使用しないでください。

### 解決方法（本番環境）

1. **適切なセキュリティルールを設定**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /data_records/{recordId} {
         // Cloud Functionsからのみアクセス許可
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

---

## 🌐 curlコマンドが見つからない (Windows)

### 症状
```
'curl' は、内部コマンドまたは外部コマンド、
操作可能なプログラムまたはバッチ ファイルとして認識されていません。
```

### 原因
- Windows 10バージョン1803より前ではcurlが標準搭載されていない

### 解決方法

#### 方法1: PowerShellを使用

```powershell
$body = @{
    id = "test123456"
    value1 = "テスト"
    value2 = "090-1234-5678"
} | ConvertTo-Json

Invoke-RestMethod -Uri "YOUR-FUNCTION-URL" -Method Post -Body $body -ContentType "application/json"
```

#### 方法2: curlをインストール

1. **Git for Windowsをインストール**
   - https://git-scm.com/download/win
   - Git Bashにcurlが含まれています

2. **Chocolateyでインストール**
   ```cmd
   choco install curl
   ```

#### 方法3: ブラウザでテスト

URLをブラウザで開く:
```
https://YOUR-FUNCTION-URL?id=test123456
```

---

## 🐛 デプロイは成功するがAPIが動かない

### 症状
- デプロイは成功
- しかしAPIにアクセスすると500エラー

### 診断方法

1. **ログを確認**
   ```bash
   gcloud functions logs read firebase-data-api \
     --region=asia-northeast1 \
     --gen2 \
     --limit=50
   ```

2. **詳細なエラーメッセージを確認**

### よくある原因と解決方法

#### 原因1: Firestoreクライアントの初期化失敗

**解決方法**: Firestore APIが有効化されているか確認

```bash
gcloud services enable firestore.googleapis.com
```

#### 原因2: Pythonパッケージの不足

**解決方法**: requirements.txtを確認

```txt
functions-framework==3.5.0
Flask==3.0.0
google-cloud-firestore==2.14.0
```

#### 原因3: エントリポイントの設定ミス

**解決方法**: デプロイコマンドで `--entry-point=firebase_data_api` を指定

---

## 📱 データが保存されない

### 症状
- APIから200 OKが返る
- しかしFirestore Consoleにデータが表示されない

### 診断方法

1. **Firestore Consoleを確認**
   ```
   https://console.cloud.google.com/firestore/data
   ```

2. **コレクション名を確認**
   - `data_records` コレクションが存在するか
   - ドキュメントが作成されているか

3. **ログを確認**
   ```bash
   gcloud functions logs read firebase-data-api --region=asia-northeast1 --gen2
   ```

### 解決方法

1. **セキュリティルールを確認**（上記参照）

2. **プロジェクトIDを確認**
   - 正しいプロジェクトにデプロイされているか
   - Firestoreが同じプロジェクトで有効になっているか

3. **テストデータで確認**
   ```bash
   curl -X POST YOUR-FUNCTION-URL \
     -H "Content-Type: application/json" \
     -d '{"id":"debug12345","value1":"debug","value2":"090-0000-0000"}'
   ```

---

## 💡 その他のヒント

### ログの確認方法

**リアルタイムログ**:
```bash
gcloud functions logs read firebase-data-api \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50 \
  --follow
```

**エラーのみ表示**:
```bash
gcloud functions logs read firebase-data-api \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50 | findstr ERROR
```

### デバッグモードでデプロイ

環境変数を追加してデバッグ情報を有効化:
```bash
gcloud functions deploy firebase-data-api \
  --gen2 \
  --runtime=python311 \
  --region=asia-northeast1 \
  --source=. \
  --entry-point=firebase_data_api \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars=DEBUG=true
```

### 完全にクリーンアップして再デプロイ

```bash
# 関数を削除
gcloud functions delete firebase-data-api --region=asia-northeast1 --gen2

# 再デプロイ
./deploy.sh  # または deploy.bat
```

---

## 📞 さらにサポートが必要な場合

1. **Google Cloud サポート**
   - https://cloud.google.com/support

2. **Stack Overflow**
   - タグ: `google-cloud-functions`, `google-cloud-firestore`

3. **GitHub Issues**
   - 具体的なエラーメッセージとログを添えて報告

---

## ✅ 健全性チェックリスト

問題が発生した場合、以下を順番に確認してください：

- [ ] Google Cloud SDKがインストールされている
- [ ] `gcloud auth login` で認証済み
- [ ] プロジェクトが選択されている (`gcloud config get-value project`)
- [ ] 課金アカウントがリンクされている
- [ ] Cloud Functions APIが有効
- [ ] Cloud Build APIが有効
- [ ] Firestore APIが有効
- [ ] Firestoreデータベースが作成されている
- [ ] 適切なIAM権限がある
- [ ] Firestoreセキュリティルールが設定されている

すべてチェックが入ったら、再度デプロイを試してください。
