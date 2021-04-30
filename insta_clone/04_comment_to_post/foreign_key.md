# なんとなくの理解だったforeign_keyについて

関連付ける際に指定しとけばいいかなくらいの理解だったので、一度調べてみました

<br>

## そもそも外部キー制約ってなんじゃ？？

外部キー制約とは・・・

主キーと外部キーを使った制約で利用した場合、下記の制限が入る

1. 存在しない値を外部キーとして登録することができない
2. 子テーブルの外部キーに値が登録されている親テーブルのレコードは削除できない
  1. `dependent: :destroy`オプションを子クラスに定義することで、回避できる

## 外部キー制約のメリット・デメリット

### メリット

- 存在しない値が外部キーとして登録されることを防ぐことができる
- うっかり親テーブルのレコードを消しちゃった。なんてことがなくなり、子テーブルのレコードの親子関係がバグることがなくなる

### デメリット

- 設定を間違えた際に、意図せず重要なレコードが消える可能性がある
- 大量のデータを抱えた親レコードがあっても、外部キー制約があると分割して消すことが難しいため、削除の負荷を分散できない
- DBを跨いだ制約はかけることができない

[外部キーの概要と制約を使うことのメリット・デメリット](https://qiita.com/kamillle/items/5ca2db470f199c1bc3ef)

<br>

## foreign_keyってなに？？

`foreign_key`とは、参照先を参照するための外部キーをしていするもの。　らしい

## 嚙み砕くと

`foreign_key`とは、belongs_toによって参照先を参照するためにbelongs_toを行う側に記述しなければならないもの

つまり 1userが多数のpostを投稿できる関係の場合

```
class User < ApplicationRecord
 has_many :posts
end

class Post < ApplicationRecord
 belongs_to :user
end
```

foreign_keyはbelongs_to側に指定するものだったので次のようなマイグレーションファイルになる

```
def change
 create_table :posts, do |t|
   t.references :user, foreign_key: true
 end
end

# または

def chage
 add_reference :posts, :user, foreign_key: true
end
```

## 考え方

BBB has_many AAA

AAA belongs_to BBB

という関係性の場合、foreign_keyは、AAAのマイグレーションファイルに記述するということ

`foreign_keyはbelongs_toで参照を行う側に記述しなければならない`

[Railsの外部キー制約とreference型について](https://qiita.com/ryouzi/items/2682e7e8a86fd2b1ae47)
[foreign_keyの定義がわからなかったので自分なりに噛み砕いてみた](https://qiita.com/eitches/items/516ebd36bd3e8d633e41)
