# rails mysql2を使用する方法

## rails new

```
$ rails new <app_name> -d mysql

or

$ rails new <app_name> --database=mysql
```

## config/database.ymlについて

用語説明

```
adapter: 使用するデータベースの種類
encoding: 文字コード
reconnect:  再接続するかどうか
database: データベース名
pool: コネクションプーリングで使用するコネクションの上限
username: ユーザー名
password: パスワード
host: MySQLが動作しているホスト名
```

MySQLの場合は、ホスト名・ユーザー名・パスワードの指定が必要。ユーザー名はデフォルトで`root`になっているが、データベース作成の権限があるユーザーを予めMySQLに作成しておき、そのユーザー名とパスワードを指定しても良い

## MySQLのユーザー作成

1. rootユーザーでMySQLにログイン
  1. mysql -u root -p
  2. mysql -u root
2. 作業ユーザーを作成：ユーザー名とパスワードを指定`;`を最後に付ける
  1. `create user 'ユーザー名'@'localhost' identified by 'パスワード';`
3. select User,Host from mysql.user; コマンドで作成したユーザーを確認できる
4. grant all on *.* to 'ユーザー名'@'localhost';　コマンドでグローバルレベルでALL権限を付与する

## config/database.ymlファイルの書き換え

```
# config/database.yml

development:
 adapter: mysql2
 encoding: utf8
 reconnect: false
 database: [app_name]_development
 pool: 5
 username: 作成したユーザー名
 password: 作成したユーザーパスワード
 host: localhost

test:
 adapter: mysql2
 encoding: utf8
 reconnect: false
 database: [app_name]_test
 pool: 5
 username: 作成したユーザー名
 password: 作成したユーザーパスワード
 host: localhost

production:
 adapter: mysql2
 encoding: utf8
 reconnect: false
 database: [app_name]_production
 poot: 5
 username: 作成したユーザー名
 password: 作成したユーザーパスワード
 host: localhost
```

## bin/rails db:create

## 参考

[参考](https://qiita.com/reeenapi/items/9fc38c4f2f8186c78288)