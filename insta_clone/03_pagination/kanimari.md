# kaminari による ページネーション

ページネーションとは、レコード件数が一定数を超えた場合んに複数のページに分割して表示を行うこと

## 導入

```
# Gemfile

gem 'kaminari'
```

## 仕様

`params[:page]`で表示するページ番号がアクションに渡される

２ページ目を表示したい場合は、`?page=2`というリクエストパラメーターをURLにくっつけてGETする

特にページ番号を指定しない場合は、`params[:page]はnil`だが、1ページ目がしてされたと同様の挙動をする

デフォルトでは、１ぺージに表示する件数は`25件`

```
def index
 @posts = current_user.posts.page(params[:page])
end
```

## ページネーションの情報表示

`paginate`メソッドを使うことで、現在どのページを表示しているか・他のページに移動するためのリンクを表示できる

`page_entries_info`メソッドを使うことで、全データが何件なのかなどの情報を表示できる

```
= paginate @posts
= page_entries_info @posts
```

デフォルトのロケールがenなので日本語ロケールを設定する(毎回使いまわしたい)

```
# config/locales/kaminari.ja.yml

ja:
 views:
   pagination:
     first: "&laquo; 最初"
     last: "最後 &raquo;"
     previous: "&lsaquo; 前"
     next: "次 &rsaquo;"
     truncate: "&hellip;"
 helpers:
   page_entries_info:
     one_page:
       display_entries:
         zero: "%{entry_name}がありません"
         one: "１件の%{entry_name}が表示されています"
         other: "%{count}件の%{entry_name}が表示されています"
     more_pages:
       display_entries: "全%{total}件中%{first}&nbsp;-&nbsp;%{last}件の%{entry_name}が表示されています"
```

<br>

## bootstrapの適用

bootsrap4のテーマを適用する

```
$ bundle exec rails g kaminari:views bootstrap4
```

<br>

## 表示件数の変更

`perスコープ`を使ってコントローラーで指定する方法

```
def index
 @posts = current_user.posts.page(params[:page]).per(50)
end
```

or

`paginates_per`を使ってモデルで指定する方法

```
# models/post.rb

class Post < ApplicationRecord
 paginates_per 50
```

or

`defaul_per_page`を使ってkaminari全体としての表示件数を設定ファイルで指定する方法

```
$ bundle exec rails g kaminari:config

# config/initializers/kaminari_config.rb

kaminari.configure do |config|
 config.defaul_per_page = 50
end
```

<br>

わかったこと！

`paginate`メソッドを使いことで、`paginationクラス`が生成される

<br>

参照(現場Rails p.317)
