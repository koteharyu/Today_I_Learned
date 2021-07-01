# docker * heroku production

herokuへの登録・クレジットカードの登録・heroku cliのインストール, herokuとheroku containerへのログインは済んだものとする

## for M1 mac

herokuは、x86アーキテクチャを採用しているため、x86向けのimageを作成する必要があるとのこと。

よくわかっていない

[同様のエラーが出たがまだ解決できていない](https://zenn.dev/daku10/articles/m1-heroku-container-trouble-exec-format-error)

[iterm2はrosettaを使用](https://qiita.com/nagatak/items/fc7a2cc39d8fb1826b32)

## create heroku app

```
heroku create rails-docker-hryau6
```

アプリ名は、世界で唯一の名前にする必要がある

## add DB and config

herokuにおけるmysqlのアドオンは基本的に有料だが、`cleardb:ignite`は無料プラン

```
heroku addons:create cleardb:ignite -a rails-docker-hryau6
```

`-a`...--application

環境変数の設定

```yml
production:
  <<: *default
  database: <%= ENV['APP_DATABASE'] %>
  username: <%= ENV['APP_DATABASE_USERNAME'] %>
  password: <%= ENV['APP_DATABASE_PASSWORD'] %>
  host: <%= ENV['APP_DATABASE_HOST'] %>
```

本番環境の接続先をherokuの接続先にしたいため環境変数に設定する。

`heroku config -a rails-docker-hryau6`...heroku内におけるアプリのDBへの接続情報が出てくる

それがこんな感じ

`CLEARDB_DATABASE_URL: mysql://bb539140cdc716:5e427864@us-cdbr-east-04.cleardb.com/heroku_33b742c0c6d11f3?reconnect=true`

```
CLEARDB_DATABASE_URL:  mysql://`bb539140cdc716`:`5e427864`@`us-cdbr-east-04.cleardb.com`/`heroku_33b742c0c6d11f3`?reconnect=true
```

1. ユーザー名
2. パスワード
3. ホスト名
4. データベース名

以上の情報を環境変数に設定する

```
$ heroku config:add APP_DATABASE_USERNAME='bb539140cdc716' -a rails-docker-hryau6
$ heroku config:add APP_DATABASE_PASSWORD='5e427864' -a rails-docker-hryau6
$ heroku config:add APP_DATABASE_HOST='us-cdbr-east-04.cleardb.com' -a rails-docker-hryau6
$ heroku config:add APP_DATABASE='heroku_33b742c0c6d11f3' -a rails-docker-hryau6
```

## 本番環境用にDockerfileを編集

top directoryに`start.sh`ファイルを作成する

```sh
#!/bin/sh

if [ "${RAILS_ENV}" = "production" ]
then
    bundle exec rails assets:precompile
fi

bundle exec rails s -p ${PORT:-3000} -b 0.0.0.0
```

Dockerファイルを以下のように変更

```docker
FROM ruby:3.0.0

ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

COPY start.sh /start.sh
RUN chmod 744 /start.sh
CMD ["sh", "/start.sh"]
```

RAILS_ENVがproductionであれば、start.shをコピーし、権限を変更し、CMD ["sh", "/start.sh"]を実行する流れ

`$ heroku config:add RAILS_SERVE_STATIC_FILES='true'`を実行し、環境変数を追加する。この設定により、本番環境にて`assets:precompile`が実行されるようになる

## Boot Timeout

`https://tools.heroku.support/limits/boot_timeout`にアクセスし、対象のアプリのタイムアウトを120秒に変更する。ポート番号をバインドする際に60秒じゃ心許ないため。

`docker-compose down`...ローカルで起動中のコンテナを停止させるコマンド

## Dockerイメージのビルド・リリース

`heroku container:push web -a rails-docker-hryua6`...引数`web`を渡して、heroku containerにイメージをビルドする

heroku containerへのビルドが完了したら次に実際にそのイメージを使用できるようにするため開放する必要がある

`heroku container:release web -a rails-docker-hryau6`...heroku containerからherokuへ移動させるイメージ

`heroku run bundle exec rake db:migrate RAILS_ENV=prodiction -a rails-docker-hryua6`...heroku内のアプリに対する操作は`heroku run`。本番環境のDBをマイグレートするコマンド

## 補足

`heroku config:add RAILS_LOG_TO_STDOUT='true' -a rails-docker-hryau6`...デフォルトのログが少ないため、たくさん表示させるように環境変数を設定

`heroku logs -t -a rails-docker-hryua6`...ログを確認するコマンド
