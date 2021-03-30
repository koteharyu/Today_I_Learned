## chapter9 モジュール

- `モジュール`を使うと、複数のクラス間でメソッドを共同利用することができる。クラスにてモジュールをインクルードすることで、モジュールに定義したメソッドをクラス自身に定義されたメソッドとして使えるようになる

- モジュールの作成から利用までの大まかな流れ

1. モジュールを作る
2. モジュールにメソッドを定義する
3. モジュールのメソッドをクラスで使う


```
module WhippedCream
 def whipped_creame
   @name += "whipped creame" # 1
 end
end

class Drink
 include WippedCream # 2
 def initialize(name)
   @name = name # 3
 end
 def name 
   @name # 4
 end
end

drink = Drink.new("latte") # 5
drink.whipped_cream # 6
puts drink.name # 7

#=> lattewhippedcream
```

まず、モジュールの定義方法はクラスの定義方法とほぼ同じように定義すればいい

2の、`include whipped_cream`を実行すると、Drinkクラスのオブジェクトは、`WhippedCream`モジュールの`whipped_creamメソッド`が利用可能になる

6で、実行している`drink.whipped_cream`は、Drinkインスタンスで`WhippedCream`モジュールの`whipped_creamメソッド`を実行している

<br>

`@name`の流れ

1. 5で、Driknクラスのオブジェクトを作成した瞬間に、`initializeメソッド`が呼ばれ、引数`"latte"`が`@name`に代入される
2. 6で、`whipped_creamメソッド`を実行することで、`@name`に`"whipped cream"`が追加される
3. そのため、7で、`lattewhippedcream`が出力される

<br>

### 複数のクラスでモジュールを利用する一例

```
module WhippedCream
 def whipped_cream
   @item += "+whipped cream"
 end
end

class Drink
 include WhippedCream
 def initialize(item)
   @item = item
 end

 def item
   @item
 end
end

class Cake
 include WhippedCream
 def initialize(item)
   @item = item
 end

 def item
   @item
 end
end

drink = Drink.new("coffee")
drink.whipped_cream
puts drink.item

cake = Cake.new("choco")
cake.whipped_cream
puts cake.item
```

<br>

- `Enumerableモジュール`とは、ArrayクラスやHashクラスにincludeされているモジュールのこと。なので、リファレンスマニュアルでは、Enumerableモジュールのとこに書いてある

- `none?メソッド`とは、全要素が該当しないことを調べるメソッド

```
[1,2].none?{ |x| x == 0 } #=> true
[1,2].none?{ |x| x == 1 } #=> false

{a: 1, b: 2}.none?{ |k,v| v == 0 } #=> true
{a: 1, b: 2}.none?{ |k,v| v == 1 } #=> false
```

<br>

- `extendメソッド`を使うことで、モジュールのメソッドをクラスメソッドのように利用することができるようになる

```
module Greeting # 1
 def welcome # 2
   "welcome!!"
 end
end

class Cafe
 extend Greeting # 3
end

puts Cafe.Greeting # 4

#=> welcome!!
```

1で、extendメソッドで利用するモジュールを定義

2で、利用したいクラスメソッドwelcomeをインスタンスメソッドとして定義

3で、extendメソッドの引数にモジュールGreetingを渡すことで、2で定義したwelcomeメソッドが、Cafeクラスのクラスメソッドとして利用可能になる

4で、Cafeクラスのクラスメソッドになったwelcomeメソッドを呼び出している

<br>

- モジュールを使うとメソッドを共同利用ことができる
- モジュールには、インスタンスメソッドを定義できる
- モジュールはクラスと違い、インスタンスを作ることはできない
- クラスにモジュールをincludeすると、モジュールに定義したインスタンスメソッドをりようできる
- eachメソッドを定義しているクラスで、Enumerableモジュールをインクルードするとメソッド群を利用できる
- 自分が作ったクラスにeachメソッドを定義しておけばEnumerableモジュールをインクルードすることで、沢山のメソッド群を利用することができる
- 配列やハッシュではEnumerableモジュールのメソッド群を利用できる

<br>

## モジュールにクラスメソッドを定義する

```
module WhippedCream
 def self.info
   "add topping"
 end
end

puts WhippedCream.info

#=> add topping
```

<br>

## 定数

- 先頭を`大文字`にする

```
module WhippedCream
 Price = 100  # 1
end

puts WhippedCream::Price  # 2

#=> 100
```
1. 定数は先頭を大文字で書く
2. `::`でモジュールと定数を繋げて、定数を利用する

<br>

## 名前空間

- 同じクラス名を複数の場所で使いたいが、別のクラスなので別々に定義して呼び分けたいケースに使える
- たとえば、カフェごとに違う`Coffeeクラス`を作るケース
- `名前空間を作る`とは、モジュールを使って名前を分ける手段のこと

```
module BocoCafe
 class Coffee
   def self.info
     "BocoCafe!"
   end
 end
end

module MathCafe
 class Coffee
   def self.info
     "MAth coffee"
   end
 end
end

puts BocoCafe::Coffee.info
#=> "BocoCafe!"

puts MathCafe::Coffee.info
#=> "MAth coffee"
```

- `モジュール名::クラス名`と書くことで、クラスの使い分けが可能に
- `BocoCafe::Coffee`
- `MathCafe::Coffee`

<br>

- モジュールには、クラスメソッド、定数を定義出来す
- モジュールの中の定数を使うときは、`::`でモジュール名と定数を繋ぐ

<br>

## 別ファイルのクラスやモジュールを読み込む

- `require_relative "<ファイル名>"`と書くことで、<ファイル>で定義したクラスやモジュールを使うことができる
- <ファイル名>には、`.rb`などの拡張子は省略可能

```
# whippe.rb
module WhippedCream
 def whipped_cream
   @name += "whippe"
 end
end
```

<br>

```
# drink.rb
require_relative "whipee"
class Drink
 include WhippedCream
 def name
   @name
 end
 def initialize
   @name = "latte"
 end
end

latte = Drink.new
latte.whipped_cream
puts latte.name #=> lattewhippe
```

1. `whippe.rb`にて、`WhippedCreamモジュール`を定義
2. `drink.rb`内で、`require_relative "whippe"`と書き、`whippe.rb`を使用することを宣言(?)
3. `include WhippedCream`で、`WhippedCreamモジュール`に定義したメソッドが使えるように

<br>

## `require_relative`と`require`

- `require_relative`は、別のファイルを読み込むためのメソッド
- `require`は、現在のフォルダにあるファイルであれば読み込むことが出来る

### 不安なら`require_relative`を使え

<br>

- `include`には、モジュール名を渡す
- `require_relative`には、ファイル名を渡す

<br>