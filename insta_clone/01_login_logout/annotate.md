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
