# post.body 以外にcomment.bodyとuser.nameで検索できるようにする

## 目次

1. ActiveModelについて
2. Routingについて
3. scopeについて
4. 半角空白での複数検索
5. searchメソッド
6. controllerについて
7. viewの実装

## ActiveModel

検索は既存のテーブルから該当するデータを探す行為なため、新規でテーブルを作成する必要は無い。また、検索は基本的にviewから検索するキーワード(パラメーター)をリクエストとして送信したいため、ActiveRecordの機能であるform_withメソッドが使えることがベストだろう。

そんな要望を叶えるのが、`ActiveModel`である。検索用のテーブルを作成しなくても、`ActiveModelのモデルmodule`をincludeすることで、ActiveRecordの機能を使えるようになる(つまり、form_withメソッドが使えるようになる)

[ActiveModel::Model](https://github.com/koteharyu/TIL/blob/main/insta_clone/07_search/ActiveModel::Model.md)

[ActiveModel::Attribtues](https://github.com/koteharyu/TIL/blob/main/insta_clone/07_search/ActiveModel::Attributes.md)

```ruby
# app/forms/search_form.rb

class SearchFrom
 include ActiveModel::Model
 include ActiveModel::Attributes

 attribute :post_body, :string
 attribute :comment_body, :string
 attribute :user_name, :string
end
```

`ActiveModel::Attributes`モジュールをincludeすることで、attributeメソッドが使えるようになる。このattributeメソッドとは、属性名と型を定義することができるメソッドで、SearchFromクラスに3つの属性を追加したことになる

## Routing

今回は、posts_controller内にsearchアクションを定義するため、以下のようなroutingになる

```rubu
# routes.rb

resources :posts, shallow: true do
 collection do
   get :search
 end
end
```

```ruby
$ bundle exec rails routes | grep search

GET    'posts/search', 'posts#search'
```

memberでなくcollectionを採用した理由は、検索時のリクエストに対してidを指定する必要がないと感じたから。[member & collection](https://github.com/koteharyu/TIL/blob/main/dust/member_conllection.md)

## scopeについて

今回の検索対象である"投稿本文"、"コメント"、"ユーザー名"はすべて`post`に関連づいているため、検索メソッドは`models/post`に記述すればいいだろう

```ruby
# models/post

scope :post_like, -> (post_body) { where('body LIKE ?', "%#{post_body}%")}
scope :comment_like, -> (comment_body) { joins(:comment).where('comments.body LIKE ?', "%#{comment_body}%")}
scope :user_like, -> (user_name) { joins(:user).where('user.name LIKE ?', "%#{user_name}%")}
```

ここで大事になるのが、`主語はPost`であること！ comment_like, user_likeに関して解説すると、`joins`メソッドを使ってPostモデルにそれぞれを連結される必要がある。

`join`することで、post.comments.body, post.user.nameのようにアソシエーションの恩恵を受けることが出来る

## 半角空白での複数検索

`POSIX 文字クラス`...`[:XXX:]`という文字クラスの表現方法がPOSIX文字ブラケットと呼ばれている。今回半角空白を判断するために`[:blank:]`というブラケットを使用する。[POSIX 文字クラス](https://docs.ruby-lang.org/ja/latest/doc/spec=2fregexp.html)

`[:blank:]`...スペースとタブの空白文字にマッチするブラケット

`stripe`メソッド...文字列先頭と末尾の空白文字をすべて取り除いた文字列を生成し返すメソッド。[reference](https://docs.ruby-lang.org/ja/latest/method/String/i/strip.html)

上記のテクニックを使うことで、検索フォームから"foo bar"という文字列が送られてきた場合、["foo", "bar"]と空白で文字列を区切ることができる

`"foo bar".stripe.split(/[[:blank:]]+/)`

## searchメソッド

posts_controllerのsearchアクションで呼び出す`search`メソッドを定義する

```ruby
# app/forms/search_form.rb

class SearchForm
 include ActiveModel::Model
 include ActiveModel::Attributes

 attribute :post_body, :string
 attribute :comment_body, :string
 attribute :user_name, :string

 def search
   scope = Post.distinct
   scope = split_post_body.map{ |word| scope.post_like(word) }.inject{ |result, scp| result.or(scp) } if post_body.present?
   scope = scope.comment_like(comment_body) if comment.body.present?
   scope = scope.user_like(user_name) if name.present?
   scope
 end

 private
 def split_post_body
   post_body.stripe.split(/[[:blank:]]+/)
 end
end
```

まず`distinct`メソッドを使い、postの重複したレコードを1つにまとめる。これにより、各レコードを一意にすることができる。

次に、検索ワードたちが配列として格納されている`split_post_body`を`map`メソッドを使い、変数`word`に１つずつ格納する。models/postで定義した`post_like`メソッドを使って引数wordに入った文字をscopeに代入されたpostのデータから検索している。検索でヒットしたデータがmapメソッドにより再度配列に格納される。この時、分けた検索条件ごとにデータも分かれているため、`inject`メソッドを使って、再度格納された配列を1つずつresultとscpに代入していき、orメソッドで分かれた条件を1つのデータ一覧としてまとめる。以下のようなイメージ

```
Post
.where(body: "foo")
.or(Post.where(body: "bar"))

SELECT "posts".*
FROM "post"
WHERE ("posts"."body" = "foo" OR "posts"."content" = "bar")
```

`scope.comment_like`, `scope.user_like`に関しては、present?であればその検索結果をscopeに代入する。結果的に、post, comment, userのどれかの検索結果を返すための一行が`scope`

## controllerについて

検索フォームはヘッダーに実装するため、どのページからでも使えるようにする必要がある。したがって今回は、`application_controller`でSearchFormクラスのインスタンスを生成させる。また検索フォームで入力されたparamsを受け取るためのメソッドも作成する

```ruby
# application_controller

class ApplicationController < ActionController::Base
 before_action :set_search_form

 def set_search_form
   @search_form = SeachForm.new(search_params)
 end

 def search_params
   params.fetch(:search, {}).permit(:post_body, :comment_body, :user_name)
 end
end
```

```
params.fetch(:search, {}).permit(:post_body, :comment_body, :user_name)
```

paramsに対して`fetch`メソッドを使用する。paramsに:searchキーが無い場合は、{}がデフォルト値として評価されるので、ActionController::ParameterMissingのエラーが起きないようにする。[参考](https://qiita.com/siman/items/c3918c6c29770805373d)

```
before_action :set_search_form
```

before_actionを指定することで、どのページにいても@search_formを生成してくれるようになる。

次にposts_controllerについて

```ruby
# posts_controller

def search
 @posts = @search_form.search.includes(:user).page(params[:page])
end
```

## viewの実装

まずは、`shared/header`に検索フォームをrenderさせる。上記で生成したインスタンス変数をseach_formに渡している

```ruby
# shared/_header

= render 'posts/search', search_form: @search_form
```

次に、`posts/_search`を実装する

```ruby
# posts/_search

= form_with model: search_form, scope: :search, url: search_posts_path, method: :get, class: 'form-inline my-2 my-lg-0 mr-auto', local: true do |f|
 .form-group
   = f.text_field :post_body, class: 'form-control mr-sm-2', placeholder: '本文'
   = f.text_field :comment_body, class: 'form-control mr-sm-2', placeholder: 'コメント'
   = f.text_field :user_name, class: 'form-control mr-sm-2', placeholder: 'ユーザー名'
```

`scope: :search`オプションを指定することで、`params[:search]`というパラメーターに格納しリクエストを送ることができる

最後に検索結果を表示させれば完成

```ruby
# posts/search

.container
 .row
   .col-md-8.col-12.offset-md-2
     h2.text-center
       | 検索結果: #{@posts.total_count}件
     = render @posts
     = paginate @posts
```
