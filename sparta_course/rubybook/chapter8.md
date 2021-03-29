## chapter 8 Class

- `class`とは、オブジェクトの種族を表すもの。
- `インスタンス`とは、クラスに属するオブジェクトのこと
 - クラスから作ったオブジェクト
 - そのクラスに属する
- オブジェクトは、所属するクラスが用意しているメソッドを使うことが出来る
 - `even?メソッド`は、Integerクラスのオブジェクトが偶数かどうかを判断するためのメソッド。もちろんStringやArrayクラスのオブジェクトなどには使えない。

- `class.new` そのクラスのオブジェクトを作成する記法
 - `String.new` #=> 空の文字列オブジェクトを作成
 - `String.new("latte")` #=> `latte`という文字列オブジェクトが作成
 - `Array.new` #=> 空の配列オブジェクトを作成
 - `Array.new("its","me")` #=> `["its","me"]`という配列オブジェクトを作成
 - `Integreクラス`には、`newメソッド`は用意されていない

- クラスの命名規則 
 - Drink,Itemのように`1文字目は大文字`、`2文字目以降は小文字`にする
 - `キャメルケース`　CaffeLatteのように2単語以上を組み合わせる場合は、区切り文字大文字にする。(ラクダのこぶ)

- クラスも実はオブジェクト
 - `p Drink.class #=> Class`

- クラスに定義したメソッドを呼び出す

```
class Drink
 def name
   "CaffeLatte"
 end
end

drink = Drink.new
puts drink.name  #=> CaffeLatte
```

1. Drinkクラスの作成
2. 変数drinkへDrinkクラスのオブジェクトを代入
3. 変数drinkに対して、nameメソッドを呼び出させる

- `レシーバー`とは、メソッドを呼び出されるオブジェクトのこと。
 - drinkはnameメソッドによってのレシーバー

- `methodsメソッド`とは、そのレシーバーに使えるメソッドを返すメソッド
 - `drink.methods` #=> 使えるメソッドがいっぱい

- クラスの中で同じクラスのメソッドを呼び出す

```
class Drink
 def order(name)
   puts "#{name} #{topping}"
 end
 def topping 
   "choco"
 end
end

cafe = Drink.new
cafe.order("latte")

#=> latte choco
```

`orderメソッド`が`toppingメソッド`を呼び出している？（表現が合っているか微妙）だが、解釈としては、toppingと経由してorderが呼ばれている感覚

- `selfメソッド`とは、クラス内で定義したメソッドのレシーバーを調べるためのメソッド
 - メソッド内に　`p self`と書くことで、そのメソッドのレシーバーがわかる

- `インスタンス変数`とは、先頭に`@`を付けることで作ることができる。ローカル変数のスコープは、そのメソッド内であることに対して、インスタンス変数は、同じオブジェクトであれば、複数のメソッドを跨いで使うことが出来る
 - もし、代入されていないインスタンス変数を使おうとすると`nil`が返ってくる
 - インスタンス変数の寿命は、それを持つオブジェクトの寿命と同じ

```
class Drink
 def order(item)
   puts "#{item} please"
   @name = item # @nameというインスタンス変数に引数itemの値を代入
 end
 def reorder
   puts "#{@name} one more please"
 end
end

drink = Drink.new
drink.order("latte")
drink.reorder
```

<br>

- インスタンス変数を取得するメソッドの作成

㈰で`@name`を取得したい場合、以下のようなインスタンス変数を取得するメソッド定義しておけば、オブジェクトの外でも取得することができる

```
class Drin
 def order(item)
   puts "#{item} please"
   @name = item
 end
 def name
   @name 
 end

 drink = Drink.new
 drink.order("latte")
 # ㈰ここでインスタンス変数を取得したい
 puts drink.name  #=> latte
```

- インスタンス変数を取得するメソッドは、習慣的にインスタンス変数の`@`を取り除いたメソッド名にすることが多い
- ここでいうnameメソッドを１行で定義できる`attr_reader`メソッドがある（後述）

- インスタンス変数へ代入するメソッド

```
class Drink
 def name=(text) # 1
   @name = text # 3
 end
 def name 
   @name
 end
end

drink = Drink.new
drink.name= "latte" # 2
puts drink.name
```

1. `name=`メソッドを定義。このメソッドは引数で渡したオブジェクトを`@name`へ代入
2. `name=`メソッドを呼び出して、引数として`latte`を渡す
  1. `drink.name = "latte"`と書くことも可能
3. 引数で渡された`latte`をインスタンス変数`@name`に代入

<br>

- `instance_variablesメソッド`とは、オブジェクトに対して使うことで、オブジェクトが持っているインスタンス変数を全て返すメソッド

<br>

## `initializeメソッド`

- `initializeメソッド`とは、オブジェクトが新しく作られるときに、自動で呼び出されるメソッドのこと

```
class Drink
 def initialize  # 1
   puts "新しいオブジェクト"
 end
end

Drink.new  # 2

#=> 新しいオブジェクト
```
1. 他のメソッドの定義と同じ手順で定義できる。メソッド名を`initialize`にするだけ
2. `newメソッド`が呼ばれるとオブジェクトが作られ、その際に`initializeメソッド`が自動で呼ばれる

<br>

initializeメソッドで、インスタンス変数の初期値を設定できる

```
class Drink
 def initialize
   @name = "latte" # 1
 end
 def name 
   @name
 end
end

drink = Drink.new # 2
puts drink.name # 3

#=> latte
```

2で、Drink.newで新しいオブジェクトが作られた際にinitializeメソッドが呼ばれ

1で、インスタンス変数`@name`に"latte"が代入される

3で、nameメソッドを呼ぶと、戻り値は1で代入した"latte"になる

<br>

initializeメソッドに引数を指定する

```
class Drink
 def initialize(name)
   @name = name
 end
 def name
   @name
 end
end

drink1 = Drink.new("latte")
drink2 = Drink.new("coffee")
drink3 = Drink.new("mocha")

puts drink1.name #=> latte
puts drink2.name #=> coffee
puts drink3.name #=> mocha
```

<br>

メソッドの種類

- `インスタンスメソッド`とは、レシーバーがインスタンスであるメソッドのこと。
 - Drink.newで作成したdrinkというインスタンスに使ってたメソッドたち
- `クラスメソッド`とは、レシーバーがクラスであるメソッドのこと
 - `newメソッド`はクラスメソッドだよ！
 - `Drink.new` レシーバーがクラスでしょ？

<br>

クラスメソッドの定義方法 ~Cafeクラスに「welcome!」と返すwelcomeメソッドを定義~

```
class Cafe
 def self.welcome # クラスメソッドの定義は、self.メソッド名
   "welcome!"
 end
end

puts Cafe.welcome #=> welcome!
```

- クラスメソッドは、クラスが実行するので、オブジェクトを作ることなく呼び出すことが可能

## メソッド早見表

|名前|定義方法|呼び出し方法|レシーバー|ドキュメントでの記法|
|-|-|-|-|-|
|インスタンスメソッド|def メソッド名|インスタンス.メソッド|インスタンス|クラス名#メソッド名|
|クラスメソッド|def self.メソッド名|クラス.メソッド|クラス|クラス名.メソッド名|

<br>

`#記法`と`.記法`

- インスタンスメソッド
 - クラス名#メソッド名
- クラスメソッド
 - クラス名`.`メソッド
 - クラス`::`メソッド  Cafe::welcome

<br>

同じクラスのクラスメソッドを呼び出す

- クラスメソッドの中で同じクラスのクラスメソッドを呼ぶときは、インスタンスメソッドのときと同じように、メソッド名を書けばOK

- レシーバーを省略しない形でかくと、`self.クラスメソッド`or `クラス.クラスメソッド`になる

- インスタンスメソッドからクラスメソッドを呼ぶこともできる。`self.class.クラスメソッド` or `クラス.クラスメソッド`の書き方

- クラスメソッドからインスタンスメソッドを呼ぶことはできないので注意!!
 - クラスからは、レシーバーとなるインスタンスを決めることができないから

```
class Cafe
 def self.welcome
   "welcome!"
 end
 def self.welcome_again
   welcome + "thanks"
 end
end

puts Cafe.welcome_again #=> welcome! thanks

puts Cafe.welcome #=> welcome!
```

<br>

クラスメソッドの別の定義方法

- `class << self`

```
class Cafe
 class << self
   def welcome
     "welcome!"
   end
 end
end
```

<br>

- インスタンスメソッドはインスタンスに呼び出すメソッド
- クラスメソッドはクラスに対して呼び出すメソッド
- クラスメソッドは`def self.メソッド名`のようにメソッド名の前に`self`を書いて定義する

<br>

## 継承

```
class Item
  def name
    @name
  end
  def name=(text)
    @name = text
  end
end

class Drink < Item # 1
  def size
    @size
  end
  def size=(text)
    @size = text
  end
end

item = Item.new
item.name = "mafin"

drink = Drink.new
drink.name = "latte" # 2
drink.size = "tall"

puts "#{drink.name} #{drink.size} size"

#=> latte tall
```

- 1で、`class Drink < Item`のように定義すると、Itemクラスを継承空いたDrinkクラスを作ることができる。このDrinkクラスはItemクラスの全てのメソッドを受け継ぐことができる。つまりItemクラスの`nameメソッド`と`name=メソッド`を使うことができる

- ２で、Drinkクラスのオブジェクトへ呼び出している`name=メソッド`は、親クラスであるItemクラスの`name=メソッド`を使っている

- `スーパークラス`とは、ここでいう継承元であるItemクラスのこと

```
class クラス名 < スーパークラス名
end
```

<br>

- `ancestorsメソッド`とは、クラスの継承先を返すメソッド。親クラスとincludeしているモジュールを表示する。家系図のように親世代に向かって進む
  - `p Integer.ansestors`

<br>

親子のクラスで同名のメソッドを作った（使用した）場合、呼び出したインスタンスのクラスで定義したメソッドが使われる（継承関係を親へ親へと辿って、最初に該当したメソッド呼び出す）

<br>

Q.　では、親クラスのメソッドを使いたくなったら？

A.　`super`を使う

```
class Item
  def name
    @name
  end
  def name=(text)
    @name = text
  end
  def full_name # 1
    @name
  end
end

class Drink < Item
  def size
    @size
  end
  def size=(text)
    @size
  end
  def full_name #2
    super # 3
  end
end

item = Item.new
item.name = "haryu"

drink = Drink.new
drink.name = "latte"
drink.size = "tall"

puts drink.full_name #=> latte

puts "#{drink.name} #{item.name} yes" #=> latte haryu yes
```

<br>

- `public`と`private`

- `public`なメソッドは、言ったら通常のメソッド
- `private`なメソッドは、レシーバーを書かない形式でのみ呼び出せるようにするメソッド。privateにすることで、設計上の意図を他のプログラマーに伝えることができる

```
class Cafe
  def staff
    makanai
  end

  private
  def makanai
    "for the staff"
  end
end

cafe = Cafe.new
puts cafe.staff #=> for the staff

puts cafe.makanai =#> error
```

<br>

## privateなクラスメソッドを定義

- `private_class_method`をdefの前に書くことで、そのメソッドだけをprivateにすることができる

```
class Foo
  private_class_method def self.a
    "method a"
  end
end

p Foo.a

#=> error 呼び出すことができない
```

<br>

- privateよりも後ろで定義したメソッドはprivateなメソッドになる
- privateなメソッドはレシーバーを指定したオブジェクト.メソッド名の形式で呼び出しができなくなる
- クラスの中でprivateより前または、privateを書かずに定義したメソッド、及びpublicよりも後ろで定義したメソッドはpublicなメソッドになる
- publicなメソッドはオブジェクト.メソッド名の形式でも、レシーバーを指定しないメソッド名の形式でも呼び出しができる




