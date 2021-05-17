# 12_install_sidekiq

## なぜsidekiqやredisを利用する必要があるのか

[railsガイド](https://railsguides.jp/active_job_basics.html)によると

> デフォルトのRailsは非同期キューを実装します。これは、インプロセスのスレッドプールでジョブを実行します。ジョブは非同期に実行されますが、再起動するとすべてのジョブは失われます。

つまり上記の問題を解決するために、sidekiqやredisを利用してメール送信のジョブを永続化させる必要があるというわけ

## そのまえに　キュー について

`queue(キュー)`...最も基本的なデータ構造の一つで、要素を入ってきた順に１列に並べ、先に入れた要素から順に取り出すという規則で出し入れを行うもの。順番を待つ人の行列と同じ仕組みであるため「待ち行列」とも訳される。「先入れ先出し」方式のデータ構造

`enqueue(エンキュー)`...キューに要素を追加する操作のこと。要素の最後尾に追加される。

`dequeue(デキュー)`...キューから先頭の要素を取り出す操作のこと。

`queuing/queueing(キューイング)`...キューを用いて要素の管理を行うこと。キューイングは機器やプログラムなどの2つの主体の間でデータの受け渡しを`非同期`に行う手法として使われる

[キュー 【queue】 待ち行列](https://e-words.jp/w/%E3%82%AD%E3%83%A5%E3%83%BC.html)

## redis

redisとは...メモリ上で動作するキーバリューストア型のNoSQLデータベース。全てのデータをメモリ上に格納して、各種アプリケーションからの高速アクセスを可能にするもの。

上記にあるよう通常メモリ上のデータは再起動すると消えてしまう。Redisもメモリを利用するが、メモリ上のデータを任意のタイミングでディスク上に格納して保持する仕組みを持っている。

[Redisの特徴](https://agency-star.co.jp/column/redis/)

[【入門】Redis](https://qiita.com/wind-up-bird/items/f2d41d08e86789322c71)

### redisのインストール

`$ brew install redis`

`$ redis-server`コマンドでredis-serverを起動させる

## sidekiqについて

[`sidekiq`](https://github.com/mperham/sidekiq)...バックグラウンドジョブを動作させるためのフレームワーク。Rubyが動作する環境であればActiveJobを使わなくてもsidekiqは利用できるとのこと

### actibejobのアダプタとしてsidekiqを利用する

ActiveJobは、キューバックエンドである`sikdekiq`に接続するためのアダプタがビルトインされているため簡単に接続ができる。そうすることで、Railsが停止してもジョブが失われないようにする

Sidekiqを使うためには、`Client`, `Redis`, `Server`の3つが必要になる。

`Client`は、Railsアプリケーション自身のこと。`XXXXJob.perform_later`などを実行する主体のこと

`Redis`は、Jobをキューイング(行列を作ること)するために利用する。またClientからアクセスできるようにする必要がある。

`Servre`は、Railsとは別プロセスとして起動させる。`bundle exec sidekiq`コマンドで実行

## sidekiqの導入・設定

まずは、gemをインストールする

```
# Gemfile

gem 'sidekiq'
```

次に、サーバーを立ち上げるのだが、defaultというキューとmailersというキュー２種類を受け付けるというオプションを指定して実行した方がいいらしい。これは、Active jobとAction Mailerを利用してメールを非同期で送信するように指定したいから。[参考](https://qiita.com/QUANON/items/09c87787df6b0d287896)

`$ bundle exec sidekiq -q default -q mailers`コマンドでサーバーを起動させる

サーバーを起動させたら、次にactive_job.queue_adapterにて`:sidekiq`を指定する

```
# config/application.rb

class Application < Rails::Application
  ////
  config.active_job.queue_adapter = :sidekiq
end
```

次に、`config/initializers/sidekiq.rb`ファイルを自作し、以下のように記述する[参照](https://github.com/mperham/sidekiq/wiki/Using-Redis#using-an-initializer)

```
# config/initializers/sidekiq.rb

Sidekiq.configure_server do |confg|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end
```

最後に`default`, `mailers`の設定を行う

`$ bundle exec sidekiq -C config/sidekiq.yml`コマンドでsidekiq.ymlファイルを作成ｓ、以下の内容に編集する[設定参考](https://github.com/mperham/sidekiq/wiki/Advanced-Options)

```
# config/sidekiq.yml

# 処理できるprocess数の設定
concurrency: 25

# キューの設定
queues:
  - default
  - mailers
```

## Sidekiqのダッシュボードからジョブの確認・削除を行う

Sidekiqには、ジョブの処理状況をGUIで確認できるインターフェースが備わっている。そのインターフェースは`sinatora`で動いているため、`sinatora`のインストールが必要

```
# Gemfile

gem 'sidekiq'
gem 'sinatora'
```

`$ bundle install`

次に、routes.rbにsidekiqのインターフェースをマウントする。letter_opener_webを似ている

```
# routes.rb

# Sidekiqのダッシュボード導入のために必ず記述するように
require 'sidekiq/web'

if Rails.env.develop?
  mount LetterOpennerWeb::Engine, at: '/latter_opener'
  mount Sidekiq::Web, at: '/sidekiq'
end
```

上記の設定により`http://localhost:3000/sidekiq`にアクセスすることで、sidekiqのダッシュボードに入ることができる。このダッシュボード内で、実行中のジョブを確認したり・停止したり、キューにあるジョブを確認したり・削除したり、リトライキュにあるジョブを確認したり・削除したりできる

sidekiqのダッシュボードはsinatoraで動作しているため、ダッシュボードにアクセスしてからRailsに戻ると、セッションが失効し、ログオフした状態になってしまう。この問題を解決するために、RailsとRedisと2つのサーバーを起動しておけばいいとのこと

<br>

[miketaさん](https://github.com/miketa-webprgr/TIL/blob/master/11_Rails_Intensive_Training/12_issue_note.md)

[Ruby on Rails の Active Job と SideKiq でバックグラウンドジョブをキューイングして実行する](https://qiita.com/tatsurou313/items/d3664f8dda05dcd12d56)
