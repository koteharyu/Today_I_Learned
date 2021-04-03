## hash

<br>

- `symbol`とは、Symbolというクラスのオブジェクトで、何かしらの名前を表す存在である。

hashのバリエーション

- 文字列をキーに
  - `{"tokyo" => 122434 , "kanagawa" => 247298 }`
- ハッシュロケットの代わりにコロンを使う
  - `{"tokyo": 122434, "kanagawa": 247298 }`
- シンボルをキーに
  - `{ :tokyo => 113432, :fukuoka => 2324 }`
- シンボルをキー　コロンバージョン
  - `{ tokyo: 1214, fukuoka: 2425}`
- 数字をキーに
  - `{ 13 => 1213, 32 => 14314}`

- キーが文字列か、シンボルであれば`コロン`を使うことができる

<br>

## initialize

<br>

- `イミュータブル[immutable]オブジェクト`とは、Userクラスのオブジェクトをnewメソッドで作成する際に、名前・住所・アドレスを設定し、それ以降は変更しないような、読み出し専用を意図して作られているオブジェクトのこと

```
class User
  attr_accessor :name, :address, :email
  def initialize(name, address, :email)
    @name = name
    @address = address
    @emial = email
  end
end

user = User.new("haryu", "1-1-1", "ex@s.com")
```

<br>

## メソッドの呼び出しに制限をかける

<br>

- `private`

```
class Person
  def initialize(money)
    @money = money
  end

  #　億万長者か判断するためのメソッド
  def billionaire?
    money > 100000000
  end

  private
  def money
    @money
  end
end
```

このように、`private`以下に書いたメソッドは、オブジェクトの外部から利用することができなくなる

<br>

```
person = Person.new(1230000000)
puts person.billionaire?
#= true
puts person.money
#=> private method `money' called for #<Person:0x0000000148896888 @money=1230000000> (NoMethodError)
```

のように、億万長者かどうかは判断できるけど、その人がいくら持っているかの情報は見せないようにできる！

- `initializeメソッド`は、`privateメソッド`

<br>

- `オーバーライド`とは、親クラスが持つメソッドの処理を、子クラスに書かれた処理で上書きすること
- `super`とは、子クラスのメソッドの中で親クラスの同名のメソッドを呼び出す際に使う記法

memo) 親クラスと子クラスでsuperするメソッド名は同じじゃないとだめよ！

<br>

- `module`  `include`
- `module`を作ることで、部分的な設計書を実現できるため、複数の似たクラスを簡単に実現できる
- `Mix-in(ミックスイン)`とは、モジュールをクラスに取り込んで振る舞いを追加すること

## クラスメソッド

- `has_manyメソッド`もクラスメソッドの一種

## 例外

- `raiseメソッド`とは、自分で例外を発生させるメソッド

```
irb>
raise ZeroDivisionError, "hello, error!"
#=> ZeroDivisonErrorのエラーメッセージが出現
```

<br>

- `RuntimeError` 一般的な例外
- 自分で例外を作成する時は、`StandardError`を継承するように

```
irb>
class NoMoneyError < StandardError; end
raise NoMoneyError, "no Money"
#=> 自作の例外を発生できる
```

<br>

Rubyでは、例外が発生するとプログラムが終了する

Railsでは、例外が捕捉され、最終的にブラウザにエラー画面が表示される

<br>

例外を捕捉するには、例外が発生するかもしれないコードを`begin`の中に記述し、その中で発生した例外への対応の仕方を`rescue`節の中で記述する。さらに例外が出た場合も、出なかった場合も必ず行たい後処理を`ensure`節に書くことができるが、`ensure`節はなくても良い。

```
begin
  (例外が発生するかもしれないコード)
resuce
  (例外に対応するコード)
ensure
  (例外が発生してもしなくても必ず実行したいコード)
```

<br>

メソッド内の処理全体に対して例外処理を行たい場合は、beginを使わずに記述できる　
```
def メソッド名
  (method処理)
rescue
  (例外に対応するコード)
ensure
  (例外発生してもしなくても必ず実行したいコード)
end
```

<br>

beginの中で`do_something`というメソッドを実行し、もし実行中に自作の`SomeSpecialError`が発生したら捕捉して、例外オブジェクトを`e`という変数に受け取り、例外の内容を出力してそのままプログラムを実行する
```
begin
  do_something
rescue SomeSpecialError -> e
  puts "#{e.class}(#{e.message})が発生しました。処理を続行します"
end
```

上記では、`rescue節`で、捕捉するクラスを指定しているが、クラスを省略することも

```
rescue -> e
```

省略すると、`StandardError`及び、その子クラスの例外を捕捉する。が、さまざまなエラーは`StandardError`を継承してるから、この方法で捕捉することができる。また、例外オブジェクトを変数として受け取る必要がなければ、その部分の記述を次のように省略して書くことができる

```
rescue SomeSpecialError
```

<br>

## nilガード

```
number ||=  10
```
もしもnumberがあればnumber、なければnumberに10を代入した上でのnumberになる

つまり、numberが真であれば(nilやfalseでない)numberをそのまま、nil falseであれば10を代入

```
def children
  @children ||= []
end
```

もしchildrenがnil falseであれば、[] からの配列を代入する

<br>

## &. ぼっち演算子

- `&.`は、もしnilだったら代入するとう構文

- `self navigation operator`

<br>

- ifを使った記述方

```
name = if object
  object.name
else 
  nil
end
```

- 三項演算子を使った記述方

```
name = object ? object.name : nil
```

- ぼっち演算子を使った記述方

```
name = object&.name
```

<br>

## %記法

%記法を使うことで、ソースコードの記述量を減らすことができる

<br>

- `%w`記法を使うことで、全ての文字列である配列を作ることができる

```
arry = ["apple","banana","orange"]
ary = %w(apple banana orange)
```

- `%i`記法を使うことで、要素がシンボルである配列を簡潔にかける

```
ary2 = [:apple, :banana, :orange]
ary2 = %i(apple banana orange)
```

<br>

- ブロックとは、`do ~ end`までのこと

ユーザーの名前を取り出して、配列を作り直す

```
class User
  attr_accessor :name
end

user1 = User.new
user1.name = "haryu"
user2 = User.new
user2.name = "saya"
user3 = User.new
user3.name = "kaka"

users = [user1, user2, user3]

names = []

names = users.map(&:name)
```
