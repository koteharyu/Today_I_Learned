## chapter 4 ~ 5 配列

<br>

- `配列`とは、オブジェクトをまとめて扱う部品のこと。数値や文字列と同じように配列もオブジェクトである。配列のクラスは`Array`
- `[`と`]`の間にカンマ区切りで複数のオブジェクトを書く
- `["cafe", "ice", "apple"]`
- 配列は変数に格納できる
- `drinks = ["coffee","orange","apple"]`
- 習慣的に配列を格納する変数は`複数形`で書く
- `[]`は、空の配列

<br>

- 配列の要素の取得方法
  - `drinks = ["coffee","orange","apple"]`

- [n] ~要素の１番目から取得~
  - 配列は、`0`から始まるため、最初の要素を取得するには
  - `puts drinks[0] #=> "coffee"`
  - `puts drinks[1] #=> "orange"`

- [-n] ~要素の最後から取得~
  - `puts drinks[-1] #=> "apple"`
  - `puts drinks[-2] #=> "orange"`

- `first`、`last`で取得
  - `puts drinks.first #=> "coffee"`
  - `puts drinks.last #=> "apple"`

- `nilオブジェクト`とは、「何もない」ことを表すオブジェクト。nilオブジェクトは配列以外でも使われる
- `puts drinks[3] #=> nil `

- 要素を取得するメソッドは変数に対してだけじゃなく、直接、配列にも使用できる
- `puts ["coffee","orange","apple"].first #=> "coffee"`
- `puts ["coffee","orange","apple"][1] #=> "orange"`

memo)

rubyでは、`first` `last`メソッドが使えるが、Railsでは、`first` `second` `third` ... `forty_two`などのメソッドが使えるよになる！

<br>

- `pushメソッド`　~配列の末尾への要素追加~
- `"配列" << "追加したい文字列"` ~配列の末尾への要素追加~
- `unshiftメソッド` ~配列の先頭への要素追加~

```
drinks = ["coffee"]
drinks.push("orange")
p drinks #=> ["coffee","orange"]
drinks.unshift("apple")
p drinks #=> [,"apple","coffee","orange"]
drinks << "tea"　#末尾への追加
p drinks #=> [,"apple","coffee","orange","tea"]
```

<br>

- `popメソッド` ~配列の末尾の要素を１つ削除~
  - 削除した要素を返すメソッド
- `shiftメソッド` ~配列の先頭の要素を１つ削除~
  - 削除した要素を返すメソッド

```
drinks.pop
p drinks #=> ["apple","coffee","orange"]
drinks.shift
p drinks #=> ["coffee","orange"]
```

<br>

- 配列の足し算
  - 2つの配列の要素を繋げることができる

```
a1 = [1,2,3]
a2 = [4,5]
p a1 + a2 #=> [1,2,3,4,5]
```
<br>

- 配列の引き算
  - 引き算を使うと「配列a」と「配列b」を比べて、「配列a」にだけある要素を取得することができる

```
a1 = [1,2,3]
a2 = [1,3,5]
p a1 - a2 #=> [2]
```

<br>

- `break`で`each`処理を停止させる

```
[1,2,3].each do |x|
  break if x == 2
  puts x
end

#=> 1
```
つまり、breakの条件を満たせば、次の行に処理が進まなくなるということ

<br>

- `next`で次の回に進む

```
[1,2,3].each do |x|
  next if x == 2
  puts x
end

#=> 1
#=> 3
```
つまり、`next`の条件を満たした瞬間、`end`までスキップされるため、次の処理に進むことになる

<br>

- `rangeオブジェクト`とは、範囲を表すオブジェクト。`(1..10)`と書くことで、`1~10`の範囲を作ることができる

```
(3..5).each do |x|
  puts x
end

#=> 3
#=> 4
#=> 5
```

<br>

- `戻り値`とは、メソッドの実行結果として返ってくる値のこと。数字だけでなく色々なオブジェクトを返す。

- `size`
  - 配列の要素数を取得する
- `sum`
  - 全要素の合計を取得
- `sample`
  - 要素をランダムに１つだけ取得する
- `shuffle`
  - 配列の要素をランダムに並び替える
- `sort`
  - 要素が数値であれば、小さい順に並び替え
  - 要素が文字列であれば、abc順に並び替え
    - 大文字が混じると`大文字が先、小文字が後`になる


<br>

## 小数点が出てくる計算

- `to_fメソッド`をつけることで小数点まで扱った計算ができる

```
a = [1,2,3]
puts a.sum / a.size
#=> 1 #本来なら1.6...となるべき

# 小数点を計算する
puts a.sum.to_f / a.size.to_f
#=> 1.66667
```

<br>

memo)

`a = [1.0, 1.0, 3.0]`のように要素を小数点有にするだけではダメだった

<br>

- `組み込みライブラリ`とは、Rubyであらかじめ用意されているメソッドなどの道具のこと

- `uniqメソッド`とは、配列の重複した要素を取り除くメソッド

```
a = [1,2,3,1]
p a.uniq
#=> [1,2,3]
```

<br>

- `破壊的変更(!)`とは、メソッドの末尾に`!`をつけること。自分自身の配列オブジェクトを変更するメソッド。

- `object_idメソッド`とは、それぞれのオブジェクトに割り当てれられた識別番号(`オブジェクトID`)を返すメソッド

```
a = [1,1,2]
b = a.uniq
p a #=> [1,1,2]
p a.object_id #=> 9374937
p b #=> [1,2]
p b.object_id #=> 88747

# ↑では、自身の配列オブジェクトは変わっていないことがわかる

# 一方 uniq!を使うと

a = [1,1,2]
b = a.uniq!
p a #=> [1,2]
p a.object_id #=> 9374937
p b #=> [1,2]
p b.object_id #=> 9374937

# オブジェクトIDが一緒になっていることがわかる。つまり自分自身の配列オブジェクト自体を変更している
```

<br>

memo)

- オブジェクトIDが同じということは、オブジェクトが１つということ。つまり、１つのオブジェクトに対して名札が複数ある状況
- 元の配列を残しておきたければ、通常のメソッドを使う
- 残す必要がなければ、`!`をつける

<br>

- [リファレンスマニュアル](http://www.ruby-lang.org/ja/documentation/)

- [るりまサーチ](https://docs.ruby-lang.org/ja/search/)

<br>

- `reberseメソッド`とは、順序を逆にするメソッド。

- sortは小さい順に並び替え
- 大きい順にしたい場合はsortして reverseすればいい

```
a = [2,1,8,6]
p a.sort.reverse
#=> [8,6,2,1]
```

<br>

- `joinメソッド`は、配列内の文字列要素を連結するメソッド
- 引数に指定した文字列で連結することも可能

```
puts ["Tom", "Jerry", "Me"].join("と")
#=> TomとJerryとMe
```

<br>

- `split`とは、文字列を分割して配列にするメソッド。引数を指定しないと、スペースで区切る

```
p "TomとJerryとMe".split("と")
#=> ["Tom", "Jerry", "Me"]
```

<br>

- `mapメソッド`とは、配列の各要素へ処理を行い、変換してできた要素を持った、新しい配列を作るメソッドのこと。ブロックを渡して各要素に処理を行う。

```
result = [1,2,3].map do |x|
  x * 2
end
p result
#=> [2,4,6]
```

```
result = [100,200,300].map do |x|
  "#{x}円"
end
p result
#=> ["100円","200円","300円"]
```

<br>

## ブロックを渡すメソッドを省略して書く記法

以下の３つは全て同じ意味

```
result = ["abc","123"].map do |text|
  text.reverse
end
p result
#=> ["cba","321"]
```

```
result = ["abc","123"].map{|tet| text.reverse}
p result
#=> ["cba","321"]
```

```
result = ["abc","123"].map(&:reverse)
p result
#=> ["cba","321"]
```
