`Where`で取得できるのは`ActiveRecord:Relation`なので、複数の要素が入っている配列と言える。複数のものに`destroy`は呼べないため、`destroy_add`メソッドを使う。

以下のような関連がある際

```
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :Author
end
```

<br>

Authorテーブルの最初のレコードに紐づいている`Book`から`title`が`hoge`のものを取得し、削除する記述は以下のようになる。

```
author = Author.first
books = author.books.where(title: "hoge")
books.`destroy_all`
```