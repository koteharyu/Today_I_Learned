# ActiveJobについて

ActiveJobとは、ジョブを宣言し、それによってバックグラウンドでさまざまな方法によるキュー操作を実行するためのフレームワーク

### Jobとは

`Job`とは・・・定期的なクリーンアップ、請求書発行やメール配信など

## Default

デフォルトのRails非同期キューを実装します。これは、インプロセンスのスプレッドプールでジョブを実行します。ジョブは非同期に実行されるが、再起動するとすべてのJobは失われます。

つまり、Railsサーバーを再起動した途端、メール送信のジョブは全て失われてしまう。よって非同期処理を行うための`Sidekiq`とキューを保存するための`Redis`を導入する必要がある

## ジョブを実行する

production環境でのジョブのキュー登録と実行では、キューイングのバックエンドを用意しておく必要がある。Rails自身が提供するのは、ジョブをメモリに保存するインプロセスのキューイングシステムだけ。プロセスがクラッシュしたりコンピューターをリセットしたりすると、デフォルトの非同期バックエンドの振る舞いによって主要なジョブが失われてしまう。

キューバックエンドは、`Sidekiq`, `Resque`, `Delayed Job`など種類がある。ActiveJobはこれらのキューバックエンドに接続できるアダプタがビルトイン(デフォルト・組み込まれている)で用意されている。

## Sidekiqの設定

sidekiqの設定について

必ずGemfileに`sidekiq`を追加し、sidekiq固有のインストール方法や、デプロイ方法に従うこと

```
# config/application.rb

class Application < Rails::Application
  #...
  config.active_job.queue_adaptre = :sidekiq
end
```

## Action Mailer 非同期でのメール送信

リクエストーレスポンスのサイクルの外でメールを送信することが最近では良く行われる。これによりユーザーが送信を待つ必要がなくなる。ActiveJobはActionMailerと統合されているので、非同期メールを簡単に実行できる。

```
# すぐにメール送信したい場合は#deliver_nowを使用
UserMailer.welcome(@user).deliver_now

# ActiveJobを使用して後でメール送信したい場合は#delivery_laterを使用
UserMailer.welcome(@user).delivery_later
```

一般的に、非同期キュー(.delivery_laterでメールを送信するなど)はRakeタスクに書いても動かない。Rakeが終了すると、.deliver_laterがメールの処理を完了する前にインプロセスのスプレッドプールを削除する可能性があるため。この問題を回避するには、.deliver_nowを使用するか、delevopmet環境で永続的キューを実行する

[Railsガイド ActiveJob](https://railsguides.jp/active_job_basics.html)
