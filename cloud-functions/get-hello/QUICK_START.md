# 🚀 クイックスタートガイド

最も簡単な方法でGetHello APIをGoogle Cloudにデプロイする手順です。

## 方法1: Web UI で3ステップデプロイ（最も簡単）

### ステップ1: Google Cloudの準備（初回のみ）

1. **Google Cloud Consoleにアクセス**
   - https://console.cloud.google.com/ を開く
   - Googleアカウントでログイン

2. **新しいプロジェクトを作成**
   - 画面上部の「プロジェクトを選択」→「新しいプロジェクト」
   - プロジェクト名を入力（例: `my-first-api`）
   - 「作成」をクリック

3. **課金を有効化**
   - 左メニュー「お支払い」→「課金アカウントをリンク」
   - クレジットカード情報を入力（初回は$300の無料クレジット付き）

### ステップ2: APIを有効化（初回のみ）

以下のリンクをクリックして「有効にする」を押すだけ：

1. [Cloud Functions API を有効化](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com)
2. [Cloud Build API を有効化](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)

### ステップ3: 関数をデプロイ

1. **Cloud Functions ページを開く**
   - https://console.cloud.google.com/functions
   - 「関数を作成」をクリック

2. **基本設定**
   ```
   環境: 第2世代
   関数名: get-hello
   リージョン: asia-northeast1 (東京)
   ```

3. **トリガー設定**
   ```
   トリガータイプ: HTTPS
   認証: 未認証の呼び出しを許可 ✓
   ```
   「保存」→「次へ」

4. **コード設定**
   ```
   ランタイム: Python 3.11
   エントリポイント: get_hello
   ソースコード: インラインエディタ
   ```

5. **main.pyの内容をコピペ**
   
   `main.py` タブに以下をコピペ：
   ```python
   import functions_framework
   from flask import jsonify

   @functions_framework.http
   def get_hello(request):
       headers = {
           'Access-Control-Allow-Origin': '*',
           'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
           'Access-Control-Allow-Headers': 'Content-Type',
       }
       
       if request.method == 'OPTIONS':
           return ('', 204, headers)
       
       if request.method in ['GET', 'POST']:
           response_data = {'message': 'Hello'}
           return (jsonify(response_data), 200, headers)
       
       return (jsonify({'error': 'Method not allowed'}), 405, headers)
   ```

6. **requirements.txtの内容をコピペ**
   
   `requirements.txt` タブに以下をコピペ：
   ```
   functions-framework==3.5.0
   Flask==3.0.0
   ```

7. **デプロイ実行**
   - 「デプロイ」ボタンをクリック
   - 2〜5分待つ（緑のチェックマークが表示されたら完了）

### ステップ4: テスト

1. **URLを取得**
   - 関数名 `get-hello` をクリック
   - 「トリガー」タブを選択
   - URLをコピー（例: `https://asia-northeast1-xxxxx.cloudfunctions.net/get-hello`）

2. **ブラウザでテスト**
   - コピーしたURLをブラウザのアドレスバーに貼り付け
   - 以下のような結果が表示されればOK：
   ```json
   {
     "message": "Hello"
   }
   ```

3. **curlでテスト**
   ```bash
   curl https://asia-northeast1-xxxxx.cloudfunctions.net/get-hello
   ```

---

## 方法2: コマンドラインでデプロイ（上級者向け）

### 前提条件

Google Cloud SDK がインストールされていること。

**インストール方法:**
- macOS: `brew install --cask google-cloud-sdk`
- Linux: `sudo snap install google-cloud-cli --classic`
- Windows: [公式インストーラー](https://cloud.google.com/sdk/docs/install)をダウンロード

### デプロイ手順

1. **初期設定（初回のみ）**
   ```bash
   # Google Cloud SDK を初期化
   gcloud init
   
   # プロンプトに従ってログインとプロジェクト選択
   ```

2. **自動デプロイスクリプトを使用**
   ```bash
   cd /home/user/webapp/cloud-functions/get-hello
   ./deploy.sh
   ```
   
   スクリプトが以下を自動で実行します：
   - プロジェクト確認
   - リージョン選択
   - 必要なAPI有効化
   - デプロイ実行
   - URLの表示とテスト

3. **手動でデプロイ**
   ```bash
   cd /home/user/webapp/cloud-functions/get-hello
   
   gcloud functions deploy get-hello \
     --gen2 \
     --runtime=python311 \
     --region=asia-northeast1 \
     --source=. \
     --entry-point=get_hello \
     --trigger-http \
     --allow-unauthenticated
   ```

---

## 📊 デプロイ後の確認

### ログの確認

**Web UI:**
1. Cloud Console → Cloud Functions
2. `get-hello` をクリック
3. 「ログ」タブを選択

**コマンドライン:**
```bash
gcloud functions logs read get-hello \
  --region=asia-northeast1 \
  --gen2 \
  --limit=50
```

### メトリクスの確認

Cloud Console → Cloud Functions → `get-hello` → 「指標」タブ

以下を確認できます：
- 呼び出し回数
- 実行時間
- エラー率
- メモリ使用量

---

## 🔧 よくある問題と解決方法

### 「課金が有効になっていません」エラー

**解決方法:**
1. Cloud Console → お支払い
2. 課金アカウントを作成
3. プロジェクトにリンク

### 「API が有効になっていません」エラー

**解決方法:**
```bash
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

または、Web UIで有効化リンクをクリック。

### 403 エラー（認証エラー）

**解決方法:**
```bash
gcloud functions add-iam-policy-binding get-hello \
  --region=asia-northeast1 \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --gen2
```

---

## 🗑️ 削除方法

### Web UI
1. Cloud Functions ページ
2. `get-hello` の横のチェックボックスをオン
3. 「削除」ボタンをクリック

### コマンドライン
```bash
gcloud functions delete get-hello \
  --region=asia-northeast1 \
  --gen2
```

---

## 💰 料金について

**無料枠:**
- 月200万回の呼び出し
- 月40万GB秒のコンピューティング時間
- 月5GBのネットワーク

**このAPIの場合:**
- ほぼすべてのケースで無料枠内に収まります
- 1回あたり数ミリ秒の実行時間
- レスポンスサイズも非常に小さい

---

## 📚 次のステップ

1. **カスタマイズ**
   - レスポンスメッセージを変更
   - パラメータを受け取る機能を追加
   - データベースと連携

2. **セキュリティ強化**
   - 認証を追加
   - APIキーを要求
   - レート制限を設定

3. **モニタリング**
   - Cloud Monitoring でアラート設定
   - ログベースのメトリクス作成

詳細は `DEPLOYMENT_GUIDE.md` を参照してください。

---

## ✅ チェックリスト

デプロイ前:
- [ ] Google Cloudアカウントを作成
- [ ] プロジェクトを作成
- [ ] 課金を有効化
- [ ] 必要なAPIを有効化

デプロイ後:
- [ ] URLにアクセスして動作確認
- [ ] ログを確認
- [ ] メトリクスを確認
- [ ] URLをアプリケーションに組み込み

---

困ったときは `DEPLOYMENT_GUIDE.md` の詳細ガイドを参照してください！
