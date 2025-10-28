# Firebase Data API 使用例

各プログラミング言語でのAPI使用例を紹介します。

## 📋 共通設定

**APIのベースURL**を環境変数として設定することを推奨します：

```bash
export API_URL="https://asia-northeast1-PROJECT_ID.cloudfunctions.net/firebase-data-api"
```

---

## 🐍 Python

### 依存関係のインストール

```bash
pip install requests
```

### 完全なサンプルコード

```python
import requests
import json

# APIのベースURL
API_URL = "https://asia-northeast1-PROJECT_ID.cloudfunctions.net/firebase-data-api"

# 1. データ作成（POST）
def create_data(id_value, value1, value2):
    """データを作成"""
    data = {
        "id": id_value,
        "value1": value1,
        "value2": value2
    }
    
    response = requests.post(API_URL, json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.json()

# 2. データ取得（GET）
def get_data(id_value):
    """特定のIDのデータを取得"""
    params = {"id": id_value}
    response = requests.get(API_URL, params=params)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.json()

# 3. 全データ取得（GET）
def get_all_data():
    """全データを取得"""
    response = requests.get(API_URL)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.json()

# 4. データ更新（PUT）
def update_data(id_value, value1, value2):
    """データを更新"""
    data = {
        "id": id_value,
        "value1": value1,
        "value2": value2
    }
    
    response = requests.put(API_URL, json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.json()

# 5. データ削除（DELETE）
def delete_data(id_value):
    """データを削除"""
    params = {"id": id_value}
    response = requests.delete(API_URL, params=params)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    return response.json()

# 使用例
if __name__ == "__main__":
    # データ作成
    print("=== データ作成 ===")
    create_data("python1234", "Pythonからのテスト", "090-1111-2222")
    
    # データ取得
    print("\n=== データ取得 ===")
    get_data("python1234")
    
    # 全データ取得
    print("\n=== 全データ取得 ===")
    get_all_data()
    
    # データ更新
    print("\n=== データ更新 ===")
    update_data("python1234", "更新されたデータ", "080-3333-4444")
    
    # データ削除
    print("\n=== データ削除 ===")
    delete_data("python1234")
```

---

## 🟨 JavaScript (Node.js)

### 依存関係のインストール

```bash
npm install axios
```

### 完全なサンプルコード

```javascript
const axios = require('axios');

// APIのベースURL
const API_URL = 'https://asia-northeast1-PROJECT_ID.cloudfunctions.net/firebase-data-api';

// 1. データ作成（POST）
async function createData(id, value1, value2) {
  try {
    const response = await axios.post(API_URL, {
      id: id,
      value1: value1,
      value2: value2
    });
    console.log('Status:', response.status);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// 2. データ取得（GET）
async function getData(id) {
  try {
    const response = await axios.get(API_URL, {
      params: { id: id }
    });
    console.log('Status:', response.status);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// 3. 全データ取得（GET）
async function getAllData() {
  try {
    const response = await axios.get(API_URL);
    console.log('Status:', response.status);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// 4. データ更新（PUT）
async function updateData(id, value1, value2) {
  try {
    const response = await axios.put(API_URL, {
      id: id,
      value1: value1,
      value2: value2
    });
    console.log('Status:', response.status);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// 5. データ削除（DELETE）
async function deleteData(id) {
  try {
    const response = await axios.delete(API_URL, {
      params: { id: id }
    });
    console.log('Status:', response.status);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// 使用例
(async () => {
  try {
    // データ作成
    console.log('=== データ作成 ===');
    await createData('nodejs1234', 'Node.jsからのテスト', '090-5555-6666');
    
    // データ取得
    console.log('\n=== データ取得 ===');
    await getData('nodejs1234');
    
    // 全データ取得
    console.log('\n=== 全データ取得 ===');
    await getAllData();
    
    // データ更新
    console.log('\n=== データ更新 ===');
    await updateData('nodejs1234', '更新されたデータ', '080-7777-8888');
    
    // データ削除
    console.log('\n=== データ削除 ===');
    await deleteData('nodejs1234');
  } catch (error) {
    console.error('処理エラー:', error);
  }
})();
```

---

## 🌐 JavaScript (ブラウザ/fetch API)

### HTML + JavaScriptサンプル

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>Firebase Data API テスト</title>
</head>
<body>
    <h1>Firebase Data API テスト</h1>
    
    <div>
        <h2>データ作成</h2>
        <input id="createId" placeholder="ID (10文字)" maxlength="10">
        <input id="createValue1" placeholder="Value1">
        <input id="createValue2" placeholder="電話番号">
        <button onclick="createData()">作成</button>
    </div>
    
    <div>
        <h2>データ取得</h2>
        <input id="getId" placeholder="ID (10文字)">
        <button onclick="getData()">取得</button>
        <button onclick="getAllData()">全件取得</button>
    </div>
    
    <div id="result"></div>
    
    <script>
        const API_URL = 'https://asia-northeast1-PROJECT_ID.cloudfunctions.net/firebase-data-api';
        
        // 結果表示用
        function displayResult(data) {
            document.getElementById('result').innerHTML = 
                '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
        
        // データ作成
        async function createData() {
            const id = document.getElementById('createId').value;
            const value1 = document.getElementById('createValue1').value;
            const value2 = document.getElementById('createValue2').value;
            
            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ id, value1, value2 })
                });
                
                const data = await response.json();
                displayResult(data);
            } catch (error) {
                console.error('Error:', error);
                displayResult({ error: error.message });
            }
        }
        
        // データ取得
        async function getData() {
            const id = document.getElementById('getId').value;
            
            try {
                const response = await fetch(`${API_URL}?id=${id}`);
                const data = await response.json();
                displayResult(data);
            } catch (error) {
                console.error('Error:', error);
                displayResult({ error: error.message });
            }
        }
        
        // 全データ取得
        async function getAllData() {
            try {
                const response = await fetch(API_URL);
                const data = await response.json();
                displayResult(data);
            } catch (error) {
                console.error('Error:', error);
                displayResult({ error: error.message });
            }
        }
    </script>
</body>
</html>
```

---

## 🔧 cURL

### データ作成（POST）

```bash
curl -X POST https://YOUR-FUNCTION-URL/firebase-data-api \
  -H "Content-Type: application/json" \
  -d '{
    "id": "curl123456",
    "value1": "curlからのテスト",
    "value2": "090-9999-0000"
  }'
```

### データ取得（GET）- 単一

```bash
curl https://YOUR-FUNCTION-URL/firebase-data-api?id=curl123456
```

### 全データ取得（GET）

```bash
curl https://YOUR-FUNCTION-URL/firebase-data-api
```

### データ更新（PUT）

```bash
curl -X PUT https://YOUR-FUNCTION-URL/firebase-data-api \
  -H "Content-Type: application/json" \
  -d '{
    "id": "curl123456",
    "value1": "更新されたデータ",
    "value2": "080-1111-2222"
  }'
```

### データ削除（DELETE）

```bash
curl -X DELETE https://YOUR-FUNCTION-URL/firebase-data-api?id=curl123456
```

---

## 💻 PowerShell (Windows)

### データ作成（POST）

```powershell
$API_URL = "https://YOUR-FUNCTION-URL/firebase-data-api"

$body = @{
    id = "ps1234567890"
    value1 = "PowerShellからのテスト"
    value2 = "090-1234-5678"
} | ConvertTo-Json

Invoke-RestMethod -Uri $API_URL -Method Post -Body $body -ContentType "application/json"
```

### データ取得（GET）

```powershell
$API_URL = "https://YOUR-FUNCTION-URL/firebase-data-api"
$id = "ps1234567890"

Invoke-RestMethod -Uri "$API_URL?id=$id" -Method Get
```

### 全データ取得

```powershell
$API_URL = "https://YOUR-FUNCTION-URL/firebase-data-api"

Invoke-RestMethod -Uri $API_URL -Method Get
```

---

## 🦀 Rust

### Cargo.toml

```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

### サンプルコード

```rust
use reqwest;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct DataRecord {
    id: String,
    value1: String,
    value2: String,
}

const API_URL: &str = "https://YOUR-FUNCTION-URL/firebase-data-api";

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // データ作成
    let record = DataRecord {
        id: "rust123456".to_string(),
        value1: "Rustからのテスト".to_string(),
        value2: "090-1234-5678".to_string(),
    };
    
    let client = reqwest::Client::new();
    let response = client.post(API_URL)
        .json(&record)
        .send()
        .await?;
    
    println!("Status: {}", response.status());
    println!("Response: {:?}", response.json::<serde_json::Value>().await?);
    
    Ok(())
}
```

---

## 📱 エラーハンドリング例（Python）

```python
import requests
from typing import Optional, Dict, Any

class FirebaseDataAPIClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
    
    def create_data(self, id_value: str, value1: str, value2: str) -> Optional[Dict[Any, Any]]:
        """データを作成（エラーハンドリング付き）"""
        try:
            response = requests.post(
                self.base_url,
                json={
                    "id": id_value,
                    "value1": value1,
                    "value2": value2
                },
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 400:
                print(f"バリデーションエラー: {e.response.json()}")
            elif e.response.status_code == 404:
                print("データが見つかりません")
            else:
                print(f"HTTPエラー: {e}")
            return None
        
        except requests.exceptions.ConnectionError:
            print("接続エラー: APIに接続できません")
            return None
        
        except requests.exceptions.Timeout:
            print("タイムアウトエラー: APIの応答が遅すぎます")
            return None
        
        except Exception as e:
            print(f"予期しないエラー: {e}")
            return None

# 使用例
client = FirebaseDataAPIClient("https://YOUR-FUNCTION-URL/firebase-data-api")
result = client.create_data("test123456", "テスト", "090-1234-5678")

if result:
    print("成功:", result)
else:
    print("失敗")
```

---

## 🔑 ベストプラクティス

### 1. 環境変数の使用

```python
import os

API_URL = os.environ.get('FIREBASE_API_URL', 'default-url')
```

### 2. リトライ機能

```python
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def create_session_with_retry():
    session = requests.Session()
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[500, 502, 503, 504]
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session
```

### 3. タイムアウトの設定

```python
response = requests.post(API_URL, json=data, timeout=10)
```

---

## 📚 参考リンク

- [Requests (Python)](https://requests.readthedocs.io/)
- [Axios (JavaScript)](https://axios-http.com/)
- [Fetch API (JavaScript)](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- [cURL Documentation](https://curl.se/docs/)
