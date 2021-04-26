## Redisとは

- キャッシュシステム、NoSQLの１つ
- キーとバリューの組み合わせ(KVS(キーバリューストア))を保存する
- さまざまなデータ型を持つ
 - String
 - List
 - Set
 - Sorted
 - Hash
- インメモリデータベースのため高速
 - すべてのデータをPCのメインメモリ上に展開しながら動作する
- 使いどころ
 - セッションなどの有効期限があるデータを扱う場合
 - ランキングデータなど重たいSQLを走らせる処理を行う場合

### RailsでRedisを使うメリット

- キャッシュ(Rails.cache)
- railsのセッションデータ
- 大量データ送信データ(Active Job)

などの一時的なデータ保存先としてRedisを利用することで、Railsを高速化できる

セッションの場合、Redisへ変更することでセッションハイジャックなどのセキュリティリスクを軽減できる

### Redisのインストール

'$ brew install redis'

'$ redis-server'でサーバーを起動させる。ローカル環境でRedisが使えるようになる

新規ターミナルにて`$ redis-cli`をコマンド実行で、Redisに接続できる

### Rails with Redis

`gem 'rails-redis'`

```
# config/application.rb

config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', { expires_in: 90.minutes }
```

### Redisでのセッション管理

`config/initializers/session_store.rb`を作成

```
# config/initializers/session_store.rb

Rails.application.config.session_store :redis_store, {
 servers: [
   {
     host: "localhost",  # Redisのサーバー名
     port: 6379,         # Redisのサーバーのポート
     db: 0,              # データベースの番号(0 ~ 15)の任意
     namespace: "session"  # 名前空間。"session:セッションID"の形式
   },
 ],
 expire_after: 90.minutes # 保存期間
}
```

'$ bin/rails c'

```
# console

redis = Redis.new(url: 'redis://localhost:6379/0')  # redisに接続

# セッションを保存しているデータベースを選択
redis.select 0
=> "OK

# Redisのセッションデータをクリア
redis.flushdb
=> "OK"

# キーの一覧を取得
redis.keys　
=> []

# Railsアプリからセッションに保存する操作をすると、redis.keysで内容を確認できる

# キーの一覧を取得
redis.keys
=> ["session:de7b87c3c487b3622c8a505c5e1ce69a", "session:7d12e83552cd35bb1e082480fbaee71d"]

# 保存データの中身を確認
redis.get "session:de7b87c3c487b3622c8a505c5e1ce69a"
=> "\u0004\b{\u0006I\"\u0010_csrf_token\u0006:\u0006EFI\"13u/SxOI4lsxx836eIAKj8yOnViUXGcAMF02kvvDQFB8=\u0006;\u0000F"
```

[Ruby on rails x Redisでsessionを高速化しよう!](https://qiita.com/keitah/items/61f5308424957257017e)
[Redisとは？RailsにRedisを導入](https://qiita.com/hirotakasasaki/items/9819a4e6e1f33f99213c)
[Redis](https://qiita.com/wind-up-bird/items/f2d41d08e86789322c71)
