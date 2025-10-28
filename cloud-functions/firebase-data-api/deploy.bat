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
if %errorlevel% neq 0 (
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

if "%CURRENT_PROJECT%"=="" (
    echo プロジェクトが設定されていません
    set /p PROJECT_ID="プロジェクトIDを入力してください: "
    gcloud config set project !PROJECT_ID!
) else (
    echo 現在のプロジェクト: %CURRENT_PROJECT%
    set /p CONFIRM="このプロジェクトでよろしいですか? (y/n): "
    if /i "!CONFIRM!"=="y" (
        set PROJECT_ID=%CURRENT_PROJECT%
    ) else (
        set /p PROJECT_ID="プロジェクトIDを入力してください: "
        gcloud config set project !PROJECT_ID!
    )
)

echo.

REM Firestoreデータベースの確認
echo Firestoreデータベースを確認しています...
gcloud firestore databases list >nul 2>nul
if %errorlevel% neq 0 (
    echo [警告] Firestoreデータベースが見つからない可能性があります
    echo 以下のURLから手動で作成してください:
    echo https://console.cloud.google.com/firestore
    echo.
    pause
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

if "%REGION_CHOICE%"=="1" (
    set REGION=asia-northeast1
) else if "%REGION_CHOICE%"=="2" (
    set REGION=asia-northeast2
) else if "%REGION_CHOICE%"=="3" (
    set REGION=us-central1
) else if "%REGION_CHOICE%"=="4" (
    set /p REGION="リージョンを入力してください: "
) else (
    echo デフォルトで asia-northeast1 (東京) を使用します
    set REGION=asia-northeast1
)

echo.
echo ==========================================
echo デプロイ設定:
echo   プロジェクトID: %PROJECT_ID%
echo   リージョン: %REGION%
echo   関数名: firebase-data-api
echo   ランタイム: Python 3.11
echo   Firestore: 有効
echo ==========================================
echo.

set /p DEPLOY_CONFIRM="この設定でデプロイしますか? (y/n): "
if /i not "%DEPLOY_CONFIRM%"=="y" (
    echo デプロイをキャンセルしました
    pause
    exit /b 0
)

echo.
echo 必要なAPIを有効化しています...

REM 必要なAPIを有効化
call gcloud services enable cloudfunctions.googleapis.com --project=%PROJECT_ID%
call gcloud services enable cloudbuild.googleapis.com --project=%PROJECT_ID%
call gcloud services enable artifactregistry.googleapis.com --project=%PROJECT_ID%
call gcloud services enable firestore.googleapis.com --project=%PROJECT_ID%

echo [OK] APIの有効化が完了しました
echo.

REM デプロイ実行
echo デプロイを開始します...
echo (これには2〜5分かかる場合があります)
echo.

call gcloud functions deploy firebase-data-api ^
  --gen2 ^
  --runtime=python311 ^
  --region=%REGION% ^
  --source=. ^
  --entry-point=firebase_data_api ^
  --trigger-http ^
  --allow-unauthenticated ^
  --project=%PROJECT_ID%

if %errorlevel% neq 0 (
    echo.
    echo [エラー] デプロイに失敗しました
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   デプロイが完了しました！
echo ==========================================
echo.

REM URLを取得して表示
for /f "tokens=*" %%i in ('gcloud functions describe firebase-data-api --region=%REGION% --gen2 --format="value(serviceConfig.uri)" --project=%PROJECT_ID% 2^>nul') do set FUNCTION_URL=%%i

echo APIのURL:
echo %FUNCTION_URL%
echo.

REM テスト実行
echo APIをテストしています...
echo.
set TEST_DATA={"id":"test123456","value1":"テストデータ","value2":"090-1234-5678"}
echo テストデータ: %TEST_DATA%
echo.

curl -s -X POST "%FUNCTION_URL%" -H "Content-Type: application/json" -d "%TEST_DATA%"
echo.
echo.

echo [OK] デプロイとテストが正常に完了しました！
echo.
echo 次のステップ:
echo 1. Firestore Consoleでデータを確認:
echo    https://console.cloud.google.com/firestore/data
echo.
echo 2. APIを使用してみる:
echo    curl %FUNCTION_URL%?id=test123456
echo.
echo 3. ログを確認:
echo    gcloud functions logs read firebase-data-api --region=%REGION% --gen2 --limit=50
echo.
echo 4. 関数を削除するには:
echo    gcloud functions delete firebase-data-api --region=%REGION% --gen2
echo.
echo 詳細は FIREBASE_SETUP.md を参照してください。
echo.
pause
