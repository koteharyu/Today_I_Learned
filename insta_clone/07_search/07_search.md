# 07_search

## 要件

- 全ての投稿を検索対象とすること（フィードに対する検索ではない）
- 検索条件としては以下の三つとする
 - 本文に検索ワードが含まれている投稿
   - こちらに関しては半角スペースでつなげることでor検索ができるようにする。e.g.「rails ruby」
 - コメントに検索ワードが含まれている投稿
 - 投稿者の名前に検索ワードが含まれている投稿
- ransackなどの検索用のGemは使わず、フォームオブジェクト、ActiveModelを使って実装すること
- 検索時のパスは/posts/searchとすること

<br>

## ルーティング

```
# routes.rb

resources :posts, shallow: true do
 collection do
   get :search
 end
end
```

collectionオプションを使用することで、resoruces以外のpostsアクションにルーティングすることができる

生成されるルーティングは、`search_posts GET /posts/search(.:format)   posts#search`

<br>

## models/postsの編集

scopeで、`body_contain`を定義

この処理の目的は、検索フォームに入力された`word`に部分一致するpostsに絞り込むこと

```
# mdoels/posts

...
scope :body_contain, -> (word) { where('post.body LIKE ?', "%#{word}%") }
```

<br>

## ActiveModel::Model

## そもそもActiveModelって何をしてるの？

ActiveModelのおかげで非ActiveRecordモデルとやり取りが実現できる

(ちなみにActiveRecordは、モデルに相当するもので、ビジネスデータとビジネスロジックを表すシステムの階層) by[Railsガイド](https://railsguides.jp/active_record_basics.html)

ActiveModelは多くのモジュールを含むライブラリで、クラスで使用する既知の一連のインターフェースを提供する

by[Railsガイド](https://railsguides.jp/active_model_basics.html)

<br>

## includeメソッドの復習

`include`メソッドは、クラスやモジュールに他のモジュールをインクルード(Mix-in)する。引数には、モジュールを指定する(複数指定可能)。戻り値はクラスやモジュール自身

[Rubyリファレンス](https://ref.xaio.jp/ruby/classes/module/include)

つまり、他のモジュールをincludeすることで、そのモジュール内で使われているメソッドなどが使えるようになると言うこと

クラスの継承とも似ているが、、、includeの引数に指定できるのは、モジュールだけなので注意

- クラスを引き継ぎたい場合は、クラスの継承
- モジュールを引き継ぎたい場合は、include

<br>

## ActiveModel::Model

`include ActiveModel::Model`となっているので、ActiveModel::Modelと言うモジュールを引き継いでいることがわかった。

ActiveModel::Modelをincludeすることで、次の機能が使えるよになる

- モデルの調査
- 変換
- 翻訳
- バリデーション
- form_withやrenderなどのAction Viewヘルパーメソッド

[Railsガイド](https://railsguides.jp/active_model_basics.html#model%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB)

<br>

## いったん結論

普通にクラスとして定義したままの状態では、モデルに使える機能(バリデーションや、form_withなど)などが使えないため、ActiveModel::Modelをincludeする

<br>

[include ActiveModel::Modelとは](https://www.y-hakopro.com/entry/2019/10/15/204805)

<br>

## ActiveModel::Attributesについて

<br>

## 使用方法

ActiveModel::Modelと一緒にincludeする

```
class <任意なクラス>
 include ActiveModel::Model
 include ActiveModel::Attributes
end
```

こうすることで、クラスにActiveRecordのカラムのような属性を加えることができる

クラスメソッドattributeに属性名と型を渡すと、attr_accessorと同じように属性が使えるようになる

attributeをクラスの冒頭に並べておくと、「このクラスは何をパラメーターとして受け取るのか」を明示できるメリットもあるそう

以下のような、自作のクラスを作ったとする

```
class Book
 include ActiveModel::Model
 include ActiveModel::Attributes

 attribute :name, :string
 attribute :price, :integer, default: 100
 attribute :published_at, :datetime
end
```

`hash`を渡してインスタンスを生成することもできちゃう


```
book = Book.new({name: "harry potter", price: 200, published_at: "1997-06-12 12:30:45 UTC"})
book.class #=> Book
book.name #=> harry potter
book.price #=> 200
```

もし、nameに何も入れずにインスタンスを生成しようとすると、`ArgumentError`も出る

<br>

## メソッド

`attributes`メソッドは、定義されている属性全てをhashで取得できる

```
book.attributes
#=> {"name"=>"harry potter", "price"=>100, "published_at"=>1997-06-12 12:30:45 UTC}
```

<br>

`attribute_names`メソッドは、属性の名前のみ取得できる(Rails6以降のみ)

```
book.attribute_names
#=> ["name","price","publish_at"]
```

[ActiveModel::Attributesの使い方](https://qiita.com/dy36/items/617ae9af81b50baab98a)

<br>

## app/forms/search_posts_form.rbの作成

`ActiveModel::Model`,`ActiveModel::Attributes`をincludeし、それぞれのモジュールが提供するメソッドなどを使えるようにする

`ActiveModel::Attributes`の恩恵で、属性を追加することができるため、検索ようの`body`属性を追加

クラスメソッドである`search`を定義

```
class SearchPostsForm
 include ActiveModel::Model
 include ActiveModel::Attributes

 attribute :body, :string

 def search
   scope = Post.all
   scope = scope.body_contain(body) if body.present?
   scope
 end
end
```

恐らく、この引数`body`は、posts_controller側で取得する`params.require(:search).permit(:body)`のbodyのことかな??

<br>

## posts_controller.rb

```
# posts_controller.rb

def search
 @search_form = SearchPostsForm.new(params.require(:search).permit(:body))
 @posts = @search_form.search.includes(:user).page(params[:page])
end
```

ここの処理の流れ

`@search_form`と言うインスタンス変数に検索フォームから送られた値を格納する。`require(:search)`は後述するが、 検索フォームのform_withのscopeオプションにsearchを指定しているため

@search_formに対して、SearchPostsFormクラスメソッドである、`search`を呼び出し、N+1問題対策・ページネーションを行った上、インスタンス変数`@posts`に代入する

<br>

## view

まずは、検索フォームの実装から(必須箇所のみ抜粋)

```
# posts/_search_form.html.slim

= form_with model: search_form, url: search_posts_path, scope: :search, method: :get, local: true do |f|
 = f.search_field :body
 = f.submit "Search"
```

このパーシャルは、shared/_headerにレンダーする予定のため、インスタンス変数ではなく、ローカル変数をmodelに渡している

GETメソッドでsearch_posts_pathをHTTPリクエストするため、method: :getも指定

先に記述した通り、`scope: :search`とすることで、`name="search[:body]"`と言うHTMLを生成する

search_fieldに渡している(表現が正しいか微妙ではあるが)`body`は、`SearchPostsForm`クラスで追加した属性

このフォームによって生成されるHTMLを確認

[![Image from Gyazo](https://i.gyazo.com/48dd3ad77e9aa83d17c7b1625c6e6709.png)](https://gyazo.com/48dd3ad77e9aa83d17c7b1625c6e6709)

確かに、想定通りのHTMLが生成されていることがわかる

<br>

次に、`shared/_header`の編集

ここは、単純で、いつも通りrenderすればいいだろう

```
# shared/_header.html.slim

#navbarTogglerDemo02.collapse.navbar-collapse
 = render 'posts/search_form', search_form: @search_form
```

posts/_seach_formのことでも記述したように、ローカル変数を渡すことに注意

<br>

最後に検索結果を表示するページ

```
# posts/search.html.slim

.container
 .row
   .col-md-8.col-12.offset-md-2
     h2.text-center
       | 検索結果: #{@posts.total_count}件
     = render @posts
     = paginate @posts
```

renderとpaginateに渡している@postsは、searchアクションで生成されたインスタンス変数

`total_count`とは、kaminariが提供するメソッドの一つで、取得した全件数を表示する

他には、以下のようなメソッドが使える

```
オブジェクト.total_count #=> レコード総数
オブジェクト.offset_value #=> オフセット
オブジェクト.total_pages #=> 総ページ数
オブジェクト.per_page #=> 1ページごとのレコード数
オブジェクト.current_page #=> 現在のページ
オブジェクト.first_page? #=> 最初のページならtrue
オブジェクト.last_page? #=> 最後のページならtrue
```

[kaminari徹底入門](https://qiita.com/nysalor/items/77b9d6bc5baa41ea01f3)
[Kaminariの使い方まとめ](http://nekorails.hatenablog.com/entry/2018/10/15/005146)

