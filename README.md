# Shukatsu Board

就活中の企業情報、選考進捗、ES、募集要項、締切、マイページID/パスワードをローカルファーストで管理するiOSアプリです。

## 開発環境

- Xcode 15以上
- iOS 17以上
- XcodeGen

## セットアップ

```sh
xcodegen generate
open ShukatsuBoard.xcodeproj
```

`project.yml` の `bundleIdPrefix`、App Group、署名チームは自分のApple Developer設定に合わせて変更してください。

## MVP実装済みの範囲

- SwiftUI / SwiftDataによる企業、ES、募集要項、タスク管理
- Keychainへのパスワード保存
- Face ID / Touch ID認証後のパスワードコピー
- ローカル通知予約
- コピペ文章のローカル解析
- Share ExtensionからのURL/テキスト取り込み入口
- デモデータ投入

## 方針

- パスワード本文はDBへ保存しない
- 外部サーバーへ就活情報を送信しない
- 解析候補はユーザー確認後に保存する
- 企業サイトへの自動ログインは行わない
