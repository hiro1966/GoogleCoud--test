#!/bin/bash

# Firebase Data API デプロイスクリプト
# Google Cloud FunctionsにFirestore連携APIをデプロイ

set -e

echo "=========================================="
echo "  Firebase Data API デプロイスクリプト"
echo "=========================================="
echo ""

# カラー設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# gcloudがインストールされているか確認
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}エラー: gcloud コマンドが見つかりません${NC}"
    echo "Google Cloud SDK をインストールしてください:"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo -e "${GREEN}✓ gcloud コマンドが見つかりました${NC}"
echo ""

# 現在のプロジェクトIDを取得
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [ -z "$CURRENT_PROJECT" ]; then
    echo -e "${YELLOW}プロジェクトが設定されていません${NC}"
    read -p "プロジェクトIDを入力してください: " PROJECT_ID
    gcloud config set project "$PROJECT_ID"
else
    echo -e "${GREEN}現在のプロジェクト: ${CURRENT_PROJECT}${NC}"
    read -p "このプロジェクトでよろしいですか? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        read -p "プロジェクトIDを入力してください: " PROJECT_ID
        gcloud config set project "$PROJECT_ID"
    else
        PROJECT_ID=$CURRENT_PROJECT
    fi
fi

echo ""

# Firestoreデータベースの存在確認
echo -e "${YELLOW}Firestoreデータベースを確認しています...${NC}"
FIRESTORE_EXISTS=$(gcloud firestore databases list --format="value(name)" 2>/dev/null | wc -l)

if [ "$FIRESTORE_EXISTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Firestoreデータベースが見つかりません${NC}"
    echo ""
    echo "Firestoreデータベースを作成する必要があります。"
    echo "以下のURLから手動で作成してください:"
    echo "https://console.cloud.google.com/firestore"
    echo ""
    read -p "Firestoreの作成が完了したら Enter を押してください..."
else
    echo -e "${GREEN}✓ Firestoreデータベースが見つかりました${NC}"
fi

echo ""

# リージョンの選択
echo "デプロイするリージョンを選択してください:"
echo "1) asia-northeast1 (東京) [推奨]"
echo "2) asia-northeast2 (大阪)"
echo "3) us-central1 (アイオワ)"
echo "4) その他のリージョンを指定"
read -p "選択 (1-4): " REGION_CHOICE

case $REGION_CHOICE in
    1)
        REGION="asia-northeast1"
        ;;
    2)
        REGION="asia-northeast2"
        ;;
    3)
        REGION="us-central1"
        ;;
    4)
        read -p "リージョンを入力してください: " REGION
        ;;
    *)
        echo -e "${YELLOW}デフォルトで asia-northeast1 (東京) を使用します${NC}"
        REGION="asia-northeast1"
        ;;
esac

echo ""
echo "=========================================="
echo "デプロイ設定:"
echo "  プロジェクトID: $PROJECT_ID"
echo "  リージョン: $REGION"
echo "  関数名: firebase-data-api"
echo "  ランタイム: Python 3.11"
echo "  Firestore: 有効"
echo "=========================================="
echo ""

read -p "この設定でデプロイしますか? (y/n): " DEPLOY_CONFIRM
if [ "$DEPLOY_CONFIRM" != "y" ]; then
    echo "デプロイをキャンセルしました"
    exit 0
fi

echo ""
echo -e "${YELLOW}必要なAPIを有効化しています...${NC}"

# 必要なAPIを有効化
gcloud services enable cloudfunctions.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable artifactregistry.googleapis.com --project=$PROJECT_ID
gcloud services enable firestore.googleapis.com --project=$PROJECT_ID

echo -e "${GREEN}✓ APIの有効化が完了しました${NC}"
echo ""

# デプロイ実行
echo -e "${YELLOW}デプロイを開始します...${NC}"
echo "（これには2〜5分かかる場合があります）"
echo ""

gcloud functions deploy firebase-data-api \
  --gen2 \
  --runtime=python311 \
  --region=$REGION \
  --source=. \
  --entry-point=firebase_data_api \
  --trigger-http \
  --allow-unauthenticated \
  --project=$PROJECT_ID

echo ""
echo -e "${GREEN}=========================================="
echo -e "  デプロイが完了しました！"
echo -e "==========================================${NC}"
echo ""

# URLを取得して表示
FUNCTION_URL=$(gcloud functions describe firebase-data-api \
  --region=$REGION \
  --gen2 \
  --format='value(serviceConfig.uri)' \
  --project=$PROJECT_ID)

echo -e "${GREEN}APIのURL:${NC}"
echo -e "${YELLOW}$FUNCTION_URL${NC}"
echo ""

# テスト実行
echo -e "APIをテストしています..."
echo ""
TEST_DATA='{"id":"test123456","value1":"テストデータ","value2":"090-1234-5678"}'
echo "テストデータ: $TEST_DATA"
echo ""

RESPONSE=$(curl -s -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d "$TEST_DATA")

echo -e "${GREEN}レスポンス:${NC}"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""

echo -e "${GREEN}✓ デプロイとテストが正常に完了しました！${NC}"
echo ""
echo "次のステップ:"
echo "1. Firestore Consoleでデータを確認:"
echo "   https://console.cloud.google.com/firestore/data"
echo ""
echo "2. APIを使用してみる:"
echo "   curl $FUNCTION_URL?id=test123456"
echo ""
echo "3. ログを確認:"
echo "   gcloud functions logs read firebase-data-api --region=$REGION --gen2 --limit=50"
echo ""
echo "4. 関数を削除するには:"
echo "   gcloud functions delete firebase-data-api --region=$REGION --gen2"
echo ""
echo "詳細は FIREBASE_SETUP.md を参照してください。"
