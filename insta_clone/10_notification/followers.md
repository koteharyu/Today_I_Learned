# followersメソッドを使えるようにする

現状は、active_relationshipsを通してユーザーがフォローしている人たちを返す`following`が使える。

```
# models/user

has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
has_many :following, through: :active_relationships, source: "followed"
```

これを応用して自分をフォローしているユーザーsを返す`followers`メソッドを使えるようにする。

そのためには、`passive_relationships`というテーブルを作成する。これは、active_relationshipsの`follower_id`と`followed_id`を入れ替えるだけで実装できそう。よって以下のような構成になる

```
# models/user

has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
has_many :followers, through: :passive_relationships, source: "follower"
```

<br>

### クイズ

followersの場合、`source`オプションを省略しても良いが、それはなぜでしょう?

...

...

...

正解は、`followds`とは異なり、sourceに`follower`と指定しなくても、素直に`followers`から`follower`と単数形にRailsが変換してくれるから[復習](https://github.com/koteharyu/TIL/blob/main/insta_clone/06_follow/follow_rails_tutorial.md)


<br>

### 完成版

```
# models/user

has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
has_many :passive_relationships, class_name: "Relationship", foreing_key: "followed_id", dependent: :destroy

has_many :following, through: :active_relationships, source: "followed"
has_many :followers, through: :passive_relationships, source: "follower"
```

以上をもって、`following`, `followers`メソッドが使えるようになりました。めでたしめでたし。
