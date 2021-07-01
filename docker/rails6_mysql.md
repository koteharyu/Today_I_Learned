# m1 * docker * rails6 * mysql

M1macと自分の知識不足のおかがでローカルでの環境構築にかなり苦戦したため、思い切ってdockerに入門して見ようと思った。

今回は、あの最初のページまで表示できるところまでをまとめていく

## 完成図

```
.
  Dockerfile
  Gemfile
  Gemfile.lock
  decker-compose.yml
  mysql-condf
    default_authentication.cnf
```

## 作業ディレクトリの作成

まずは、任意の作業ディレクトリを作成する。今回は`rails-docker`

```terminal
$ mkdir rails-docker
$ cd rails-docker
```

## Dockerfile

次に`Dockerfile`を作成する

Dockerfileとは、Dockerで作成するコンテナイメージを管理するためのファイルである。 コンテナイメージは、予め用意されたコンテナイメージに、ファイルをコピーしたり、直接的な編集を行って、イメージを保存することでも作成できる。 Dockerfileは、そうした変更をファイルに記述したものである。

```dockerfile
FROM ruby:3.0.0
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
```

44~47行目...yarnというjsのパッケージマネージャーをdockerコンテナ内部にインストールするための記述。後々Webpackerを導入するために必要となる

## Gemfile, Gemfile.lock

```
$ touch Gemfile
$ touch Gemfile.lock
```

```Gemfile
source 'https://rubygems.org'
gem 'rails', '6.0.3.4'
```

Gemfile.lockは空の状態でOK。なぜなら、bundle installされたタイミングで、実際にインストールしたGemのリストとバージョンが自動的に記載されるファイルだから。

Gemfile.lockの用途は、別のサーバーや他の開発者のPCといった別環境で同じRailsアプリを動かす際、同じGemをインストールするために使用される。これは、依存関係も含めて何がインストールされたかを全て記載しているため可能となる。

## docker-compose.yml

`docker-compose.yml`...Dockerで複数のコンテナ設定をまとめて起動させるためのファイル。今回は`web`と`db`がそれに当たる

```yml
version: '3'
services:
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/app
    ports:
      - 3000:3000
    depends_on:
      - db
    tty: true
    stdin_open: true
  db:
    image: mysql@sha256:dce31fcdd15aaedb5591aa89f19ec37cb79981af46511781fa41287d88ed0abd
    volumes:
      - db-volume:/var/lib/mysql
      - ./mysql-confd:/etc/mysql/conf.d
    environment:
      MYSQL_ROOT_PASSWORD: password
volumes:
  db-volume:
```

注意点として、MYSQLのimage指定方法をタグではなく、`DIGEST欄のID`を指定しないとエラーになること。もしかしたら今後解消されるかもしれない

`./mysql-confd:/etc/mysql/conf.d`...MYSQLのデフォルトの認証形式である、`caching_sha2_password`から`mysql_native_password`に変更するファイルのこと。次のステップでこちらのファイルを作成する

また、docker-composeを使用する場合、docker-compose.ymlが置いてあるディレクトリ名が、コンテナ名やvolume名の接頭辞として使用されるため、ディレクトリ名の命名には気をつけるように。

## mysql_native_password

認証形式mysql_native_passwordに関する設定ファイルを作成する

```
# /mysql_confd/default_authentication.cnf

[db]
default_authentication_plugin= mysql_native_password
```

`db`...docker-compose.yml内に記載しているdbサービスのこと

## rails new

以上のファイルを構築後、Railsの開発環境を構築していく

`$ docker-compose run web rails new . --force --database=mysql`

webに関するdocker-composeを起動させるようなイメージ

上記コマンドで、いつものようなRailsに関するファイルが生成される

また、dockerfileに記載したように、bundle isntallとyarnに関するインストールが順番に行われたこともわかる

次に、Gemfileに追記されたGemのインストールや作成されたファイルをコンテナ内に取り込むために、もう一度ビルドを実行する

`$ docker-compose build`

## database.yml

ビルドが完了したら、Railsで使用するデータベースの設定ファイルを編集する

変更するのは、156,157行目

```yml
# MySQL. Versions 5.5.8 and up are supported.
#
# Install the MySQL driver
#   gem install mysql2
#
# Ensure the MySQL gem is defined in your Gemfile
#   gem 'mysql2'
#
# And be sure to use new-style password hashing:
#   https://dev.mysql.com/doc/refman/5.7/en/password-hashing.html
#
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: password
  host: db

development:
  <<: *default
  database: app_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: app_test

# As with config/credentials.yml, you never want to store sensitive information,
# like your database password, in your source code. If your source code is
# ever seen by anyone, they now have access to your database.
#
# Instead, provide the password as a unix environment variable when you boot
# the app. Read https://guides.rubyonrails.org/configuring.html#configuring-a-database
# for a full rundown on how to provide these environment variables in a
# production deployment.
#
# On Heroku and other platform providers, you may have a full connection URL
# available as an environment variable. For example:
#
#   DATABASE_URL="mysql2://myuser:mypass@localhost/somedatabase"
#
# You can use this database configuration with:
#
#   production:
#     url: <%= ENV['DATABASE_URL'] %>
#
production:
  <<: *default
  database: app_production
  username: app
  password: <%= ENV['APP_DATABASE_PASSWORD'] %>
```

`docker-compose up -d`コマンドでデタッチ(バックグラウンド)でコンテナを起動させる

`docker-compose ps`コマンドでweb, db２つのコンテナが起動していることを確認。以下のようになっていれば成功

```
$ docker-compose ps
     Name                   Command               State           Ports
--------------------------------------------------------------------------------
rails-docker_db_1    docker-entrypoint.sh mysqld      Up      3306/tcp, 33060/tcp
rails-docker_web_1   bundle exec rails s -p 300 ...   Up      0.0.0.0:3000->3000/tcp
```

## db:create

起動が完了したが、まだ開発環境用のデータベースが作成されていない状態のため、次のコマンドでデータベースを作成する

`$ docker-compose run web bundle exec rake db:create`

もし次のようなエラーになった場合は、以下の手順でエラーを解消しよう

```
Mysql2::Error::ConnectionError: Plugin caching_sha2_password could not be loaded: /usr/lib/aarch64-linux-gnu/mariadb19/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory
```

原因としては、MySQL8.0系の認証形式が、`caching_sha2_password`のままになっているため、本来ならdefault_authentication.cnfが変更してくれるはずだが...従って手動で認証形式を変更していく

```
$ docker exec -it rails-docker_db_1 bash
root@a503c7951a1f:/# mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.22 MySQL Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SELECT User, Host, Plugin  FROM mysql.user;
+------------------+-----------+-----------------------+
| User             | Host      | Plugin                |
+------------------+-----------+-----------------------+
| root             | %         | caching_sha2_password |
| mysql.infoschema | localhost | caching_sha2_password |
| mysql.session    | localhost | caching_sha2_password |
| mysql.sys        | localhost | caching_sha2_password |
| root             | localhost | caching_sha2_password |
+------------------+-----------+-----------------------+
5 rows in set (0.04 sec)

mysql> select @@version;
+-----------+
| @@version |
+-----------+
| 8.0.22    |
+-----------+
1 row in set (0.02 sec)

mysql> alter user 'root'@'%' identified WITH mysql_native_password by 'password';
Query OK, 0 rows affected (0.22 sec)

mysql> alter user 'root'@'localhost' identified WITH mysql_native_password by 'password';
Query OK, 0 rows affected (0.13 sec)

mysql> SELECT User, Host, Plugin  FROM mysql.user;
+------------------+-----------+-----------------------+
| User             | Host      | Plugin                |
+------------------+-----------+-----------------------+
| root             | %         | mysql_native_password |
| mysql.infoschema | localhost | caching_sha2_password |
| mysql.session    | localhost | caching_sha2_password |
| mysql.sys        | localhost | caching_sha2_password |
| root             | localhost | mysql_native_password |
+------------------+-----------+-----------------------+
5 rows in set (0.01 sec)
```

再度、`$ docker-compose run web bundle exec rake db:create`を実行すると正常にデータベースの作成ができるだろう。

`localhost:3000`にアクセスすればあの、安心感満載の見慣れたページが表示される
