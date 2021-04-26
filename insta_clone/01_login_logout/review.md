# 復習ポイント

<br>

## git flowとは

`brew install git-flow`にてHomebrewにインストール

`$ git flow init (全部EnterでOK）`

`$ git push --all （これでmasterとdevelopが一気にリモートにプッシュされる）`

`$ git flow feature start 01_hogehogebranch`

`$ git flow feature finish 01_hogehogebranch`...feature/01_hogehogebranchブランチを削除、変更点をdevelopブランチに反映させる。

`$ git push origin develop`


## turbolinkとは

turbolinksとは、画面遷移を高速化させるライブラリのこと。画面全体を更新するのではなく、画面の一部だけを更新されることで高速化を実現させる

リンクを生成するa要素のクリックをフックにして、移動先のページをAjaxで取得する。

取得ページのデータが遷移前のページと同じものがあれば、再利用し、title, body要素を置き換えて表示させる

turbolinksが原因で、JavaScriptが正しく動作しない

具体的には、ページ読込を起点としたJavaScriptが機能しなくなる。

通常であれば、ページが読み込まれたタイミングでloadイベントが発生するが、Turboliksによって画面が切り替わった場合は、loadイベントは発生しなくなるから

また、jQuery.readyやDOMContentLoadedを使用しても、ページ切り替え時にそのイベントは発生しない

loadイベントを発生させたい場合は、Turbolinksを無効化させる必要がある

[参考1](https://www.ryotaku.com/entry/2019/01/15/213420)
[参考2](https://kossy-web-engineer.hatenablog.com/entry/2018/11/29/093958)

<br>

## slimとは

Slimとは、Ruby製のテンプレートエンジン。HTMLタグを短く書くことが出来る

### 導入方法


下記gemをインストール

```
# Gemfile

gem 'slim-rails'
gem 'html2slim'
```

`bundle exec erb2slim app/views/layouts/ --delete`コマンドでlayouts配下にあるerbファイルを削除し、slimファイルを作成する

### コメント

`/`を付けることでコメントすることができる

### パイプ `|`

長いテキストなど、改行してテキストを書く際には、`パイプ(|)`を使用する

パイプを使うと, Slim はパイプよりも深くインデントされた全ての行をコピーし、エスケープされ、`p`タグで囲われる

```
# .slim

p
 |
   ほげほげ　ふがふが
   ふがふが　ほげほげ

# タグに改行されたテキスト

<p>
 ほげほげ　ふがふが
 ふがふが　ほげほげ
</p>

# パイプの後ろに書いてもOK

p 
 | ほげほげ　ふがふが
```

[reference](https://github.com/slim-template/slim/blob/master/README.jp.md)
[reference](https://qiita.com/pugiemonn/items/b64171952d958dc4d6be#slim%E3%81%A8%E3%81%AF)

<br>

## sorceryとは

ログイン機能を手軽に実装できるgem

4年以上更新されていないため、RSpecのsystem specが使えないことに注意

### 導入

`gem 'sorcery'`にて、インストール

`bundle exec rails g sorcery:install`コマンドで諸々必要なファイルが作成される

### 注意

自分だけかもしれないが、自動で作成されたマイグレーションファイルを少しいじる必要があった

デフォルトでは、Userテーブルを作成することになっていたので、rails db:migrateはできるが、その後ユーザー作成時にエラーが発生

そのため、一度rollbackして、usersに変更することで、想定通りの挙動になった

### 使用できるメソッド(公式抜粋)

```
require_login # This is a before action
login(email, password, remember_me = false)
auto_login(user) # Login without credentials
logout
logged_in? # Available in views
current_user # Available in views
redirect_back_or_to # Use when a user tries to access a page while logged out, is asked to login, and we want to return him back to the page he originally wanted
@user.external? # Users who signed up using Facebook, Twitter, etc.
@user.active_for_authentication? # Add this method to define behaviour that will prevent selected users from signing in
@user.valid_password?('secret') # Compares 'secret' with the actual user's password, returns true if they match
User.authenticates_with_sorcery!
```

[reference](https://github.com/Sorcery/sorcery)
[reference](https://qiita.com/d0ne1s/items/f6f8f4cc7ae6eea069fb)

<br>

## rubocopとは

Rubocopとは、コーディング規約に沿っているかを確認できる「静的コード解析ツール(コーディングチェックツール)」のこと。ソースコードの品質を下げないために使われるRubyのコーディングチェックツール

- チェック出来る項目(他にもいっぱいあるけど)
 - インデント
 - 文字数の長さ
 - メソッド内の行数
 - 条件式の見やすさ
 - ソースコードの複雑度
 - ハッシュなどの末尾にあるカンマの有無

### 導入

```
# Gemfile

group :development do
 gem 'rubocop', require: false
 gem 'rubocop-rails'
end
```

rubocopは、ターミナル等で使用するため、bundlerによってアプリ側に自動で読み込む必要がないため、`require: false`にしている

### 設定ファイルについて

`$ bundle exec rubocop --auto-gen-config`コマンドで設定ファイルを作成

`.rubocop.yml`とは、独自のコーディング規約を設定するファイル。`inherit_from: .rubocop_todo.yml`を記述して、読み込む必要がある

`.rubocop_todo.yml`とは、規約を無視するための設定ファイル。現状は対応できない規約を一時的にスルーするための設定が書かれたファイル。そのため、最終的にはこのファイルの中身を空にすることが望ましい

### RuboCopの設定ファイルを変更

現状では、rubocopコマンドで出た警告をすべてスルーするという内容の記述が書かれているため、警告が1つも出ないため、.rubocop.ymlを編集する

```
inherit_from: .rubocop_todo.yml

# 追記した規約ファイルの読込
require:
 - rubocop-rails

# This file overrides https://github.com/bbatsov/rubocop/blob/master/config/default.yml

AllCops:
 # 除外ファイル
 Exclude:
   - 'vendor/**/*'
   - 'db/**/*'
   - 'bin/**/*'
   - 'spec/**/*'
   - 'node_modules/**/*'
 # どのCOPに引っかかったのかを表示する
 DisplayCopNames: true
Rails:
 Enabled: true

# ブロックが正しく記述されているかのCOP
Layout/MultilineBlockLayout:
 # 除外
 Exclude:
   - 'spec/**/*_spec.rb'

Metrics/AbcSize:
 Max: 25

Metrics/BlockLength:
 Max: 30
 Exclude:
   - 'Gemfile'
   - 'config/**/*'
   - 'spec/**/*_spec.rb'
   - 'lib/tasks/*'

Metrics/ClassLength:
 CountComments: false
 Max: 300

Metrics/CyclomaticComplexity:
 Max: 30

Metrics/LineLength:
 Enabled: false

Metrics/MethodLength:
 CountComments: false
 Max: 30

Naming/AccessorMethodName:
 Exclude:
   - 'app/controllers/**/*'

# 日本語でのコメントを許可
Style/AsciiComments:
 Enabled: false

Style/BlockDelimiters:
 Exclude:
   - 'spec/**/*_spec.rb'

# モジュール名::クラス名の定義を許可
Style/ClassAndModuleChildren:
 Enabled: false

# クラスのコメント必須を無視
Style/Documentation:
 Enabled: false

# 文字リテラルのイミュータブル宣言を無視
Style/FrozenStringLiteralComment:
 Enabled: false

Style/IfUnlessModifier:
 Enabled: false

Style/WhileUntilModifier:
 Enabled: false

Bundler/OrderedGems:
 Enabled: false
Rails/OutputSafety:
 Enabled: true
 Exclude:
   - 'app/helpers/**/*.rb'

Rails/InverseOf:
 Enabled: false

Rails/FilePath:
 Enabled: false
```

### ファイルの自動修正

`--auto-correct`オプションを使うことで、警告している箇所をある程度自動修正してくれる

または`-a`

Rubocopではどうやって修正したら良いかわからない箇所はスキップするため、ある程度

Rubocopが自動修正できた箇所は`Corrected`と表示される

`bundle exec rubocop`コマンドで、最終的に以下のような状態になれば、ソースコードの品質が保たれているといえる

```
$ rubocop
Inspecting 19 files
...................

19 files inspected, no offenses detected
```

まだまだ全然理解できてない。

[rubocop.org](https://rubocop.org/)
[Railsの品質を上げるRuboCopとは？インストールや使い方を紹介！](https://kitsune.blog/rails-rubocop)
[rubocopとは？](https://qiita.com/freestylehh46/items/f8dae4b962df681ed2ad)
[rubocop のしつけ方](https://blog.onk.ninja/2015/10/27/rubocop-getting-started)

<br>

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

<br>

## annotateとは

各モデルのスキーマ情報をファイルの先頭or末尾にコメントとして書き出すgem。いちいちschemaを見に行かなくて済む。

さらに、`config/routes.rb`にルーティング情報を書き出してくれる機能もあるため、わざわざrails routesしなくて済む！

### 導入

`gem 'annotate'`

`$ bundle exec rails g annotate:install`を実行することで、`lib/tasks/auto_annotate_models.rake`が作成される

`bundle exec rails db:migrate`することで、各モデルファイルにスキーマ情報がコメントで追記される

### 手動実行

`bundle exec annotate`

`bundle exec annotate --routes`  ルーティング情報を書き出す

`bundle exec annotate --exclude fixtures`　　fixturesには書き出さない
　
`bundle exec annotate --exclude tests,fixtures,factories,serializers`　modelファイルだけに書き出す

[annotateの使い方](https://qiita.com/kou_pg_0131/items/ae6b5f41c18b2872d527)

<br>

## i18nとは

国際化・多言語化を意味する`initernationalization`を短縮したもの。

### デフォルトの言語を日本語にする方法

`gem 'rails-i18n', '~> 5.1'`

config/application.rbを編集

```
# config/application.rb

require_relative 'boot'
requrie 'rails/all'

Bundler.requrie(*Rails.group)

module APP_NAME
 class Application < Rails::Application
   config.time_zone = "Tokyo"
   config.active_record.default_timezone = :local

   # デフォルトのロケールを日本語に設定
   config.i18n.default_locale = :ja

   # i18nの複数ロケールファイルが読み込まれるようpathを通す
   confg.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
 end
end
```

最後に、`config/locales`配下にロケールファイルを置けば設定完了

config/locales以下にあるすべての.rbファイルと.ymlファイルは、自動的に 訳文読み込みパスに追加される

### メソッド

以下のロケールファイルがある場合

```
# config/locales/ja.yml
ja:
 fruits:
   apple: "りんご"
   orange: "みかん"
 time:
   current: "%Y年%m月%d日"
```

`tメソッド`を使うと、以下のように記述する

```
= t("fruits.apple")
= t("fruits.orange")
```

`l(エル)メソッド`は、日付や時刻を表す際に使用するメソッドで、以下のように記述する

```
= l(Time.currnet)
```

`model_name.human`や`human_attribute_name({attr_name})`メソッドも、modelの日本語化を設定することで使用できる

[Railsガイド](https://railsguides.jp/i18n.html)
[Railsのi18nによる日本語化対応](https://qiita.com/shimadama/items/7e5c3d75c9a9f51abdd5)
[RailsのI18nの紹介](https://qiita.com/tiktak/items/a70ef7940fa4710f37cb)

<br>

## database.yml 

`&(アンカー)<アンカー名>`とは、名前を付ける機能

`*<アンカー名>`とは、エイリアスで、指定したアンカーを呼び出す機能


### credentials.yml.encを使って環境変数の設定

`$ EDITOR="vi" bin/rails credentials:edit`

```
# credentials.yml.enc

db:
 username: sample_user
 password: sample_password
```

```
# database.yml

default: &default
 username: <%= Rails.application.credentials.db[:username]%>
 password: <%= Rails.application.credentials.db[:password]%>
```

のようにして、credentialsに設定した環境変数を取り出す

[Railsのdatabase.ymlについてなんとなく分かった気になっていた記法・意味まとめ](https://qiita.com/terufumi1122/items/b5678bae891ba9cf1e57)
[database.yml](https://qiita.com/ryouya3948/items/ba3012ba88d9ea8fd43d)
[database.ymlのパスワード管理方法2パターン](https://qiita.com/d01masatooo11/items/b780dce36a61ad95a08b)

<br>

## schema.rbとは

`rails db:migrate`の実行結果が反映されるファイル。基本的にこのファイルは閲覧するだけで、直接編集してはいけない。変更したい場合は、migrationファイルを変更すること

[RailsのDBとmigrationファイルとschemaの関係](https://qiita.com/kakiuchis/items/2ed1604557ee29bbcbf7)

<br>

## config/application.rbとは

アプリ全体の設定を記述するファイル。タイムゾーンの設定や、デフォルトで使用するロケール、アプリ起動時に読み込むディレクトリなどを指定する

```
module InstaClone
 class Application < Rails::Application
   config.generators.system_tests = nil

   config.generators do |g|
     g.skip_routes true
     g.assets false
     g.helper false
   end
 end
end
```
の、ように記述することで、generateコマンド時に生成されるファイルを制限することができる(ルーティング、JS、CSS、テストが自動生成されない)

### Time.currentとTime.nowの違い

`Time.current`とは、Railsの独自のメソッドで、TimeWithZoneクラスを使用している。`config.time_zone`で設定したタイムゾーンを元に現在時刻を取得する

`Time.now`とは、Rubyのメソッドで、Timeクラスを使用している。環境変数`TZ`の値、無ければシステム(OS)のタイムゾーンを元に現在時刻を取得する

[application.rbの初期設定](https://blog.cloud-acct.com/posts/u-rails-applicationrb-settings/)

<br>

## yarnとは

JavaScriptのパッケージマネージャーで、npmと互換性があり、`package,.json`が使えるもの

### yarnのインストール

`$ brew install yarn`コマンドを実行しインストール

`yarn init`実行にてpackage.jsonを生成する

### ご利用方法

`yarn add <パッケージ名>`にて、インストールしたいパッケージをpackage.jsonに追加する

`yarn`コマンドでpackage.jsonに記載されたモジュールをインストールする

`yarn remove <パッケージ名>`コマンドでパッケージのアンインストールができる

つまり、イメージとしては、こんな感じ？

`$ yarn add <パッケージ名>` == `Gemfileへの追記`

`$ yarn` == `bundle install`

[yarnとは](https://qiita.com/akitxxx/items/c97ff951ca31298f3f24)
[yarnチートシート](https://qiita.com/morrr/items/558bf64cd619ebdacd3d)