# 06_follow

<br>

あるユーザーが他のユーザーをフォルーする時、あるユーザーが他のユーザーをフォロー解除する時、`Relationship`が作成されたり、削除されたりする

AがBをフォローしているが、BはAをフォローしていない場合

AはBに対して`能動的(active)`な関係であり、逆に、BはAに対して`受動的(passive)`な関係だと言える。この関係性が、左右非対称な関係性を見分ける上で必要になる。

## active relationships

activeつまり能動的な関係を表すテーブルについてなので、以下のように考えることができる。

AがBをフォローしている場合、active_relationshipsテーブル内の、`follower_id`にAのIDを格納、`followed_id`にBのIDを格納。中間テーブルである、このactive_relationshipsテーブル・`followed_id`を通して、userテーブルと繋がり、Aが誰をフォローしているのかがわかる。

## relationshipモデルの作成

```
relationshipls:
  follower_id: integer
  followed_id: integer

  add_index :relationships, follower_id
  add_index :relationships, followed_id
  add_index :relationships, [:follower_id, :followed_id], unique: true
```

今回も、likesテーブルと同様、follower_idとfollowed_idの組み合わせを一意にすることで、あるユーザーが同じユーザーを２回以上フォローすることを防ぐことができる

## 復習

belongs_to ~と書けるのは、外部キー(foreign_key)を指定しているから。だから、外部キーを辿って２つのテーブルを繋げることができる。Railsはuser_idと言う外部キーの名前を使って、関連付けの推測をしているそうだ。つまり、`<class>_id`と言うパターンを理解し、`<class>`に当たる部分からクラス名(小文字に変換されたクラス名)を推測する

## class_name

`class_name`オプションを使うことで、関連名を参照先のクラス名と異なる名前で登録することができるようになる

[アソシエーションにおけるclass_nameの定義！](https://qiita.com/wacker8818/items/eccdf0a63616feb14a70)

主に、1つのモデルに対して、複数のアソシエーション経路を組む場合に利用する。複数のアソシエーションを組む場合は、経路を指定する必要があるが、モデルが１つのため、別経路なのに取りに行くモデルが同じと言うことが起きる。これを防ぐ目的として、`class_name`がある。これのおかげて、便宜的にモデルを複数に分けることができ、実際は１つのモデルを見にいくことができると言うわけ[railsアソシエーションオプションのメモ](https://qiita.com/tomoharutt/items/e548186c763079327ed1)

めちゃめちゃなるほど！！！！！！

よって今回は、その`class_name`を使って、擬似的に`active_relationships`と`followed`と`follower`を作成し、関連付を行おうと言うわけ

userはたくさんのユーザーをフォローすることができ、Relationshipクラスは、Userに属するため...以下のように記述する

```
class User < ApplicationRecord
  has_many :active_relationships, class_name: "relationships", foreign_key: "follower_id", dependent: :destroy
end
```

```
class Relationship < ApplicationRecord
  belongs_to :followed, class_name: "User"
  belogns_to :follower, class_name: "User"
end
```

## 上記により、使えるようになるメソッド一覧

|メソッド|用途|
|-|-|
|active_relationships.follower|フォロワーを返す(つまり自分？)|
|active_relationships.followed|フォローしているユーザーを返す|
|user.active_relationships.create(followed_id: other_user.id)|userがother_userをフォローする(能動的)|
|user.active_relationships.build(followed_id: other_user.id)|userと紐づいた新しいRelationshipオブジェクトを返す|

## relationshipsのバリデーション

```
validates :follower_id, presence: true
validates :followed_id, presence: true
```

## 復習

has_manyの関連付をする際に、`user has_many :likes`のような記述をする。これはRailsが`:likes`と言うシンボル名を見て`like`と言う単数系に変え、likesテーブルのuser_idを使って、対象のユーザーを取得する(あってますかね？？)

## following followers

いいね機能実装でも使った、`has_many through`,`source`を今回も使用する

あるユーザーがフォローしているユーザー達を表す際に、本来は、`followeds`としたいが、これは英語として不適切であるため、今回は`following`としたい

つまり、`following`配列の元は`followed`idの集合であることを明示的にRailsに伝えれば良い

```
# models/user.rb

has_many :following, through: :active_relationships, source: :followed
```

上記の関連付により、以下のような記述ができる

```
user.following.include?(other_user) #=> userがother_userをフォローしているかどうか

user.following << other_user #=> userのフォローしているユーザー配列にother_userをpush

user.following.delete(other_user) #=> userがother_userをフォローしていれば、other_userのフォローを解除
```

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

<br>

## passive_relationships

`user.followers`メソッドを追加するために、passive_relationshipsテーブルを作成する。これはactive_relationshipsテーブルの`follower_id`,`followed_id`を入れ替えれば良さそう

つまり、あるユーザーが、誰からフォローされているかがわかる

```
# models/user.rb

has_many :passive_relationships, class_name: "Relationships", foreing_key: "followed_id", dependent: :destroy
has_many :followers, through: :passive_relationships, source: :follower
```

followersの場合は、`source`オプションを省略しても良い。なぜかわかりますか？？？？

...正解は、followedsと異なり、素直に`followers`から`follower`へと単数系に変換することができるから

以上の関連付で、`user.followers`メソッドが使えるようになる

## seeds.rb

ユーザー同士の関係性をseedを使って生成する

```
# seeds.rb

# ユーザーの作成
99.times do |n|
  User.create!(
    name: "Example User#{n}",
    email: "example#{n}@example.com,
    password: "password",
    password_confirmation: "password"
  )
end

# リレーションシップの作成
users = User.all
user = User.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) } # userが2~50番目までのユーザーをフォロー
followers.each { |follower| follower.follow(user) } # 3~40番目までのユーザーがuserをフォロー
```

## ルーティング

```
# routes.rb

resources :relationships, only: i%[create destrioy]

$ be rails routes | grep relationships

relationships POST   /relationships(.:format)     relationships#create
relationship DELETE /relationships/:id(.:format)  relationships#destroy
```

## views

いいね機能同様、follow_area, follow, unfollowのパーシャルをusers内に作成する

```
# users/_follow_area.html.slim

- if logged_in? && current_user.id != user.id
  div id="follow_area-#{user.id}"
    - if current_user.follow?(user)
      = render 'unfollow', user: user
    - else
      = render 'follow', user: user
```

```
# users/_follow.html/slim

= form_with url: relationships_path(followed_id: user.id), method: :post, remote: true do |f|
  = f.submit "フォロー", class: ""btn
```

```
# users/_unfollow.html.slim

= form_with url: relationship_path(current_user.active_relationships.find_by(followed_id: user.id)), method: :delete, remote: true do |f|
  = f.submit "アンフォロー", class: "btn"
```

## controller

```
# relationships_controller.rb

def create
  @user = User.find(params[:follows_id])
  current_user.follow(@user)
end

def destroy
  @user = Relationship.find(params[:id]).followed
  current_user.unfollow(@user)
end
```

## ajax

いいね機能同様、`.js.slim`を作成

```
#relationships/create.js.html

| $("#follow_area-#{@user.id}").html("#{j render('users/unfollow', user: @user)}");
```

```
#relationships/destroy.js.html

| $('#follow_area-#{@user.id}').html("#{j render('users/follow', user: @user)}");
```

## users_controller / users_views周りについて

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
  @users = User.all.page(params[:page]).order(created: :desc)
end
```

これも復習になるが、`users/index.html.slim`内に`= render @users`と記述することで、自動的に`users/_user.html.slim`がレンダーされる

その`users/_user.html.slim`内にフォロー関係をぶちこむ

```
# users/_user.html.slim

.user.mb-3.d-flex.justify-content-between
  = link_to user_path(user) do # このuserは、index.html.slim内で渡された変数
    = image_tag 'profile-placeholder.png', size: '40x40', class: 'rounded-circle mr-1'
    = user.name
  = render 'follow_area', user: user
```

今回学んだこと！！

今までlink_toをブロックで渡すことで、iconなどをリンクに設定できることは知ってたけど、まさか、複数リンクを設定することができたとは！！今まで、= link_toを必要分書いていた...

<br>

1...詳細画面

特に難しいことは、せず、詳細画面にも`follow_area`をレンダーする。注意ポイントとしては、`user: @user`。

<br>

2...表示件数の設定(投稿一覧画面)

```
# models/user.rb

scope :recent, ->(count) { order(created_at: :desc).limit(count) }
```

上記のようにすることで、それぞれのアクションや処理内にcountを指定することで、臨機応変に表示件数を変更できる

```
# posts_controller.rb

def index
  @users = User.recent(5)
end
```

<br>

3-1-1...ログインしている場合、投稿一覧画面には、自分とフォローしているユーザーの投稿だけを表示する

```
# posts_controller.rb

def index
  if current_user
    my_posts = current_user.posts
    following_user_posts = []
    current_user.following.each do |user|
      following_user_posts.push(user.posts)
    end
    @posts = my_posts + following_user_posts
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

<br>

4...一件もない場合は『投稿がありません』と画面に表示させること

posts/index.html.slim内にて、@postsが存在するかどうか(present?)を判定し、falseであれば『投稿がありません』と表示させれば良い

<br>

## feed

`_ids`メソッドとは、ActiveRecordが用意しているかなり便利なメソッド。例えば、current_userがフォローしているユーザーのidを取り出したい時は、`current_user.folliwing.map(&:id)`と記述することで、idと言う変数にそれぞれ格納され取得できる。`_ids`メソッドを使うともっと簡単に記述ができるそう

`current_user.following_ids`これだけで、フォローしているユーザーのidが配列として返ってくる。すごすぎ

`following_ids`メソッドは、`has_many :following`の関連付をした際に、ActiveRecordが自動生成したものらしい

```
# model/users

def feed
  Post.where(user_id: following_ids << id)
end
```

```
# posts_controller.rb

def index
  @posts = current_user.feed
end
```

とすることで、自分とフォロー中のユーザーの投稿のみに限定できる

<br>

[RailsTutorial](https://railstutorial.jp/chapters/following_users?version=6.0#cha-following_users)
