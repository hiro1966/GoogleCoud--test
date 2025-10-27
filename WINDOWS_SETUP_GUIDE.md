# 🪟 Windows向けデプロイガイド

WindowsでGetHello APIをGoogle Cloudにデプロイする方法を説明します。

## 🎯 推奨：Web UI を使う方法（最も簡単）

WindowsでもMacでも同じように使えます！プログラミング不要です。

### ステップ1: Google Cloud Consoleにアクセス

1. ブラウザで https://console.cloud.google.com/ を開く
2. Googleアカウントでログイン

### ステップ2: プロジェクトを作成（初回のみ）

1. 画面上部の「プロジェクトを選択」をクリック
2. 「新しいプロジェクト」をクリック
3. プロジェクト名を入力（例: `my-api-project`）
4. 「作成」をクリック

### ステップ3: 課金を有効化（初回のみ）

1. 左メニュー「お支払い」を選択
2. 課金アカウントを作成
3. クレジットカード情報を入力
   - **初回は $300 の無料クレジット付き**
   - この簡単なAPIなら無料枠で十分です

### ステップ4: Cloud Functions APIを有効化

以下のリンクをクリックして「有効にする」を押すだけ：

1. [Cloud Functions API を有効化](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com) ← クリック
2. [Cloud Build API を有効化](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com) ← クリック

### ステップ5: 関数を作成してデプロイ

1. **Cloud Functionsページを開く**
   - https://console.cloud.google.com/functions
   - 「関数を作成」をクリック

2. **環境と関数名**
   ```
   環境: 第2世代
   関数名: get-hello
   リージョン: asia-northeast1 (東京)
   ```

3. **トリガー設定**
   ```
   トリガータイプ: HTTPS
   認証: 未認証の呼び出しを許可 ✓ チェック
   ```
   「保存」→「次へ」をクリック

4. **ランタイムとエントリポイント**
   ```
   ランタイム: Python 3.11
   エントリポイント: get_hello
   ソースコード: インラインエディタ
   ```

5. **main.py の内容を貼り付け**
   
   画面左側の `main.py` タブを選択して、以下をコピー＆ペースト：

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

6. **requirements.txt の内容を貼り付け**
   
   画面左側の `requirements.txt` タブを選択して、以下をコピー＆ペースト：

   ```
   functions-framework==3.5.0
   Flask==3.0.0
   ```

7. **デプロイボタンをクリック**
   - 画面下部の青い「デプロイ」ボタンをクリック
   - 2〜5分待つ（コーヒー☕を飲んでリラックス）
   - 緑のチェックマーク ✓ が表示されたら完了！

### ステップ6: URLを取得してテスト

1. **URLを取得**
   - 関数名 `get-hello` をクリック
   - 「トリガー」タブを選択
   - URLをコピー（例: `https://asia-northeast1-xxxxx.cloudfunctions.net/get-hello`）

2. **ブラウザでテスト**
   - コピーしたURLをブラウザのアドレスバーに貼り付けてEnter
   - 以下が表示されればOK！
   ```json
   {
     "message": "Hello"
   }
   ```

🎉 **完了です！** これであなたのAPIがインターネット上で動いています！

---

## 💻 コマンドラインを使う方法（オプション）

### Google Cloud SDK のインストール

1. **インストーラーをダウンロード**
   - https://cloud.google.com/sdk/docs/install
   - 「Windows用のインストーラー」をダウンロード

2. **インストーラーを実行**
   - ダウンロードした `GoogleCloudSDKInstaller.exe` をダブルクリック
   - 指示に従ってインストール
   - 最後に「Google Cloud SDKシェルを起動」にチェックを入れる

3. **初期設定**
   - Google Cloud SDK シェルが開いたら：
   ```cmd
   gcloud init
   ```
   - ブラウザが開くのでGoogleアカウントでログイン
   - プロジェクトを選択

### バッチファイルでデプロイ

1. **コマンドプロンプトまたはPowerShellを開く**

2. **プロジェクトフォルダに移動**
   ```cmd
   cd C:\path\to\webapp\cloud-functions\get-hello
   ```
   ※パスは実際のフォルダの場所に置き換えてください

3. **デプロイスクリプトを実行**
   ```cmd
   deploy.bat
   ```

4. **プロンプトに従う**
   - プロジェクトID確認
   - リージョン選択（東京を推奨）
   - デプロイ確認
   - 自動的にデプロイされます！

### 手動でgcloudコマンドを実行

```cmd
cd C:\path\to\webapp\cloud-functions\get-hello

gcloud functions deploy get-hello ^
  --gen2 ^
  --runtime=python311 ^
  --region=asia-northeast1 ^
  --source=. ^
  --entry-point=get_hello ^
  --trigger-http ^
  --allow-unauthenticated
```

---

## 🔍 デプロイ後の確認

### ブラウザでログを確認

1. https://console.cloud.google.com/functions
2. `get-hello` をクリック
3. 「ログ」タブを選択
4. 各リクエストの詳細が表示されます

### コマンドラインでログを確認（Cloud SDK使用時）

```cmd
gcloud functions logs read get-hello --region=asia-northeast1 --gen2 --limit=50
```

---

## 🧪 APIのテスト方法

### 方法1: ブラウザでテスト
- URLをブラウザで開くだけ

### 方法2: PowerShellでテスト
```powershell
Invoke-RestMethod -Uri "https://asia-northeast1-xxxxx.cloudfunctions.net/get-hello"
```

### 方法3: curlでテスト（Git Bash または WSL）
```bash
curl https://asia-northeast1-xxxxx.cloudfunctions.net/get-hello
```

### 方法4: Postman でテスト
1. Postmanをダウンロード（https://www.postman.com/downloads/）
2. 新しいリクエストを作成
3. メソッド: GET
4. URL: あなたの関数のURL
5. 「Send」をクリック

---

## ❓ よくある質問（FAQ）

### Q: お金はかかりますか？

A: 無料枠が非常に大きいです：
- 月200万回の呼び出しまで無料
- このシンプルなAPIなら、ほぼ確実に無料枠内です
- 初回登録で $300 の無料クレジットも付きます

### Q: Cloud SDKをインストールしなくてもいいですか？

A: **はい！** Web UI（ブラウザ）だけで完結できます。
Cloud SDKは上級者向けのオプションです。

### Q: デプロイに失敗しました

A: よくある原因と解決方法：

1. **「APIが有効になっていません」エラー**
   - Cloud Functions API を有効化してください
   - https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com

2. **「課金が有効になっていません」エラー**
   - 課金アカウントを設定してください
   - クレジットカード情報が必要ですが、無料枠内なら課金されません

3. **「権限がありません」エラー**
   - プロジェクトのオーナーまたは編集者権限が必要です

### Q: URLを変更できますか？

A: Cloud Functionsが自動生成するURLは変更できません。
カスタムドメインを使いたい場合は、以下が必要です：
- Cloud Load Balancer
- カスタムドメイン設定

---

## 🗑️ クリーンアップ（削除方法）

### Web UIから削除

1. https://console.cloud.google.com/functions
2. `get-hello` の横のチェックボックスをオン
3. 画面上部の「削除」ボタンをクリック
4. 確認して「削除」

### コマンドラインから削除

```cmd
gcloud functions delete get-hello --region=asia-northeast1 --gen2
```

---

## 📚 次のステップ

デプロイが成功したら：

1. **URLを保存**
   - メモ帳やドキュメントにURLを保存
   - アプリケーションから呼び出せるようになります

2. **カスタマイズ**
   - `main.py` を編集してメッセージを変更
   - パラメータを受け取る機能を追加
   - データベースと連携

3. **セキュリティ強化**
   - API キーを追加
   - 認証を有効化
   - レート制限を設定

---

## 🎓 参考資料

- [Google Cloud公式ドキュメント（日本語）](https://cloud.google.com/functions/docs?hl=ja)
- [Cloud Functions Python クイックスタート](https://cloud.google.com/functions/docs/quickstart-python?hl=ja)
- [料金計算ツール](https://cloud.google.com/products/calculator?hl=ja)

---

## ✅ チェックリスト

デプロイ前:
- [ ] Googleアカウントを持っている
- [ ] Google Cloud Consoleにアクセスできる
- [ ] プロジェクトを作成した
- [ ] 課金を有効化した（無料クレジット付き）
- [ ] Cloud Functions API を有効化した

デプロイ後:
- [ ] URLをブラウザで開いて動作確認した
- [ ] `{"message": "Hello"}` が表示された
- [ ] URLをメモした
- [ ] ログを確認できた

---

困ったときは、このガイドを最初から読み直してみてください。
それでも解決しない場合は、エラーメッセージをコピーして質問してください！

**頑張ってください！ 🚀**
