"""
Firebase Data API - Google Cloud Functions
Firestoreにデータを格納・取得するAPI

データモデル:
- ID: 10文字のテキスト
- Value1: 100文字以内のテキスト
- Value2: 電話番号
"""
import re
import functions_framework
from flask import jsonify, request
from google.cloud import firestore
from datetime import datetime


# Firestoreクライアントの初期化
db = firestore.Client()
COLLECTION_NAME = 'data_records'


def validate_phone_number(phone: str) -> bool:
    """
    電話番号の検証
    
    Args:
        phone: 検証する電話番号
        
    Returns:
        bool: 有効な電話番号の場合True
        
    対応フォーマット:
    - 090-1234-5678
    - 09012345678
    - +81-90-1234-5678
    - +819012345678
    """
    if not phone:
        return False
    
    # ハイフンとスペースを削除
    clean_phone = re.sub(r'[-\s]', '', phone)
    
    # 日本の電話番号パターン
    patterns = [
        r'^0[789]0\d{8}$',  # 携帯電話: 090, 080, 070
        r'^0\d{9,10}$',      # 固定電話: 0X-XXXX-XXXX
        r'^\+81[789]0\d{8}$',  # 国際形式携帯
        r'^\+81\d{9,10}$'     # 国際形式固定
    ]
    
    return any(re.match(pattern, clean_phone) for pattern in patterns)


def validate_data(data: dict) -> tuple:
    """
    データの検証
    
    Args:
        data: 検証するデータ
        
    Returns:
        tuple: (is_valid, error_message)
    """
    # IDの検証
    if 'id' not in data:
        return False, 'ID is required'
    
    id_value = str(data['id'])
    if len(id_value) != 10:
        return False, 'ID must be exactly 10 characters'
    
    # Value1の検証
    if 'value1' not in data:
        return False, 'Value1 is required'
    
    value1 = str(data['value1'])
    if len(value1) > 100:
        return False, 'Value1 must be 100 characters or less'
    
    # Value2（電話番号）の検証
    if 'value2' not in data:
        return False, 'Value2 (phone number) is required'
    
    value2 = str(data['value2'])
    if not validate_phone_number(value2):
        return False, 'Value2 must be a valid phone number'
    
    return True, None


@functions_framework.http
def firebase_data_api(request):
    """
    Firebase Data API のメインエンドポイント
    
    Methods:
        POST: データを格納
        GET: データを取得（IDパラメータで特定、なしで全件取得）
        PUT: データを更新
        DELETE: データを削除
    """
    # CORSヘッダー
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    }
    
    # OPTIONSリクエスト（CORS preflight）
    if request.method == 'OPTIONS':
        return ('', 204, headers)
    
    try:
        # POSTリクエスト: データ格納
        if request.method == 'POST':
            data = request.get_json()
            
            if not data:
                return (jsonify({'error': 'No data provided'}), 400, headers)
            
            # データ検証
            is_valid, error_message = validate_data(data)
            if not is_valid:
                return (jsonify({'error': error_message}), 400, headers)
            
            # Firestoreにデータを格納
            doc_id = str(data['id'])
            doc_data = {
                'id': doc_id,
                'value1': str(data['value1']),
                'value2': str(data['value2']),
                'created_at': datetime.utcnow(),
                'updated_at': datetime.utcnow()
            }
            
            db.collection(COLLECTION_NAME).document(doc_id).set(doc_data)
            
            return (jsonify({
                'success': True,
                'message': 'Data stored successfully',
                'data': {
                    'id': doc_id,
                    'value1': doc_data['value1'],
                    'value2': doc_data['value2']
                }
            }), 201, headers)
        
        # GETリクエスト: データ取得
        elif request.method == 'GET':
            # IDパラメータがある場合は特定のデータを取得
            doc_id = request.args.get('id')
            
            if doc_id:
                # 単一データ取得
                doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
                doc = doc_ref.get()
                
                if not doc.exists:
                    return (jsonify({'error': 'Data not found'}), 404, headers)
                
                data = doc.to_dict()
                # datetimeオブジェクトを文字列に変換
                if 'created_at' in data:
                    data['created_at'] = data['created_at'].isoformat()
                if 'updated_at' in data:
                    data['updated_at'] = data['updated_at'].isoformat()
                
                return (jsonify({
                    'success': True,
                    'data': data
                }), 200, headers)
            else:
                # 全データ取得
                docs = db.collection(COLLECTION_NAME).stream()
                data_list = []
                
                for doc in docs:
                    data = doc.to_dict()
                    # datetimeオブジェクトを文字列に変換
                    if 'created_at' in data:
                        data['created_at'] = data['created_at'].isoformat()
                    if 'updated_at' in data:
                        data['updated_at'] = data['updated_at'].isoformat()
                    data_list.append(data)
                
                return (jsonify({
                    'success': True,
                    'count': len(data_list),
                    'data': data_list
                }), 200, headers)
        
        # PUTリクエスト: データ更新
        elif request.method == 'PUT':
            data = request.get_json()
            
            if not data or 'id' not in data:
                return (jsonify({'error': 'ID is required'}), 400, headers)
            
            # データ検証
            is_valid, error_message = validate_data(data)
            if not is_valid:
                return (jsonify({'error': error_message}), 400, headers)
            
            doc_id = str(data['id'])
            doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
            
            # ドキュメントの存在確認
            if not doc_ref.get().exists:
                return (jsonify({'error': 'Data not found'}), 404, headers)
            
            # データ更新
            update_data = {
                'value1': str(data['value1']),
                'value2': str(data['value2']),
                'updated_at': datetime.utcnow()
            }
            doc_ref.update(update_data)
            
            return (jsonify({
                'success': True,
                'message': 'Data updated successfully',
                'data': {
                    'id': doc_id,
                    'value1': update_data['value1'],
                    'value2': update_data['value2']
                }
            }), 200, headers)
        
        # DELETEリクエスト: データ削除
        elif request.method == 'DELETE':
            doc_id = request.args.get('id')
            
            if not doc_id:
                return (jsonify({'error': 'ID is required'}), 400, headers)
            
            doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
            
            # ドキュメントの存在確認
            if not doc_ref.get().exists:
                return (jsonify({'error': 'Data not found'}), 404, headers)
            
            # データ削除
            doc_ref.delete()
            
            return (jsonify({
                'success': True,
                'message': 'Data deleted successfully',
                'id': doc_id
            }), 200, headers)
        
        # その他のメソッドはサポートしない
        else:
            return (jsonify({'error': 'Method not allowed'}), 405, headers)
    
    except Exception as e:
        # エラーハンドリング
        return (jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500, headers)
