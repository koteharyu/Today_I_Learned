# enumとは

integer型やboolean型で登録され、数値に対応する任意のキー名を名付けることができる列挙型

特定のカラムで使う固定値がある程度決まっている際に使うと良いとのこと。従って10_notificationにおいて、readカラムはboolean型であり、true or falseの固定値であるため打って付け

ただ、基本的には、ineteger型で使うことが多いらしく、今回はinteger型での解説を元にまとめていく。

## 実装方法

integer型のgenre(ジャンル)カラムを持つbooksテーブルがあると仮定

enumはモデルに記述する！

```
# models/book

enum genre: {
  nobel: 0, #小説
  essay: 1, #エッセイ
  practical: 2, #実用
  comic: 3, #漫画
  other: 4 #その他
}
```

ハッシュ形式でキー名と数値を指定する。この方法が一般的みたい

公式：`enum <カラム名>: {付けたいキー名: 対応する数値}`

<br>

または...

```
# models/book

enum genre: [:nobel, :essay, :practical, :comic, other]
```

配列で名前定義もできる。この場合は、定義順に0から順に名前定義と数値が紐付けられる。なので、キー名と数値の組み合わせはハッシュ形式で定義したもの同じ

もし、`:nobel`の左に`:action`を差し込むと、数値が１つずつズレるため`:other`は`5`になる

なお、公式様は、「一番最初に宣言した値をデフォルト値としてモデルに定義するように」と仰っているためそれに従うべし

従って、話が前後してしまうがこの場合のマイグレーションファイルは以下のようになっているのが無難だろう

```
def change
  create_table :books do |f|
  //
  t.integer :genre, default: 0 #つまりnobelにするという意味
end
```

<br>

## 使い方・メソッド

bookの作成

```
book = Book.create(title: "sample book", genre: :essay)
```

`.キー名?`...真偽値が返ってくる

```
book.essay?
#=> true

book.comic?
#=> false
```

`.キー名!`...そのキーに変更できる

```
book.comic!
book.comic?
#=> true

book.essay?
#=> false
```

`.カラム名<enum名>`, ...キーの確認ができる

```
book.genre
#=> comic
```

`.カラム名<enum名>[:キー名]`...対応した数値が返ってくる

```
# レシーバーがクラスになっています
Book.genre[:comic]
#=> 3
```

`.カラム名<enum名>[:enumに指定していない項目]`...エラーにならず`nil`が返ってくる

Ruby/Railsでは、未定義の名前定義を選択しても例外は発生しないことに注意。

```
Book.genre[:manzai]
#=> nil
```

[ActiveRecord::Enum](https://api.rubyonrails.org/v5.1/classes/ActiveRecord/Enum.html)

[enumとは?](https://qiita.com/clbcl226/items/3e832603060282ddb4fd)

[５ステップでイケてる enum を作る（翻訳）](https://qiita.com/punkshiraishi/items/799bef63607e03262644)

[Enumってどんな子？使えるの？](https://qiita.com/ozackiee/items/17b91e26fad58e147f2e)
