# uniqueness scope構文が読めません

instacloeにて、いいね機能を実装中、以下の記述でユニーク制約をするが、なんか理解できなかったので調べてみた

```
# models/like.rb

validates :user_id, uniqueness: {scope: :post_id}
```　

上記の記述により、各ユーザーは、１つの投稿に対して１度しかいいねできないように制約しているのだが、理解に苦しむ。

<br>

## 読み方

```
# models/like.rb

belongs_to :user
belongs_to :post

validates :user_id, uniqueness: {scope: :post_id}
```　

post_idに対して、重複したuser_idを登録できないという意味。

つまり、１というidをもつユーザーが、２というidをもつ投稿に対して、一意でなければならないため、各ユーザーは、１つの投稿に対して１度しかいいねできないようになるというからくり

<br>

## もしscopeをつけなかったら

```
# models/like.rb

validates :user_id, uniqueness: true
```

となると、テーブル全体でuser_idが一意でなければならないため、１人のユーザーは、そのアプリ内で１回しかいいねすることができなくなってしまう。

<br>

## マイグレーション側での制約

```
add_index :likes, [:user_id, :post_id], unique: true
```

<br>

[uniqueness: scope を使ったユニーク制約方法の解説](https://qiita.com/j-sunaga/items/d7f0e944baad6e56206c)
