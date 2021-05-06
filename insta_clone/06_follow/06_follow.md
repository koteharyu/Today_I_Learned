# 06_follow

follow機能は、Relationship中間テーブルを通して、UserテーブルとUserテーブルが`多対多`の関係になることを意識

あるユーザーが他のユーザーをフォローする時や、あるユーザーが他のユーザーをフォロー解除する時、`Relationship`が作成されたり、削除されたりする

AがBをフォローしているが、BはAをフォローしていない場合、AはBに対して能動的(Active)な関係であり、逆に、BはAに対して、受動的(Passive)な関係だと言える。この関係性が、左右非対称(FaceBookは左右対称)な関係性を見分ける上で必要になる

<br>

## active relationships

自分がBさんをフォローした場合

`follower_id`...自分のIDが格納

`followed_id`...BさんのIDを格納

能動的な関係にフォーカスを当てたactve_relationshipsテーブルという架空のテーブルを作成し、`follower_id`に自分のIDを格納、`followed_id`にBさんのIDを格納。中間テーブルであるactive_relationshipsテーブルの`followed_id`を通して(参照して)、usersテーブルと繋げ、自分が誰をフォローしているかがわかるようにしたい

|follower_id|followed_id|
|-|-|
|私のID|BさんのID|
|私のID|CさんのID|
|私のID|EさんのID|

<br>

## Relationshipモデルの作成

```
# migraton_file

def change
 create_table :relationships do |t|
   t.integer :follower_id, null: false
   t.integer :followed_id, null: false
   t.timestamps
 end
 add_index :relationships, :follower_id
 add_index :relationships, :followed_id
 add_index :relationships, [:followed_id, :follower_id], unique: true
end
```

いいね機能と同様に、`add_index :relationships, [:followed_id, :follower_id], unique: true`インデックスを追加することで、AさんがBさんを２重でフォローできることを防ぐ

<br>

## belongs_to

belongs_to :XXXと記述できるのは、外部キー(foreign_key)を指定しているから。だから、外部キーを辿って2つのテーブルを繋げることができる。Railsは、user_idという外部キーの名前を使って、関連付けの推測をしている。つまり、`<class>_id`というパターンを理解し、`<class>`に当たる部分からクラス名(小文字に変換されたクラス名)を推測する

<br>

## class_name

`class_name`オプションを使うことで、関連名を参照先と異なる名前で登録することができるようになる

[アソシエーションにおけるclass_nameの定義！](https://qiita.com/wacker8818/items/eccdf0a63616feb14a70)

主に、1つのモデルに対して、複数のアソシエーション経路を組む場合に利用する。複数のアソシエーションを組む場合は、経路を指定する必要があるが、モデルが1つのため、別経路なのに取りに行くモデルが同じということが起きる。これを防ぐ目的として、`class_name`がある。これのおかげで、便宜的にモデルを複数に分けることができ、実際は1つのモデルを見に行くことができるという訳、からくり

かなり、納得・なるほど！！

[railsアソシエーションオプションのメモ](https://qiita.com/tomoharutt/items/e548186c763079327ed1)

<br>

## アソシエーション

以上のことを踏まえて、アソシエーションを行っていく。

```
# models/relationship

belogns_to :follower, class_name: "User"
belogng_to :followed, class_name: "User"
```

`class_name`を使用し、存在しない、follower, followedクラスを参照することを防ぐ

```
# models/user

has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
```

<br>

## 自分なりの見解

`foreing_key: "follower_id`...active_relationshipsテーブルは、あるユーザーがフォローしているユーザー達を取得するための中間テーブルなので、外部キーとして、あるユーザーのIDを格納する`follower_id`を指定する必要がある

<br>

## 以上の関連付けで、使えるよになるメソッド

|メソッド|用途|
|-|-|
|active_relationships.follower|フォロワーを返す(つまり自分？)|
|active_relationships.followed|フォローしているユーザーを返す|
|user.active_relationships.create(followed_id: other_user.id)|userがother_userをフォローする(能動的)|
|user.active_relationships.build(followed_id: other_user.id)|userと紐づいた新しいRelationshipオブジェクトを返す|

<br>

## relationshipsのバリデーション

```
# models/relationship

validates :follower_id, presence: true
validates :followed_id, presence: true
```

<br>

## has_many

has_manyでの関連付けをする際に、`user has_many :likes`のような記述をする。これは、Railsが`:likes`というシンボル名を見て、単数形`like`に変換し、likesテーブルのuser_idから対象のユーザーを取得する

<br>

## following / followers

いいね機能実装でも使用した、`has_many through`, `source`オプションを今回も使用する

あるユーザーがフォローしているユーザー達を表す際に、本来は`followeds`としたいが、これは英語的に不適切であるため、`following`という名前にしたい

つまり、`following`配列の元は、followed_idの集合であることをRailsに伝えれればいい

```
# models/user

has_many :following, through: :active_relationships, source: "followed"
```

上記の関連付けにより、次のような記述ができる

```
user.following.include?(other_user) #=> userがother_userをフォローしているかどうか

user.following << other_user #=> userのフォローしているユーザー配列にother_userをpush

user.following.delete(other_user) #=> userがother_userをフォローしていれば、other_userのフォローを解除
```

<br>

## follow, unfollow, following? メソッドの追加 (いいね機能とほぼ同じ)

```
models/user.rb

def follow(other_user)
 following << other_user
end

def unfollow(other_user)
 active_relationships.find_by(followed_id: other_user.id).destroy
end

def following?(other_user)
 following.include?(other_user)
end
```

`<<`問題については、[いいね機能のまとめ](https://github.com/koteharyu/TIL/blob/main/insta_clone/05_like_post/issues.md#like-unlike-like-%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%AE%E5%AE%9F%E8%A3%85)を振り返ること

<br>

## seeds.rb

ユーザー間のRelationshipをseedにて作成する

```
# seeds.rb

# ユーザーの作成
50.times do |n|
 User.create!(
   name: "#{n}user",
   email: "#{n}user@example.com",
   password: "password",
   password_confirmation: "password"
 )
end

# フォローしてみる
users = User.all
user = User.first
following = users[2..30]
following.each { |followed| user.follow(followed) } #userが2-30番目までのユーザーをフォロー
```

<br>

## ルーティング

```
# routes.rb

resources :relationships, only: i%[create destrioy]

$ be rails routes | grep relationships

relationships POST   /relationships(.:format)     relationships#create
relationship DELETE /relationships/:id(.:format) relationships#destroy
```

<br>

## views

いいね機能同様、follow_area, follow, unfollowのパーシャルをusers内に作成

```
# users/_follow_area.html.slim

- if logged_in? && current_user.id != user.id
 div id="follow_area-#{user.id}"
   - if current_user.follow?(user)
     = render "unfollow", user: user
   - else
     = render "follow", user: user
```

`logged_in?`で、ログインしていることを大前提に

```
# users/_follow.html.slim

= form_with url: relationships_path(followed_id: user.id), method: :post, remote: true do |f|
 = f.submit "フォロー", class: "btn btn-raised btn-outline-warning"
```

パスの引数として、誰をフォローするかとしてfollowed_idが必要

```
# users/unfollow.html.slim

= form_with url: relationship_path(current_user.active_relationships.find_by(followed_id: user.id)), method: :delete, remote: true do |f|
 = f.submit "アンフォロー", class: "btn btn-raised btn-warning"
```

DELETEリクエストを送るrelationship_pathの引数として、アンフォローするユーザーのIDが必要になる。

アンフォローするということは、すでにフォローしているということなので、上記の記述により、対象のユーザーを検索・特定し、そのユーザーIDを引数として渡すような流れ

<br>

## Controllers

models/userにて定義したメソッドをフル活用

```
# relationships_controller.rb

def create
 @user = User.find(params[:followed_id])
 current_user.follow(@user)
end

def destroy
 @user = Relatioship.find(params[:id]).followed
 current_user.unfollow(@user)
end
```

`Relatioship.find(params[:id]).followed`の記述を言語化するとこんな感じだろうか？

DELETE時に生成されるURLは`/relationships/:id`であるため、`params[:id]`にてRelationshipのidを取得し、そのIDレコードのfollowed_idのユーザー情報を@userに代入しているのか??

<br>

## ajax

いいね機能同様、`.js.slim`を作成

```
# relationships/create.js

| $("#follow_area-#{@user.id}").html("#{j render('users/follow', user: @user)}");
```

```
# relationships/destroy.js.slim

| $("#follow_area-#{@user.id}")html("#{j render('users/unfollow',user: @user)}");
```

relationships_controllerのcreate/destroyのアクションにて@userを渡していることに注意

<br>

## 要件について

以下の要件に沿って進めていく

1. ユーザー一覧画面/詳細画面を実装すること
2. 投稿一覧画面右にあるユーザー一覧については登録日が新しい順に5件分表示してください
3. 投稿一覧画面について
   1. ログインしている場合
      1. フォローしているユーザーと自分の投稿だけ表示させること
   2. ログインしていない場合
      1. 全ての投稿を表示させること
4. 一件もない場合は『投稿がありません』と画面に表示させること

<br>

1...ユーザー一覧画面

```
# users_controller

def index
  @users = User.all.page(params[:page]).order(created_at: :desc)
end
```

復習になるが、`users/index.html.slim`内に`= render @users`と記述することで、自動的に`users/_user.html.slim`がレンダーされる。

これは、`= render 'user' collection: @users`を省略させた記法

その`users/_user.html.slim`内に、フォロー関係のパーシャルをレンダーする

```
# users/_user.html.slim

.user.mb-3.d-flex.justify-content-between
  = link_to user_path(user) do
    = image_tag 'profile-placeholder.png', size: '40x40', class: 'rounded-circle mr-1'
    = render 'follow_area', user: user
```

user_pathに渡しているuserは、index.html.slim内で渡された変数

今回学んだこと！！

今までlink_toをブロックで渡すことで、iconなどをリンクに設定できることは知っていたが、まさか、複数リンクに設定することができたとは!!...今までlink_toを必要分だけ書いていた...

<br>

1...詳細画面

特に難しいことは、せず、詳細画面にも`follow_area`をレンダーする。注意ポイントとしては、`user: @user`。

<br>

2...表示件数の設定(投稿一覧画面)

```
# models/user

scope :recent, -> (count) { order(created_at: :desc).limit(count) }
```

上記のようにすることで、それぞれのアクションでrecent(count)を呼び出すことで、臨機応変に表示件数を変えることができるようになる

```
# posts_controller

def index
  @users = User.recent(5)
end
```

<br>

3-1-1...ログインしている場合、投稿一覧画面には、自分とフォローしているユーザーの投稿だけを表示する

```
# posts_controller

def index
  @posts = if current_user
             my_posts = current_user.posts
             following_user_posts = []
             current_user.following.each do |user|
               following_user_posts.push(user.posts)
             end
             my_posts + following_user_posts
           end
  @users = User.recent(5)
end
```

1. my_postsと言う変数に自身の全ての投稿を格納
2. following_user_postsと言う空の配列を作成
3. eachメソッドを使って、currnet_userがフォローしているユーザーを１人ずつ取り出す
4. 取り出したユーザーの全ての投稿をfollowing_user_postsに格納していく
5. @postsにmy_postsとfollowing_user_postsを足すことで、自分とフォローしているユーザーの投稿のみに限定できる

<br>

3-2-1...ログインしていない場合、投稿一覧画面に全ての投稿を表示させる

```
# posts_controller.rb

def index
  if current_user
    ...
  else
    @posts = Post.all.includes(:user).page(params[:page]).order(created_at: :desc)
  end
  @users = User.recent(5)
end
```

N+1問題に注意！

<br>

4...一件もない場合は『投稿がありません』と画面に表示させること

posts/index.html.slim内にて、@postsが存在するかどうか(present?)を判定し、falseであれば『投稿がありません』と表示させれば良い

<br>

## feed

`_ids`メソッドとは、ActiveRecordが用意しているかなり便利なメソッド。例えば、current_userがフォローしているユーザーのidを取り出したい時は、`current_user.folliwing.map(&:id)`と記述することで、idと言う変数にそれぞれ格納され取得できる。が、`_ids`メソッドを使うともっと簡単に記述ができるそう

`current_user.following_ids`これだけで、フォローしているユーザーのidが配列として返ってくる。すごすぎ

`following_ids`メソッドは、`has_many :following`の関連付をした際に、ActiveRecordが自動生成したものらしい

```
# models/user

# followしているユーザーのpostsを取得するメソッド
def feed
  Post.where(user_id: following_ids << id)
end
```

```
# posts_controller

def index
  @posts = current_user.feed
end
```

とすることで、自分とフォロー中のユーザーの投稿のみを取得することができる

<br>

## 疑問

- Relationship.find(params[:id]).followed
- Post.where(user_id: following_ids << id)

<br>

### Relationship.find(params[:id]).followed

DELETE時に生成されるURLは`/relationships/:id`であるため、`params[:id]`にてRelationshipのidを取得し、そのIDが含まれるレコードのfollowed_idのユーザー情報を@userに代入しているのでしょうか?

<br>

### Post.where(user_id: following_ids << id)

この記述は、models/userに記述しているため、`<< id`は、current_userのidを指しており、following_idsにcurrent_userのidも追加することで、current_userとフォロー中のユーザーの投稿を取得することができていると考えていますが、いかがでしょうか？？


<br>

[RailsTutorial](https://railstutorial.jp/chapters/following_users?version=6.0#cha-following_users)
