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

## 引き継ぎメモ

今日までの実装状況、最新CI、次にやるべき作業は [HANDOFF.md](HANDOFF.md) にまとめています。

## App Store提出準備

- アプリアイコン: `ShukatsuBoard/Support/Assets.xcassets/AppIcon.appiconset`
- プライバシーポリシー下書き: [docs/privacy-policy.md](docs/privacy-policy.md)
- App Store文面下書き: [docs/app-store-metadata.md](docs/app-store-metadata.md)

## MVP実装済みの範囲

- SwiftUI / SwiftDataによる企業、ES、募集要項、タスク管理
- Keychainへのパスワード保存
- Face ID / Touch ID認証後のパスワードコピー
- ローカル通知予約
- コピペ文章のローカル解析
- Share ExtensionからのURL/テキスト取り込み入口
- スクショ画像からのOCR取り込み
- カレンダーへの予定追加
- 企業比較画面
- デモデータ投入
- GitHub ActionsでのSimulatorビルド、Unit Test、UI Test

## 方針

- パスワード本文はDBへ保存しない
- 外部サーバーへ就活情報を送信しない
- 解析候補はユーザー確認後に保存する
- 企業サイトへの自動ログインは行わない

## Apple Developer Program有効化後の手順

Apple Developer Programの購入処理が完了したら、以下を確認します。

1. [Apple Developer Account](https://developer.apple.com/account) にログインする
2. `Certificates, Identifiers & Profiles` に入れることを確認する
3. [App Store Connect](https://appstoreconnect.apple.com/) の `Apps` に入れることを確認する

次に、Developer Accountで以下を作成します。

```text
App ID:
com.sl21ku.ShukatsuBoard

Share Extension App ID:
com.sl21ku.ShukatsuBoard.ShareExtension

App Group:
group.com.sl21ku.ShukatsuBoard
```

作成後、`project.yml` とentitlements内の仮IDを置き換えます。

```text
com.example.ShukatsuBoard
-> com.sl21ku.ShukatsuBoard

com.example.ShukatsuBoard.ShareExtension
-> com.sl21ku.ShukatsuBoard.ShareExtension

group.com.example.ShukatsuBoard
-> group.com.sl21ku.ShukatsuBoard
```

その後、App Store Connectで新規アプリを作成し、Bundle IDに `com.sl21ku.ShukatsuBoard` を選択します。
