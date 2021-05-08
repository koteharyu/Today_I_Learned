# scopeについて

投稿検索実装時に、models/postにて定義したscopeについての理解を深めようと思った

<br>

```
# models/post

scope :body_contain, -> (word) { Post.where('body LIKE ?', "%#{word}%") }
```

上記記述について

概要...`Post.body_contain(haryu)`と書くと、投稿のbodyカラムに`haryu`が含まれる投稿を検索してくれる

`->`...このマークは`ラムダ`といい、メソッドをオブジェクト化するもの

`?`...プレースホルダーといい、SQLインジェクション対策で使う(?を使わない直書きはNG)
