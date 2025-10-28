# Windowsバッチファイルの文字コードと改行コードについて

## 📋 重要な注意事項

Windowsバッチファイル（`.bat`, `.cmd`）は、以下の設定が必要です：

### 必須設定

- **文字コード**: Shift-JIS (CP932)
- **改行コード**: CRLF (Windows形式)

これらが正しく設定されていないと、以下の問題が発生します：
- 日本語が文字化けする
- バッチファイルが正常に実行されない
- エラーメッセージが表示されない

## 🔧 このプロジェクトでの対応

### 1. `.gitattributes`による自動変換

このプロジェクトでは`.gitattributes`ファイルで以下を設定しています：

```
*.bat text eol=crlf working-tree-encoding=CP932
*.cmd text eol=crlf working-tree-encoding=CP932
```

これにより、Git操作時に自動的に適切な文字コード・改行コードに変換されます。

### 2. 既存ファイルの変換

すべての`.bat`ファイルは以下のコマンドで変換済みです：

```bash
# Shift-JISに変換 + CRLF改行に変換
iconv -f UTF-8 -t SHIFT-JIS file.bat > file_sjis.bat
sed -i 's/$/\r/' file_sjis.bat
mv file_sjis.bat file.bat
```

## 🪟 Windowsでの編集方法

### Visual Studio Code

1. **文字コードの設定**
   - ファイルを開く
   - 右下の「UTF-8」をクリック
   - 「エンコード付きで保存」→「Shift-JIS」を選択

2. **改行コードの設定**
   - 右下の「LF」または「CRLF」をクリック
   - 「CRLF」を選択

3. **settings.jsonで自動設定**
   ```json
   {
     "[bat]": {
       "files.encoding": "shiftjis",
       "files.eol": "\r\n"
     }
   }
   ```

### Notepad++ (推奨)

1. **エンコーディング**
   - エンコーディング → 文字セット → 日本語 → Shift-JIS

2. **改行コード**
   - 編集 → 改行コード変換 → Windows (CR LF)

### メモ帳 (Windowsデフォルト)

- メモ帳はデフォルトでShift-JIS & CRLFなので問題なし
- ただし、高度な編集には不向き

## 💻 開発者向け情報

### ファイル形式の確認方法

#### Linux/Mac

```bash
# ファイル情報を確認
file deploy.bat

# 詳細な文字コード情報
file -i deploy.bat

# 16進数ダンプで確認 (改行コードをチェック)
od -c deploy.bat | head
```

**正しい出力例**:
```
deploy.bat: DOS batch file, Non-ISO extended-ASCII text, with CRLF line terminators
deploy.bat: text/x-msdos-batch; charset=unknown-8bit
```

#### Windows (PowerShell)

```powershell
# ファイル情報を確認
Get-Content deploy.bat -Encoding Default

# BOMをチェック
$bytes = [System.IO.File]::ReadAllBytes("deploy.bat")
$bytes[0..3]
```

### 文字コード変換ツール

#### Linux/Mac

```bash
# UTF-8 → Shift-JIS
iconv -f UTF-8 -t SHIFT-JIS input.bat > output.bat

# LF → CRLF (sedを使用)
sed -i 's/$/\r/' file.bat

# LF → CRLF (perlを使用)
perl -pi -e 's/\n/\r\n/' file.bat
```

#### Windows (PowerShell)

```powershell
# UTF-8 → Shift-JIS
$content = Get-Content file.bat -Encoding UTF8
$content | Out-File file.bat -Encoding Default

# LF → CRLF
$content = Get-Content file.bat -Raw
$content = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText("file.bat", $content)
```

## 🔄 Gitでの作業フロー

### クローン後の確認

```bash
# リポジトリをクローン
git clone <repository-url>

# バッチファイルの形式を確認
cd project
file cloud-functions/*/deploy.bat
```

### 修正時の注意点

1. **バッチファイルを編集する場合**
   - 必ずShift-JIS + CRLFで保存
   - コミット前に形式を確認

2. **Git操作**
   ```bash
   # 通常通りコミット（.gitattributesが自動変換）
   git add cloud-functions/*/deploy.bat
   git commit -m "Update deploy scripts"
   git push
   ```

3. **変換が失敗した場合**
   ```bash
   # 手動で再変換
   cd cloud-functions/firebase-data-api
   iconv -f UTF-8 -t SHIFT-JIS deploy.bat > deploy_sjis.bat
   sed -i 's/$/\r/' deploy_sjis.bat
   mv deploy_sjis.bat deploy.bat
   
   # 再度コミット
   git add deploy.bat
   git commit --amend
   ```

## ⚠️ よくある問題と解決方法

### 問題1: 日本語が文字化けする

**原因**: UTF-8で保存されている

**解決方法**:
```bash
iconv -f UTF-8 -t SHIFT-JIS deploy.bat > deploy_fixed.bat
mv deploy_fixed.bat deploy.bat
```

### 問題2: バッチファイルが実行されない

**原因**: 改行コードがLFになっている

**解決方法**:
```bash
sed -i 's/$/\r/' deploy.bat
```

### 問題3: GitHubで差分が正しく表示されない

**原因**: `.gitattributes`が正しく設定されていない

**解決方法**:
1. `.gitattributes`を確認
2. ファイルを再変換してコミット

### 問題4: WSL/Git Bashで実行すると文字化けする

**原因**: WSL/Git BashのデフォルトエンコーディングがUTF-8

**対処方法**:
- PowerShellまたはコマンドプロンプトで実行する
- または、WSLで`iconv`を使って表示時に変換

## 📚 参考資料

### 文字コードについて

- **Shift-JIS (CP932)**: Windows日本語版のデフォルト文字コード
- **UTF-8**: Web標準の文字コード
- **変換が必要な理由**: WindowsのコマンドプロンプトはデフォルトでShift-JISを想定

### 改行コードについて

- **CRLF (`\r\n`)**: Windows標準（バイト: 0D 0A）
- **LF (`\n`)**: Unix/Linux/Mac標準（バイト: 0A）
- **CR (`\r`)**: 古いMac標準（バイト: 0D）

### Git Attributes

- [Git Attributes Documentation](https://git-scm.com/docs/gitattributes)
- [Working Tree Encoding](https://git-scm.com/docs/gitattributes#_working_tree_encoding)

## ✅ チェックリスト

バッチファイルを編集・コミットする前に確認：

- [ ] 文字コードがShift-JIS (CP932)である
- [ ] 改行コードがCRLFである
- [ ] 日本語が正しく表示される
- [ ] Windowsで実行できる
- [ ] `.gitattributes`が存在する
- [ ] コミット前に`file`コマンドで確認した

## 🎯 まとめ

このプロジェクトでは：

1. ✅ すべての`.bat`ファイルはShift-JIS + CRLFで保存済み
2. ✅ `.gitattributes`で自動変換が設定済み
3. ✅ Git操作時に適切な形式が維持される

**開発者がすべきこと**:
- バッチファイル編集時は適切な文字コード・改行コードで保存
- 問題があれば上記の変換コマンドを使用
- コミット前に`file`コマンドで確認

これにより、Windowsユーザーが問題なくバッチファイルを実行できます！
