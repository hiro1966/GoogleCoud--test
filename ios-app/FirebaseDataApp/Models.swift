//
//  Models.swift
//  FirebaseDataApp
//
//  データモデル定義
//

import Foundation

// MARK: - データレコード
struct DataRecord: Codable, Identifiable {
    var id: String
    var value1: String
    var value2: String
    var createdAt: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case value1
        case value2
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - APIレスポンス
struct APIResponse: Codable {
    let success: Bool
    let message: String?
    let data: DataRecord?
    let count: Int?
}

struct APIErrorResponse: Codable {
    let error: String
    let message: String?
}

// MARK: - APIリクエスト
struct CreateDataRequest: Codable {
    let id: String
    let value1: String
    let value2: String
}

// MARK: - バリデーション
extension DataRecord {
    /// IDのバリデーション（10文字固定）
    var isValidID: Bool {
        return id.count == 10
    }
    
    /// Value1のバリデーション（100文字以内）
    var isValidValue1: Bool {
        return value1.count <= 100 && !value1.isEmpty
    }
    
    /// Value2（電話番号）のバリデーション
    var isValidValue2: Bool {
        return isValidPhoneNumber(value2)
    }
    
    /// すべてのフィールドが有効か
    var isValid: Bool {
        return isValidID && isValidValue1 && isValidValue2
    }
    
    /// 電話番号の検証
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // ハイフンとスペースを削除
        let cleanPhone = phone.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        // 日本の電話番号パターン
        let patterns = [
            "^0[789]0\\d{8}$",      // 携帯電話: 090, 080, 070
            "^0\\d{9,10}$",          // 固定電話: 0X-XXXX-XXXX
            "^\\+81[789]0\\d{8}$",  // 国際形式携帯
            "^\\+81\\d{9,10}$"      // 国際形式固定
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(location: 0, length: cleanPhone.utf16.count)
                if regex.firstMatch(in: cleanPhone, options: [], range: range) != nil {
                    return true
                }
            }
        }
        
        return false
    }
}

// MARK: - サンプルデータ
extension DataRecord {
    static var sample: DataRecord {
        DataRecord(
            id: "1234567890",
            value1: "サンプルデータ",
            value2: "090-1234-5678",
            createdAt: "2024-01-01T00:00:00",
            updatedAt: "2024-01-01T00:00:00"
        )
    }
}
