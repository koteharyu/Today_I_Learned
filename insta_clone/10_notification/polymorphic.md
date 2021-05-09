# Polimorphicについて


instacloneの通知機能の実装要件として、`ポリモーフィック関連`を使うことが挙げられていた。そもそもポリモーフィックってなんだ？状態だったので、一旦落ちつて調べ上げることに

<br>

## Polimorphism ポリモーフィズムとは

`Polimorphism`...多様性という意味。オブジェクト指向の３大要素の１つ。

`オブジェクト指向の３大要素`... `ポリモーフィズム(多様性)`, `カプセル化(隠蔽)`, `継承(インヘリタンス)`

[オブジェクト指向の３大要素](https://qiita.com/112231/items/9e8bcd804d2ed76a15ea)

polimorphismを一言でいうと、オブジェクトの実態を気にせずに、メソッドを呼び出し、そのオブジェクトごとに振る舞ってもらうこと

例えば、犬・猿・キジの３匹の動物がいて、３匹の鳴き声を聞きたい時に

「わんわん」鳴いてください

「ウキウキ」鳴いてください

「キーキー」鳴いてください

とそれぞれの動物ごとに命令を出すのではなく、３匹に向けて

「鳴いてください」

と命令したほうが楽だし、いちいち命令先の動物たちのことを考えて命令しなくてよくなる。これがポリモーフィズムの考え方。

<br>

## ポリモーフィック関連

`ポリモーフィック関連`とは、ポリモーフィズムの思想を元に、モデルを関連付けること

仮に、`Userモデル`と`Companyモデル`の２つが`Postモデル`を共有している場合、記事(post)の所有者は、企業(company)か個人(user)かの２通り存在する

また、Userであればlast_name + first_name、Companyであればnameを取得するcontributor_nameメソッドをそれぞれに定義したとする

ポリモーフィック関連を使わない場合

```
class User < ApplicationRecord
  has_many :posts
end

class Company < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :company
end
```

```
@post.user.author_name
@post.company.contributor_name
```

上記の様になるが、問題が２つある

1. 記事の投稿者の情報を取得する場合、Userなのか Companyなのかをpostごとに確認しなければならない点
2. 投稿するモデルが増えた場合、Postモデルにカラムを追加して関連づけなければならない

<br>

## ポリモーフィック関連での実装

ポリモーフィック関連で実装することで、上記の問題を解決できる

```
# create_post.rb

class_CreatePost < ActiveRecord::Migrfation
  def change
    t.string :name
    t.references :postable, polymorphic: true, index: true
    t.timestamps
  end
end
```

`reference`を使って参照するためのキーをカラムに追加する。

`polymorphic`オプションをtrueにする

以上により、`postable`を使って関連した投稿者を取得できるようになる

生成されるschema↓↓

```
# schema.rb

create_table "posts", force: :cascade do |t|
  t.string "name"
  t.string "postable_type"
  t.integer "postable_id"
  t.index ["postable_type", "postable_id"], name: "index_posts_on_postabletype_and_postable_id"
end
```

polymorphic: trueを付与するだけで、`postable_type`というカラムが追加される。このカラムにより、今回は投稿者のクラスを判断する

次に関連付

```
class Post < Applicationrecord
  belongs_to :postable, polymorphic: true
end

class User < ApplicationRecord
  has_many :posts, as: :postable
end

class User < ApplicationRecord
  has_many :posts, as: :postable
end
```

以上の関連付により、`@post.postable`で投稿者がどちらのクラス(User or Company)なのかを気にせずに呼び出すことができる様になる

最後は、共通メソッド(contibutor_name)の定義

```
class User < ApplicationRecord
  has_many :posts, as: :postable

  def contributor_name
    "#{last_name} #{first_name}"
  end
end

class Company < ApplicationRecord
  has_many ;posts, as: :postable

  def contributor_name
    name
  end
end
```

これで記事の投稿者の名前出力はオブジェクトの実態を気にせず全部共通で`@post.postable.contributor_name`で実行できる様になるというお話。

概要はわかったが、本当に使いこなすことができるのか。。。？？

今後の自分に期待！

[Railsガイド](https://railsguides.jp/association_basics.html#%E3%83%9D%E3%83%AA%E3%83%A2%E3%83%BC%E3%83%95%E3%82%A3%E3%83%83%E3%82%AF%E9%96%A2%E9%80%A3%E4%BB%98%E3%81%91)
[Railsのポリモーフィック関連　初心者→中級者へのSTEP](https://qiita.com/kamohicokamo/items/c13f72d720040cfd796d)
[Railsのポリモーフィック関連とはなんなのか](https://qiita.com/itkrt2y/items/32ad1512fce1bf90c20b)
