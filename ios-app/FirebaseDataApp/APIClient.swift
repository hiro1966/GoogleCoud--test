//
//  APIClient.swift
//  FirebaseDataApp
//
//  Firebase Data APIとの通信を担当
//

import Foundation
import Combine

class APIClient: ObservableObject {
    // MARK: - プロパティ
    
    /// APIのベースURL（デプロイ後のURLに変更してください）
    static let baseURL = "https://asia-northeast1-YOUR-PROJECT-ID.cloudfunctions.net/firebase-data-api"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - データ作成
    
    /// データを作成してFirestoreに保存
    func createData(id: String, value1: String, value2: String) async throws -> DataRecord {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: Self.baseURL) else {
            throw APIError.invalidURL
        }
        
        let request = CreateDataRequest(id: id, value1: value1, value2: value2)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        guard let record = apiResponse.data else {
            throw APIError.noData
        }
        
        return record
    }
    
    // MARK: - データ取得
    
    /// 特定のIDのデータを取得
    func fetchData(id: String) async throws -> DataRecord {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard var urlComponents = URLComponents(string: Self.baseURL) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "id", value: id)]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        guard let record = apiResponse.data else {
            throw APIError.noData
        }
        
        return record
    }
    
    // MARK: - 全データ取得
    
    /// 全データを取得
    func fetchAllData() async throws -> [DataRecord] {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: Self.baseURL) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // レスポンスの構造を確認
        struct AllDataResponse: Codable {
            let success: Bool
            let count: Int
            let data: [DataRecord]
        }
        
        let apiResponse = try JSONDecoder().decode(AllDataResponse.self, from: data)
        
        return apiResponse.data
    }
    
    // MARK: - データ更新
    
    /// データを更新
    func updateData(id: String, value1: String, value2: String) async throws -> DataRecord {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: Self.baseURL) else {
            throw APIError.invalidURL
        }
        
        let request = CreateDataRequest(id: id, value1: value1, value2: value2)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        guard let record = apiResponse.data else {
            throw APIError.noData
        }
        
        return record
    }
    
    // MARK: - データ削除
    
    /// データを削除
    func deleteData(id: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard var urlComponents = URLComponents(string: Self.baseURL) else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "id", value: id)]
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - エラー定義
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        case .noData:
            return "データが見つかりません"
        case .decodingError:
            return "データの解析に失敗しました"
        }
    }
}
