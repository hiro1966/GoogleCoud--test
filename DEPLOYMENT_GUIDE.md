# Google Cloud Functions デプロイガイド

このガイドでは、GetHello APIをGoogle Cloud Functionsにデプロイする手順を詳しく説明します。

## 📋 事前準備

### 1. Googleアカウントの準備
- Googleアカウントを持っていることを確認
- [Google Cloud Console](https://console.cloud.google.com/) にアクセス可能であること

### 2. Google Cloudプロジェクトの作成

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 画面上部の「プロジェクトを選択」をクリック
3. 「新しいプロジェクト」をクリック
4. プロジェクト名を入力（例: `my-api-project`）
5. 「作成」をクリック
6. **プロジェクトID**をメモしておく（例: `my-api-project-123456`）

### 3. 課金の有効化

1. Google Cloud Consoleで「お支払い」セクションに移動
2. 課金アカウントを作成（初回は無料クレジット $300 が付与されます）
3. プロジェクトに課金アカウントをリンク

### 4. 必要なAPIの有効化

以下のAPIを有効にする必要があります：

1. [Cloud Functions API](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com)
2. [Cloud Build API](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)
3. [Artifact Registry API](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com)

各リンクをクリックして「有効にする」ボタンを押してください。

---

## 🚀 デプロイ方法

### 方法1: Google Cloud Console（Web UI）を使用【推奨】

#### ステップ1: Cloud Functionsページに移動

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 左側のメニューから「Cloud Functions」を選択
3. 「関数を作成」をクリック

#### ステップ2: 基本設定

- **関数名**: `get-hello`
- **リージョン**: `asia-northeast1` (東京) を選択
- **トリガータイプ**: 「HTTP」を選択
- **認証**: 「未認証の呼び出しを許可」にチェック
- 「保存」→「次へ」をクリック

#### ステップ3: コードのデプロイ

1. **ランタイム**: `Python 3.11` を選択
2. **エントリポイント**: `get_hello` と入力
3. **ソースコード**: 「インラインエディタ」を選択

4. **main.py** の内容を以下に置き換え:

```python
"""
Google Cloud Functions: GetHello API
"Hello"を返すシンプルなAPIエンドポイント
"""
import functions_framework
from flask import jsonify


@functions_framework.http
def get_hello(request):
    """
    GetHello APIエンドポイント
    
    Returns:
        JSON: {"message": "Hello"}のレスポンスを返す
    """
    # CORSヘッダーを設定（必要に応じて）
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    }
    
    # OPTIONSリクエスト（CORS preflight）への対応
    if request.method == 'OPTIONS':
        return ('', 204, headers)
    
    # GETまたはPOSTリクエストへの対応
    if request.method in ['GET', 'POST']:
        response_data = {
            'message': 'Hello'
        }
        return (jsonify(response_data), 200, headers)
    
    # その他のメソッドはサポートしない
    return (jsonify({'error': 'Method not allowed'}), 405, headers)
```

5. **requirements.txt** の内容を以下に置き換え:

```
functions-framework==3.5.0
Flask==3.0.0
```

6. 「デプロイ」ボタンをクリック

#### ステップ4: デプロイの完了を待つ

- デプロイには2〜5分かかります
- 緑色のチェックマークが表示されたら完了です

#### ステップ5: URLの取得とテスト

1. デプロイされた関数名（`get-hello`）をクリック
2. 「トリガー」タブを選択
3. **トリガーURL**をコピー（例: `https://asia-northeast1-PROJECT_ID.cloudfunctions.net/get-hello`）

4. ブラウザまたはcurlでテスト:
```bash
curl https://asia-northeast1-PROJECT_ID.cloudfunctions.net/get-hello
```

期待される結果:
```json
{"message": "Hello"}
```

---

### 方法2: gcloud CLIを使用（上級者向け）

#### ステップ1: Google Cloud SDK のインストール

**macOS**:
```bash
# Homebrewを使用
brew install --cask google-cloud-sdk

# または公式インストーラー
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

**Linux**:
```bash
# Snapを使用
sudo snap install google-cloud-cli --classic

# または公式スクリプト
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

**Windows**:
- [Google Cloud SDK インストーラー](https://cloud.google.com/sdk/docs/install)をダウンロード
- インストーラーを実行

#### ステップ2: gcloud の初期化

```bash
# Google Cloud SDKを初期化
gcloud init

# プロンプトに従って:
# 1. Googleアカウントでログイン
# 2. プロジェクトを選択
# 3. デフォルトのリージョンを設定
```

#### ステップ3: 認証

```bash
# Googleアカウントで認証
gcloud auth login

# アプリケーションのデフォルト認証情報を設定
gcloud auth application-default login

# プロジェクトIDを設定
gcloud config set project YOUR_PROJECT_ID
```

#### ステップ4: デプロイコマンドの実行

```bash
# cloud-functions/get-hello ディレクトリに移動
cd /home/user/webapp/cloud-functions/get-hello

# デプロイ実行
gcloud functions deploy get-hello \
  --gen2 \
  --runtime=python311 \
  --region=asia-northeast1 \
  --source=. \
  --entry-point=get_hello \
  --trigger-http \
  --allow-unauthenticated
```

**パラメータ説明**:
- `--gen2`: Cloud Functions 第2世代を使用（推奨）
- `--runtime=python311`: Python 3.11 を使用
- `--region=asia-northeast1`: 東京リージョンにデプロイ
- `--source=.`: 現在のディレクトリのコードを使用
- `--entry-point=get_hello`: 実行する関数名
- `--trigger-http`: HTTPトリガーを設定
- `--allow-unauthenticated`: 認証なしでアクセス可能

#### ステップ5: デプロイ状況の確認

```bash
# デプロイされた関数の一覧を表示
gcloud functions list --region=asia-northeast1

# 関数の詳細を表示
gcloud functions describe get-hello --region=asia-northeast1 --gen2
```

#### ステップ6: URLの取得

```bash
# 関数のURLを取得
gcloud functions describe get-hello \
  --region=asia-northeast1 \
  --gen2 \
  --format='value(serviceConfig.uri)'
```

---

## 🧪 デプロイ後のテスト

### curlでテスト

```bash
# GET リクエスト
curl https://REGION-PROJECT_ID.cloudfunctions.net/get-hello

# POST リクエスト
curl -X POST https://REGION-PROJECT_ID.cloudfunctions.net/get-hello

# ヘッダーを含めて表示
curl -i https://REGION-PROJECT_ID.cloudfunctions.net/get-hello
```

### ブラウザでテスト

URLをブラウザのアドレスバーに貼り付けてアクセスすると、以下のJSONが表示されます：

```json
{
  "message": "Hello"
}
```

### Postmanでテスト

1. Postmanを開く
2. 新しいリクエストを作成
3. メソッド: GET
4. URL: `https://REGION-PROJECT_ID.cloudfunctions.net/get-hello`
5. 「Send」をクリック

---

## 📊 モニタリングとログ

### Google Cloud Consoleでログを確認

1. Cloud Console → Cloud Functions
2. `get-hello` 関数をクリック
3. 「ログ」タブを選択
4. リクエストごとのログが表示されます

### gcloud CLIでログを確認

```bash
# 最新のログを表示
gcloud functions logs read get-hello \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50

# リアルタイムでログを監視
gcloud functions logs read get-hello \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50 \
  --follow
```

---

## 🔧 トラブルシューティング

### デプロイが失敗する場合

1. **APIが有効になっているか確認**
   ```bash
   gcloud services list --enabled
   ```

2. **必要なAPIを有効化**
   ```bash
   gcloud services enable cloudfunctions.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   ```

3. **IAM権限を確認**
   - Cloud Console → IAM と管理 → IAM
   - 自分のアカウントに「Cloud Functions 開発者」ロールがあるか確認

### 403エラーが出る場合

関数が認証を要求している可能性があります。以下のコマンドで修正：

```bash
gcloud functions add-iam-policy-binding get-hello \
  --region=asia-northeast1 \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --gen2
```

### 502/504エラーが出る場合

関数がタイムアウトしている可能性があります。タイムアウト時間を延長：

```bash
gcloud functions deploy get-hello \
  --gen2 \
  --timeout=60s \
  --region=asia-northeast1
```

---

## 🗑️ 関数の削除

### Cloud Consoleから削除

1. Cloud Functions ページに移動
2. `get-hello` の横のチェックボックスをオン
3. 「削除」ボタンをクリック

### gcloud CLIから削除

```bash
gcloud functions delete get-hello \
  --region=asia-northeast1 \
  --gen2
```

---

## 💰 料金について

Cloud Functionsの料金は以下の要素で決まります：

- **呼び出し回数**: 月200万回まで無料
- **コンピューティング時間**: 月40万GB秒まで無料
- **ネットワーク**: 月5GBまで無料

**この簡単なAPIの場合、無料枠内で十分に運用できます！**

詳細: [Cloud Functions 料金](https://cloud.google.com/functions/pricing)

---

## 📚 参考リンク

- [Cloud Functions ドキュメント](https://cloud.google.com/functions/docs)
- [Python クイックスタート](https://cloud.google.com/functions/docs/quickstart-python)
- [gcloud functions コマンドリファレンス](https://cloud.google.com/sdk/gcloud/reference/functions)
- [Cloud Functions サンプル集](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/functions)

---

## ✅ まとめ

1. **初心者の方**: 方法1（Google Cloud Console）を推奨
2. **上級者/自動化したい方**: 方法2（gcloud CLI）を推奨
3. **テスト**: デプロイ後は必ずURLにアクセスしてテスト
4. **料金**: 無料枠が大きいので安心して使えます

何か問題があれば、エラーメッセージを確認してトラブルシューティングセクションを参照してください！
