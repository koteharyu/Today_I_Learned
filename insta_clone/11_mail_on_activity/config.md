# configというgemについて

`config`とは、Yaml形式で定数を管理することができるgemのこと。

## 導入

1. gem `cnofig`
2. bundle install
3. bundle exec rails g config:install
  1. config/initializers/config.rb
     1. configの設定ファイル
  2. config/settings.yml
     1. すべての環境で利用する定数を定義
  3. config/settings.local.yml
     1. ローカル環境のみで利用する定数を定義
  4. config/settings/development.yml
     1. 開発環境のみで利用する定数を定義
  5. config.settings/production.yml
     1. 本番環境のみで利用する定数を定義
  6. config/settings/test.yml
     1. テスト環境のみで利用する定数を定義

## 定数の定義

今回は、開発環境のみで利用する定数(URL)が必要なため、`config/settings/development.yml`内に定義していく。

```
# config/settings/development.yml

default_url_options:
 host: 'localhost:3000'
```

## 定数の確認方法

`Settings.default_url_options.host` #=> `'localhost:3000'`

`Settings.~`で定義した定数をControllerやView内で呼び出すことが出来る。

## ちなみに

`config/initializers/config.rb`を編集することで`Setting`という名前を変更できる
