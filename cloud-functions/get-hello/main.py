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
