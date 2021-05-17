# sidekiq・redisについて

## redisについて

`redis`とはkey-value型のNoSQLデータベースのこと。このredisがキューの受け皿となる。redisにキューが保存されるため、メールのジョブが永続化される。[詳しくはこちらなどを参考に](https://qiita.com/wind-up-bird/items/f2d41d08e86789322c71)

redisのインストール

`$ brew install redis`

redisを起動

`redis-server`

[MacにRedisをインストールする](https://qiita.com/sawa-@github/items/1f303626bdc219ea8fa1)

## sidekiqについて

sidekiqとは、バックグラウンドジョブを動作させるためのフレームワーク。Rubyが動作する環境であればActiveJobを使わなくてもsidekiqは利用できるとのこと

## actibejobのアダプタとしてsidekiqを利用する

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

次に、サーバーを立ち上げるのだが、defaultというキューとmailersというキュー２種類を受け付けるというオプションを指定して実行した方がいい

`$ bundle exec sidekiq -q default -q mailers`でサーバーを起動させる

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


## Jobの作成

ActiveJobのジョブを作成する[参照](https://railsguides.jp/active_job_basics.html#%E3%82%B8%E3%83%A7%E3%83%96%E3%82%92%E4%BD%9C%E6%88%90%E3%81%99%E3%82%8B-%E3%82%B8%E3%83%A7%E3%83%96%E3%82%92%E4%BD%9C%E6%88%90%E3%81%99%E3%82%8B)

`$ bundle exec rails g job generate_ticket`

すると、app/job配下に`application_job.rb`と`generate_ticket_job.rb`が作成される

ジョブを実行すべきタイミングになると`perform`メソッドが呼び出されるため、このメソッドにジョブで実行したい処理を記述していく

```
# app/job/application_job.rb

class ApplicationJob < ActiveJob::Base
end
```

```
# app/job/generate_ticket_job.rb

class GenerateTicketJob < ApplicationJob
  queue_as :default

  def perform(*arg)
    p "Hello Active Job"
  end
end
```

もしsidekiqなどのアダプタを使用せずに同期処理を行う場合は以下のようにジョブを実行できる

`GenerateTicketJob.perform_later`...キューが空き次第実行する(引数なし)

`GenerateTicketJob.perform_later some_arg`...実行時引数some_argを渡してキューが空き次第実行する

`GenerateTicketJob.set(wait: 5.second).perform_later`...5秒後に実行する

## sidekiqが動作することを確認

実行の流れとしてはこんな感じ

`Railsからsidekiqがキューをpush => Redis(キューを保存) => SidekiqがRailsに非同期でキューを実行させる`

sidekiqが動作していること、Redisが動作していることを確認の上、Rails serverを再起動させる。そして`Hello Active Job`が表示されたら正常に動いていることがわかる。

なお、sidekiqで動作したことを確認するためにも以下のように実行したジョブが増えていることを確認する方法もある

```
$ rails c -s
irb> require 'sidekiq/api'
#=> false
irb> Sidekiq::Stats.new.processed
#=> 400
irb Sidekiq::Stats.new.processed # 実行が完了すると数が増える
#=> 401
```

メソッドについて

|メソッド|役割|
|processed|実行完了数|
|failed|実行失敗数|
|scheduled_size|予定キュー内ジョブ数|
|retry_size|リトライキュー内ジョブ数|
|dead_size|デッド状態(*1)のジョブ数|
|processes_size|実行中のジョブ数|
|default_queue_latency|デフォルトキューの遅延時間(*2)|
|workers_size|Workerの数|
|enqueued|全キュー内のジョブ数(リトライキューと予定キューは除く)|

*1...ジョブ実行時に例外が発生するとリトライ数(デフォルトでは25回)だけリトライした後デッド状態となる

*2...キュー内の最初のジョブがキューに入るまでの時間

### perform_async

`perform_async`メソッドを使うことで、メソッドの引数に渡された値をJSONへ変換してRedisに保存することができる

しかし、複雑なオブジェクトの場合はJSONに変換されないことや、仮にキューがバックアップされて引用したオブジェクト側を変更した場合にどうなるかなどを考えると、引数としてはインスタンスを渡さずにIDを渡す方がベストプラクティスとのこと[best practice](https://github.com/mperham/sidekiq/wiki/Best-Practices)

```
# MISTAKE

quote = Quote.find(quote_id)
SomeWorker.perform_async(quote)
```

```
# BEST PRACTICE

quote = Quote.find(quote_id)
SomeWorker.perform_async(quote_id)
```

## Global ID

ActibeJobの`perform`メソッドにモデルを引数として渡す場合はクラスとIDを指定する必要はなく、簡潔に書くことができる

```
class TrashableCleanupJob < Application
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
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

上記の設定により`http://localhost:3000/sdekiq`にアクセスすることで、sidekiqのダッシュボードに入ることができる。このダッシュボード内で、実行中のジョブを確認したり・停止したり、キューにあるジョブを確認したり・削除したり、リトライキュにあるジョブを確認したり・削除したりできる

sidekiqのダッシュボードはsinatoraで動作しているため、ダッシュボードにアクセスしてからRailsに戻ると、セッションが失効し、ログオフした状態になってしまう。この問題を解決するために、RailsとRedisと2つのサーバーを起動しておけばいいとのこと

<br>

[miketaさん](https://github.com/miketa-webprgr/TIL/blob/master/11_Rails_Intensive_Training/12_issue_note.md)

[Ruby on Rails の Active Job と SideKiq でバックグラウンドジョブをキューイングして実行する](https://qiita.com/tatsurou313/items/d3664f8dda05dcd12d56)
