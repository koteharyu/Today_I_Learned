# ActiveModel::Attributesについて

<br>

## 使用方法

ActiveModel::Modelと一緒にincludeする

```
class <任意なクラス>
  include ActiveModel::Model
  include ActiveModel::Attributes
end
```

こうすることで、クラスにActiveRecordのカラムのような属性を加えることができる

クラスメソッドattributeに属性名と型を渡すと、attr_accessorと同じように属性が使えるようになる

attributeをクラスの冒頭に並べておくと、「このクラスは何をパラメーターとして受け取るのか」を明示できるメリットもあるそう

以下のような、自作のクラスを作ったとする

```
class Book
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :price, :integer, default: 100
  attribute :published_at, :datetime
end
```

`hash`を渡してインスタンスを生成することもできちゃう


```
book = Book.new({name: "harry potter", price: 200, published_at: "1997-06-12 12:30:45 UTC"})
book.class #=> Book
book.name #=> harry potter
book.price #=> 200
```

もし、nameに何も入れずにインスタンスを生成しようとすると、`ArgumentError`も出る

<br>

## メソッド

`attributes`メソッドは、定義されている属性全てをhashで取得できる

```
book.attributes
#=> {"name"=>"harry potter", "price"=>100, "published_at"=>1997-06-12 12:30:45 UTC}
```

<br>

`attribute_names`メソッドは、属性の名前のみ取得できる(Rails6以降のみ)

```
book.attribute_names
#=> ["name","price","publish_at"]
```

[ActiveModel::Attributesの使い方](https://qiita.com/dy36/items/617ae9af81b50baab98a)
