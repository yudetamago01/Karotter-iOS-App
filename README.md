# Karotter iOS

Xcode 16.3 で開ける、iOS 17 以降向けの Karotter クライアントです。最低対応OSは iOS 17.0 です。

## GitHubからのサイドロード配布

`KarotterApp-unsigned.ipa` は実機向けにビルドした未署名IPAです。GitHub Releasesに添付して配布できますが、ダウンロード後にそのままタップしてインストールすることはできません。利用者ごとに、AltStoreやSideloadlyなどの対応するサイドローダーを使って、自分のApple Accountで署名してから端末へインストールしてください。ツールによって必要な手順や条件は異なります。

無料のPersonal Teamで署名したアプリはプロビジョニングが7日で期限切れになるため、継続利用には再署名・再インストールが必要になる場合があります。端末でDeveloper Modeを有効にするよう求められることもあります。

> IPAを公開する前に、XcodeプロジェクトのBundle Identifier `com.example.karotter` を、配布者が管理する一意な値に変更してください。受け取り側のサイドローダーがBundle Identifierを自動変更する場合は、そのツールの案内に従ってください。

## 機能

- `https://karotter.com/` を WKWebView で表示します。タイムライン、ログイン、投稿などはKarotterのWebサービスを利用します。
- WebKitの標準データ領域を使い、ログインセッションを端末に保持します。
- 独自の上部バーを表示せず、Karotterの画面をそのまま表示します。WebKitのスワイプ戻ると引っ張って更新を使えます。
- ホーム画面のアプリアイコンに、提供されたKarotter画像を設定しています。
- サイトが音声・映像機能を使うときは、iOSのマイク・カメラ許可を要求します。
- 通信できない場合は、再読み込み操作を表示します。

## Xcodeで開く

`KarotterApp.xcodeproj` をXcodeで開き、iPhone Simulatorを選んで実行してください。実機へXcodeから直接インストールする場合は、Signing & Capabilitiesで自分の開発チームを選び、Bundle Identifierを自分が使用できる一意な値に変更してください。

このプロジェクトはKarotterのWebサービスを表示するクライアントです。独自のKarotter API実装や、Karotter運営元との公式な提携を含みません。
