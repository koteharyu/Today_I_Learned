# 検索機能の復習

[これと合わせて...](https://github.com/koteharyu/TIL/blob/main/insta_clone/07_search/07_search.md)

### 要件

- 検索ワードを含み投稿一覧を取得
  - 複数ワードでの検索可
- 検索ワードを含むコメントがある投稿一覧を取得
- 検索ワードを含むユーザー名を持つユーザーの投稿一覧を取得

### エンドポイント

```rb
resources :posts do
  collection do
    get :search
  end
end
```

### フォームを作成

`posts/_search_form.html.slim`を作成

```rb
= form_with mode: search_form, url: posts_search_path, scope: :q, method: :get, local: true do |f|
  = f.search_field :body
  = f.search_field :comment_body
  = f.search_field :username
```

`scope: :q`...`:q`というパラメーターで送ることを指定

作成したこのファイルは、ヘッダーに表示させたいので`shared/_header`, `shared/_before_login_header`の両方でレンダリングさせる

```rb
= render 'posts/searcg_form', search_form: @search_form
```

### @search_formオブジェクトの生成

検索フォームはどのページでも表示されるヘッダー部分でレンダリングさせたので、`application_controller`内で@search_formオブジェクトを生成させれば辻褄が合う

```rb
class ApplicationController < ActionController::Base
  before_action :set_search_posts_form

  private

  def set_search_posts_form
    @search_form = SearchPostsForm.new(search_post_params)
  end

  def search_post_params
    params.fetch(:q, {}).permit(:body, :comment_body, :username)
  end
end
```

フォームにて`scope: :q`と指定しているため、ちゃんと`:q`を受け取る

`params.fetch(:q, {})`...qパラメーターが送られてこなかった場合、ActionController::ParameterMissingのエラーが発生しないようにするための記法。qパラメーターがなかった場合に、{}がデフォルト値として評価されるようになる。

### FormObject

`app/forms/search_posts_form.rb`ファイルを作成

`posts/_search_form.html.slim`で指定した`body`, `comment_body`, `username`属性を仮想的に作成する

```rb
class SearchPostsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attributes :body, :string
  attributes :comment_body, :string
  attributes :username, :string

  def search
    scope = Post.distinct
    scope = splited_bodies.map { |splited_body| scope.body_contain(splited_body) }.inject { |result, scp| result.or(scp) } if body.present?
    scope = scope.comment_contain(body) if comment_body.present?
    scope = scope.username_contain(body) if username.present?
    scope
  end

  private

    def splited_bodies
      body.strip.split(/[[:blank:]]+/)
    end
end
```

`splited_bodies`メソッド...複数ワードでの検索を行うために、`body`を空白で区切る

`strip`...文字列先頭と末尾の空白文字を全て取り除くメソッド

`split`...引数で指定した値で文字列を分割するメソッド

`split(/[[:blank:]]/)`...半角スペース・全角スペースで分割できる

### scopeを定義

検索ワードごとに投稿を絞り込むための`body_contain`, `comment_contain`, `username_contain`scopeを定義する

keywordはそれぞれの検索ワードに紐づく投稿を取得するため`models/post`に定義していく

```rb
scope :body_contain, -> (body) { where('body LIKE ?', "%#{body}%") }
scope :comment_contain, -> (comment_body) { joins(:comments).where('comments.body LIKE ?', "%#{comment_body}%") }
scope :username_contain, -> (username) { joins(:user).where('username LIKE ?', "%#{username}%") }
```

`joins`...引数で指定したテーブルを結合させるメソッド

#### 複数形と単数系の違い

なんでcommentsテーブルは`joins(:comments)`複数形で、usersテーブルは`joins(:user)`なのか

それは、アソシエーションが関係する

```rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
end
```

従って、複数形と単数系と区別して記述することになる

#### comments.body

postにも`body`カラムがあるため、コメントの`body`だと明示している

逆に`username`はどの結合したテーブル内でユニークなカラムのため`username`単体でOK
