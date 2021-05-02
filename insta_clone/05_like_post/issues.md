# 05_like_post

## モデルの設計

```
likes:
 user: refenrece
 post: reference

# いいねが2回できないようにするためのユニーク制約
# user_idとpost_idの組み合わせが同じにならないようにしている
index [:user_id, :post_id], unique: true
```

```
# models/like.rb

belongs_to :user
belongs_to :post

# 1ユーザーが、1つのpostに対していいねが2回できないようにするためのバリデーション
validates :user_id, uniqueness: { scope: :post_id }
```

```
# models/post.rb

# 投稿に付いたいいねをpost.likesで取得できる
# post.likes.countで投稿についたいいね数を取得できる
has_many :likes
belongs_to :user
```

```
# models/user.rb

# ユーザーが付けたいいねを取得
has_many :likes

# ユーザーがいいねを付けた投稿を取得
has_many :like_posts, through :likes, source: :post

has_many :posts
```

`has_many :like_posts, through :likes, source: :post`とすることで、ユーザーがいいねした投稿を自分のプロフィール画面などに表示させたい場合などに`user.like_posts`と呼び出すことで取得することができるようになる。

`through`オプションを使うことで、中間テーブルであるlikesテーブルのpost_idを通して、postへと関連付けができる

### throughオプションを使用する際の注意点

throughtで使うモデルは、`必ず先に関連付けを行っていなければならない`。今回の場合だと、likesを先に関連付ける必要がある

`source`には、命名したモデル名の参照元となるモデル名を記述する。

`has_many :<好きなモデル名>, throug: :<中間テーブル>, source: :<命名したモデルの参照元となるモデル名>`

つまり、今回でいうと...

<好きなモデル名> = like_posts

<中間テーブル> = likes

<命名したモデルの参照元となるモデル名> = post

<br>

## like, unlike, like? メソッドの実装

likeメソッドは、いいねをcreateするような・like_postsの配列に追加するようなイメージの処理になる

unlikeメソッドは、likeメソッドの逆で、いいねを取り消すためのメソッド。その投稿をlike_postsから削除するようなイメージ

like?メソッドは、その投稿にいいね済みかどうかを判定するためのメソッド。like_postsの中にその投稿があるかどうかを判定するイメージ

以上を踏まえて、今回はmodels/user.rb内に実装していく(主語がどれもuserのため)

```
# models/user.rb

def like(post)
 like_posts << post
 # [miketaさんのgithub](https://github.com/miketa-webprgr/instagram_clone/pull/5/commits/afc053b03bcf7db3d48fa6e7e5ac27babeb4bac4)
end

def unlike(post)
 like_posts.destroy(post)
end

def like?(post)
 like_posts.include?(post)
end
```

<br>

### push と <<

Rubyで配列に使う`push`は、配列に要素を追加するメソッド

ActiveRecord::Relationで使う`<<`は、配列っぽく扱えるActiveRecordのメソッド

RubyとRailsにおいては、両者は異なるが、ActiveRecord(Rails)において`push`は`<<`のaliasとして設定されている

また、`<<`は、`push`,`append`,`concat`のエイリアスでもある[ActiveRecord](https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C)

[miketaさんのgithub](https://github.com/miketa-webprgr/instagram_clone/pull/5/commits/afc053b03bcf7db3d48fa6e7e5ac27babeb4bac4)

<br>

### appendメソッド

`append`メソッドは、`<<`のエイリアス

```
[0.1.2].append(3) #=> [0,1,2,3]
```

<br>

### prependメソッド

`prepend`メソッドは、`unshift`メソッドのエイリアス

```
[0.1.2].unshift(3) #=> [3,0,1,2]
```

<br>

[Rails の便利なメソッド（Array 編）](https://qiita.com/pekepek/items/55ac235a36d15ede0d90#append-prepend)

<br>

### concatメソッド

`concat`メソッドは、引数の配列を自身の配列の末尾に破壊的に連結させるメソッド

```
array = [1,2]
a = [3,4]
array.concat a
p array #=> [1,2,3,4]
```

[リファレンスマニュアル](https://docs.ruby-lang.org/ja/latest/method/Array/i/concat.html)

<br>

## ルーティング

resources postsにネストさせる

いいね機能は、いいねするか、取り消すかの2アクションが必要なため、onlyオプションを指定

また、posts_controllerに`like_posts`アクションを定義し、ユーザーがいいねした投稿を取得できるようにするため、`collection`オプションを使用する。

こうすることで、like_posts_posts_pathが生成され、getメソッドでリクエストを投げれる

[collection](https://qiita.com/k152744/items/141345e34fc0095217fe)

```
resources :posts, shallow: true do
 resources :comments
 resources :likes, only: [:create, destroy]
 collection do
   get :like_posts
 end
end
```

```
post_likes POST   /posts/:post_id/likes(.:format)            likes#create
      like DELETE /likes/:id(.:format)                       likes#destroy
like_posts_posts GET    /posts/like_posts(.:format)          posts#like_posts
```

<br>

## destroy in likes_controller

```
def destroy
  @post = Like.find(params[:id]).post
  current_user.unlike(@post)
end
```

```
# いいねを取り消す際のURL

/likes/31(仮)
```

ここの記述について

生成されるURLに含まれているlike.idをparamsから取得し、そのlikeに紐づいているpostを@postに格納

その投稿に紐づくいいねを取り消す流れ
