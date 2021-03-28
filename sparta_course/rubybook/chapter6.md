## chapter 6 Hash

- `hash`とは、複数のオブジェクトをまとめることができる箱のこと。
- 配列との違いは、`キー`と`値`のセットで複数のデータを扱うことができる点。
- ハッシュオブジェクトのクラスは`Hash`
- 配列のクラス名は、`Array`
- キーと値を`=>`で繋ぐため、`ロケットハッシュ`とも呼ばれる
- ハッシュオブジェクトを`pメソッド`へ渡す場合ば、`()`を省略しないように

```
p ( {:coffee => 300, :latte => 400} )
# ()を省略すると文法の解釈が曖昧になりエラーになる
```

<br>

- `シンボル(Symbol)`とは、ハッシュのキーでラベルのように扱われる。もちろん、ハッシュのキー以外の用途でも使用される。
- `:<string>`

- `to_symメソッド`
  - 文字列からシンボルへ変換する
- `to_s`
  - オブジェクトをStringへ変換する
  - シンボルから文字列へ変換する

<br>

- ２種類のハッシュの書き方

1. `{:coffee => 300, :latte => 400}`
2. `{coffee: 300, latte: 400`

- ハッシュから値を取得
  - `ハッシュ[:キー]`と指定することで`値`を取得できる

```
menu = {coffee: 300, latte: 400}
p menu[:latte]
#=> 400
```

memo)

`p menu[400]`のように、キーを取得しようとすると`nil`が返ってくる

## ハッシュの書き方応用

- ハッシュのキーの部分には、シンボルを使うことが多いが、値の部分にはさまざまなオブジェクトを置ける。文字列や整数だけでなく、配列や別のハッシュを置くことが可能。

```
{title: "Ruby Book", members: ["yano", "beco"]}
```
- 空のハッシュは`{}`と書く

<br>

- ハッシュへキーと値の追加
  - 末尾へ追加せれるが、配列のように順番を意識する必要性は低い

```
menu = {coffee: 300, latte: 400}
menu[:mocha] = 400
p menu
#=> {coffee: 300, latte: 400, mocha: 400}
```
<br>

- 値の上書き
  - ハッシュは同じキーを持つことはできないが、値を上書きすることができる

```
menu = {coffee: 300, latte: 400}
menu[:coffee] = 500
p menu
#=> menu = {coffee: 500, latte: 400}
```

<br>

- 存在しないキーを指定した場合は、`nil`が返ってくる。配列での範囲外の要素を取得しようとした時と同じ。

```
menu = {coffee: 300, latte: 400}
p menu[:tea]
#=> nil
```

<br>

- 存在しないキーを指定した際に返ってくる`nil`の変更
  - `default=`で指定できる

```
menu = {coffee: 300, latte: 400}
menu.default=0
p menu[:tea]
#=> 0
```

<br>

- `mergeメソッド`とは、2つのハッシュを１つにまとめるためのメソッド

```
menu1 = {coffee: 300, latte: 400}
menu2 = {red: 200, blue: 600}
p mm = menu1.merge(menu2)
#=> {:coffee=>300, :latte=>400, :red=>200, :blue=>600}
```

- 3つ以上をマージする方法

```
menu1 = {coffee: 300, latte: 400}
menu2 = {red: 200, blue: 600}
menu3 = {yellow: 400, green: 988}
mm = menu1.merge(menu2)
p mmm = mm.merge(menu3)

#=> {:coffee=>300, :latte=>400, :red=>200, :blue=>600, :yellow=>400, :green=>988}
```

<br>

- `deleteメソッド`とは、ハッシュからキーと値の組み合わせを削除するメソッド
- `ハッシュ.delete(:キー)`の構文

```
menu = {coffee: 300, latte: 400}
menu.delete(:latte)
p menu

#=> {coffee: 300}
```

<br>

- ハッシュの繰り返し処理
- `|key, value|`という２つの変数にそれぞれ格納される（変数の名前は任意）

```
menu = {coffee: 300, latte: 400}
menu.each do |key, value|
  puts "#{key}は#{value}円です"
end

#=>
coffeeは300円です
latteは400円です
```

<br>

- `each_keyメソッド`を使うこと、キーだけ繰り返し処理できる

```
menu = {coffee: 300, latte: 400}
menu.each_key do |key|
  puts key
end

#=>
coffee
latte
```

<br>

- `each_value`は値だけを繰り返し処理できる
- 構文は`each_key`と一緒

<br>

memo)

- hashのキーにて、シンボルは`""`が不要、ロケット記法は`""`が必要

- 値の取得時、ハッシュがシンボルで書かれていたら、`hash[:key]`
- ロケットで書かれていたら`hash["key"]`で取得する