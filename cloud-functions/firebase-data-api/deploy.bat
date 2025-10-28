@echo off
REM Firebase Data API デプロイスクリプト (Windows版)
REM Google Cloud FunctionsにFirestore連携APIをデプロイ

setlocal enabledelayedexpansion

echo ==========================================
echo   Firebase Data API デプロイスクリプト
echo ==========================================
echo.

REM gcloudがインストールされているか確認
where gcloud >nul 2>nul
if not %errorlevel%==0 (
    echo [エラー] gcloud コマンドが見つかりません
    echo Google Cloud SDK をインストールしてください:
    echo https://cloud.google.com/sdk/docs/install
    echo.
    pause
    exit /b 1
)

echo [OK] gcloud コマンドが見つかりました
echo.

REM 現在のプロジェクトIDを取得
for /f "tokens=*" %%i in ('gcloud config get-value project 2^>nul') do set CURRENT_PROJECT=%%i

if "!CURRENT_PROJECT!"=="" (
    echo プロジェクトが設定されていません
    set /p PROJECT_ID="プロジェクトIDを入力してください: "
    call gcloud config set project !PROJECT_ID!
) else (
    echo 現在のプロジェクト: !CURRENT_PROJECT!
    set /p CONFIRM="このプロジェクトでよろしいですか? (y/n): "
    if /i "!CONFIRM!"=="y" (
        set PROJECT_ID=!CURRENT_PROJECT!
    ) else (
        set /p PROJECT_ID="プロジェクトIDを入力してください: "
        call gcloud config set project !PROJECT_ID!
    )
)

echo.

REM Firestoreデータベースの確認
echo Firestoreデータベースを確認しています...
echo.
call gcloud firestore databases list --project=!PROJECT_ID! >nul 2>nul
set FIRESTORE_CHECK=!errorlevel!

if not !FIRESTORE_CHECK!==0 (
    echo [警告] Firestoreデータベースが見つからない、または確認できませんでした
    echo.
    echo これは以下の理由が考えられます:
    echo 1. Firestoreがまだ有効化されていない
    echo 2. Firestore APIが有効化されていない
    echo 3. 権限が不足している
    echo.
    echo 対処方法:
    echo 1. 以下のURLからWeb UIでFirestoreを有効化してください:
    echo    https://console.cloud.google.com/firestore?project=!PROJECT_ID!
    echo.
    echo 2. または、以下のコマンドでFirestore APIを有効化してください:
    echo    gcloud services enable firestore.googleapis.com --project=!PROJECT_ID!
    echo.
    set /p CONTINUE="Firestoreの設定が完了したら、続行しますか? (y/n): "
    if /i not "!CONTINUE!"=="y" (
        echo デプロイをキャンセルしました
        pause
        exit /b 0
    )
) else (
    echo [OK] Firestoreの確認が完了しました
)

echo.

REM リージョンの選択
echo デプロイするリージョンを選択してください:
echo 1) asia-northeast1 (東京) [推奨]
echo 2) asia-northeast2 (大阪)
echo 3) us-central1 (アイオワ)
echo 4) その他のリージョンを指定
set /p REGION_CHOICE="選択 (1-4): "

if "!REGION_CHOICE!"=="1" (
    set REGION=asia-northeast1
) else if "!REGION_CHOICE!"=="2" (
    set REGION=asia-northeast2
) else if "!REGION_CHOICE!"=="3" (
    set REGION=us-central1
) else if "!REGION_CHOICE!"=="4" (
    set /p REGION="リージョンを入力してください: "
) else (
    echo デフォルトで asia-northeast1 (東京) を使用します
    set REGION=asia-northeast1
)

echo.
echo ==========================================
echo デプロイ設定:
echo   プロジェクトID: !PROJECT_ID!
echo   リージョン: !REGION!
echo   関数名: firebase-data-api
echo   ランタイム: Python 3.11
echo   Firestore: 有効
echo ==========================================
echo.

set /p DEPLOY_CONFIRM="この設定でデプロイしますか? (y/n): "
if /i not "!DEPLOY_CONFIRM!"=="y" (
    echo デプロイをキャンセルしました
    pause
    exit /b 0
)

echo.
echo 必要なAPIを有効化しています...
echo.

REM 必要なAPIを有効化
echo - Cloud Functions API を有効化中...
call gcloud services enable cloudfunctions.googleapis.com --project=!PROJECT_ID! >nul 2>nul

echo - Cloud Build API を有効化中...
call gcloud services enable cloudbuild.googleapis.com --project=!PROJECT_ID! >nul 2>nul

echo - Artifact Registry API を有効化中...
call gcloud services enable artifactregistry.googleapis.com --project=!PROJECT_ID! >nul 2>nul

echo - Firestore API を有効化中...
call gcloud services enable firestore.googleapis.com --project=!PROJECT_ID! >nul 2>nul

echo.
echo [OK] APIの有効化が完了しました
echo.

REM デプロイ実行
echo デプロイを開始します...
echo (これには2〜5分かかる場合があります)
echo.

call gcloud functions deploy firebase-data-api ^
  --gen2 ^
  --runtime=python311 ^
  --region=!REGION! ^
  --source=. ^
  --entry-point=firebase_data_api ^
  --trigger-http ^
  --allow-unauthenticated ^
  --project=!PROJECT_ID!

set DEPLOY_STATUS=!errorlevel!

if not !DEPLOY_STATUS!==0 (
    echo.
    echo [エラー] デプロイに失敗しました (エラーコード: !DEPLOY_STATUS!)
    echo.
    echo よくある問題:
    echo 1. 課金が有効になっていない
    echo 2. 必要なAPIが有効化されていない
    echo 3. 権限が不足している
    echo.
    echo 詳細はログを確認してください。
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   デプロイが完了しました！
echo ==========================================
echo.

REM URLを取得して表示
for /f "tokens=*" %%i in ('call gcloud functions describe firebase-data-api --region=!REGION! --gen2 --format^="value(serviceConfig.uri)" --project=!PROJECT_ID! 2^>nul') do set FUNCTION_URL=%%i

if "!FUNCTION_URL!"=="" (
    echo [警告] 関数のURLを取得できませんでした
    echo 以下のコマンドで手動で確認してください:
    echo gcloud functions describe firebase-data-api --region=!REGION! --gen2 --project=!PROJECT_ID!
) else (
    echo APIのURL:
    echo !FUNCTION_URL!
    echo.
    
    REM テスト実行
    echo APIをテストしています...
    echo.
    
    REM curlがインストールされているか確認
    where curl >nul 2>nul
    if !errorlevel!==0 (
        set TEST_DATA={"id":"test123456","value1":"テストデータ","value2":"090-1234-5678"}
        echo テストデータ: !TEST_DATA!
        echo.
        
        curl -s -X POST "!FUNCTION_URL!" -H "Content-Type: application/json" -d "!TEST_DATA!"
        echo.
        echo.
    ) else (
        echo [注意] curlがインストールされていないため、テストをスキップします
        echo.
    )
)

echo [OK] デプロイが正常に完了しました！
echo.
echo 次のステップ:
echo 1. Firestore Consoleでデータを確認:
echo    https://console.cloud.google.com/firestore/data?project=!PROJECT_ID!
echo.
echo 2. APIを使用してみる:
if not "!FUNCTION_URL!"=="" (
    echo    curl "!FUNCTION_URL!?id=test123456"
) else (
    echo    (URLを上記のコマンドで取得してください)
)
echo.
echo 3. ログを確認:
echo    gcloud functions logs read firebase-data-api --region=!REGION! --gen2 --limit=50 --project=!PROJECT_ID!
echo.
echo 4. 関数を削除するには:
echo    gcloud functions delete firebase-data-api --region=!REGION! --gen2 --project=!PROJECT_ID!
echo.
echo 詳細は FIREBASE_SETUP.md を参照してください。
echo.
pause
