# GetHello API - Google Cloud Functions

"Hello"を返すシンプルなAPIエンドポイント

## 概要

このCloud Functionは、HTTPリクエストを受け取り、JSON形式で`{"message": "Hello"}`を返します。

## ローカルでのテスト

```bash
# 依存関係をインストール
pip install -r requirements.txt

# ローカルサーバーを起動
functions-framework --target=get_hello --debug

# 別のターミナルでテスト
curl http://localhost:8080
```

## Google Cloudへのデプロイ

### 前提条件

- Google Cloud SDKがインストールされていること
- Google Cloudプロジェクトが作成されていること
- Cloud Functions APIが有効になっていること

### デプロイコマンド

```bash
# プロジェクトIDを設定
export PROJECT_ID="your-project-id"

# デプロイ
gcloud functions deploy get-hello \
  --runtime python311 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point get_hello \
  --region asia-northeast1 \
  --project $PROJECT_ID
```

### デプロイオプション

- `--runtime python311`: Python 3.11ランタイムを使用
- `--trigger-http`: HTTPトリガーを設定
- `--allow-unauthenticated`: 認証なしでアクセス可能に設定
- `--entry-point get_hello`: 実行する関数名
- `--region asia-northeast1`: 東京リージョンにデプロイ

## APIの使用方法

### リクエスト

```bash
# GET リクエスト
curl https://REGION-PROJECT_ID.cloudfunctions.net/get-hello

# POST リクエスト
curl -X POST https://REGION-PROJECT_ID.cloudfunctions.net/get-hello
```

### レスポンス

```json
{
  "message": "Hello"
}
```

### ステータスコード

- `200`: 成功
- `405`: サポートされていないHTTPメソッド

## CORS設定

このAPIは以下のCORSヘッダーを返します：

- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type`

フロントエンドアプリケーションから直接呼び出すことができます。

## 認証設定の変更

認証を有効にする場合は、デプロイコマンドから`--allow-unauthenticated`を削除してください：

```bash
gcloud functions deploy get-hello \
  --runtime python311 \
  --trigger-http \
  --entry-point get_hello \
  --region asia-northeast1 \
  --project $PROJECT_ID
```

## モニタリング

Google Cloud Consoleから以下を確認できます：

1. Cloud Functions > get-hello
2. ログ
3. メトリクス（リクエスト数、実行時間、エラー率など）

## トラブルシューティング

### ログの確認

```bash
gcloud functions logs read get-hello --region asia-northeast1
```

### 関数の削除

```bash
gcloud functions delete get-hello --region asia-northeast1
```
