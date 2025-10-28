//
//  ContentView.swift
//  FirebaseDataApp
//
//  メインビュー - データ送信と取得
//

import SwiftUI

struct ContentView: View {
    @StateObject private var apiClient = APIClient()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // データ送信タブ
            CreateDataView(apiClient: apiClient)
                .tabItem {
                    Label("送信", systemImage: "square.and.arrow.up")
                }
                .tag(0)
            
            // データ取得タブ
            FetchDataView(apiClient: apiClient)
                .tabItem {
                    Label("取得", systemImage: "square.and.arrow.down")
                }
                .tag(1)
            
            // データ一覧タブ
            DataListView(apiClient: apiClient)
                .tabItem {
                    Label("一覧", systemImage: "list.bullet")
                }
                .tag(2)
        }
    }
}

// MARK: - データ送信画面
struct CreateDataView: View {
    @ObservedObject var apiClient: APIClient
    
    @State private var id = ""
    @State private var value1 = ""
    @State private var value2 = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccessAlert = false
    
    // ID自動生成用
    @State private var autoGenerateID = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("データ入力")) {
                    // ID入力
                    HStack {
                        TextField("ID (10文字)", text: $id)
                            .keyboardType(.asciiCapable)
                            .disabled(autoGenerateID)
                        
                        Button(action: {
                            autoGenerateID.toggle()
                            if autoGenerateID {
                                generateRandomID()
                            }
                        }) {
                            Image(systemName: autoGenerateID ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(autoGenerateID ? .green : .gray)
                        }
                    }
                    
                    if !id.isEmpty && id.count != 10 {
                        Text("IDは10文字である必要があります")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Value1入力
                    VStack(alignment: .leading) {
                        TextField("テキスト (100文字以内)", text: $value1)
                        Text("\(value1.count)/100")
                            .font(.caption)
                            .foregroundColor(value1.count > 100 ? .red : .gray)
                    }
                    
                    // Value2（電話番号）入力
                    TextField("電話番号 (例: 090-1234-5678)", text: $value2)
                        .keyboardType(.phonePad)
                    
                    // 電話番号フォーマットヘルプ
                    Text("対応形式: 090-1234-5678, 09012345678, +81-90-1234-5678")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section {
                    Button(action: sendData) {
                        HStack {
                            Spacer()
                            if apiClient.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("送信")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isValidInput || apiClient.isLoading)
                }
            }
            .navigationTitle("データ送信")
            .alert("入力エラー", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("送信完了", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {
                    clearForm()
                }
            } message: {
                Text("データの送信に成功しました！")
            }
        }
    }
    
    private var isValidInput: Bool {
        id.count == 10 && !value1.isEmpty && value1.count <= 100 && !value2.isEmpty
    }
    
    private func generateRandomID() {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        id = String((0..<10).map { _ in characters.randomElement()! })
    }
    
    private func sendData() {
        guard isValidInput else {
            alertMessage = "すべてのフィールドを正しく入力してください"
            showingAlert = true
            return
        }
        
        Task {
            do {
                _ = try await apiClient.createData(id: id, value1: value1, value2: value2)
                await MainActor.run {
                    showingSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func clearForm() {
        id = ""
        value1 = ""
        value2 = ""
        autoGenerateID = false
    }
}

// MARK: - データ取得画面
struct FetchDataView: View {
    @ObservedObject var apiClient: APIClient
    
    @State private var searchID = ""
    @State private var fetchedData: DataRecord?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ID入力")) {
                    TextField("ID (10文字)", text: $searchID)
                        .keyboardType(.asciiCapable)
                    
                    if !searchID.isEmpty && searchID.count != 10 {
                        Text("IDは10文字である必要があります")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: fetchData) {
                        HStack {
                            Spacer()
                            if apiClient.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("取得")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(searchID.count != 10 || apiClient.isLoading)
                }
                
                if let data = fetchedData {
                    Section(header: Text("取得結果")) {
                        LabeledContent("ID", value: data.id)
                        LabeledContent("テキスト", value: data.value1)
                        LabeledContent("電話番号", value: data.value2)
                        
                        if let createdAt = data.createdAt {
                            LabeledContent("作成日時", value: formatDate(createdAt))
                        }
                        
                        if let updatedAt = data.updatedAt {
                            LabeledContent("更新日時", value: formatDate(updatedAt))
                        }
                    }
                }
            }
            .navigationTitle("データ取得")
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func fetchData() {
        guard searchID.count == 10 else {
            alertMessage = "IDは10文字である必要があります"
            showingAlert = true
            return
        }
        
        Task {
            do {
                let data = try await apiClient.fetchData(id: searchID)
                await MainActor.run {
                    fetchedData = data
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    fetchedData = nil
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - データ一覧画面
struct DataListView: View {
    @ObservedObject var apiClient: APIClient
    
    @State private var dataList: [DataRecord] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataList) { data in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(data.id)
                            .font(.headline)
                        Text(data.value1)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(data.value2)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("データ一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: fetchAllData) {
                        if apiClient.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(apiClient.isLoading)
                }
            }
            .onAppear {
                fetchAllData()
            }
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func fetchAllData() {
        Task {
            do {
                let data = try await apiClient.fetchAllData()
                await MainActor.run {
                    dataList = data
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - プレビュー
#Preview {
    ContentView()
}
