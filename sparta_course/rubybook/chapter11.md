## 例外処理

```
begin 
 (例外が発生する可能性がある処理)
rescue
 (例外が発生した時に実行する処理(rescue節))
end
```

- rescue節は、例外が発生しないと実行されない

```
puts "enter bill"
bill = gets.to_i
puts "enter how many people"
number = gets.to_i

begin 
 warikan = bill / number
 puts "#{warikan}$ per 1"
rescue ZeroDivisionError
 puts "do not 0 person"
end
```

- メソッド内に例外処理を書く場合は、`begin`と`end`を省略して書ける。

```
def warikan(bill, number)
 warikan = bill / number
 puts "#{warikan}$ per 1"
rescue ZeroDivisionError
 puts "do not 0 person"
end
```

<br>

上記の例は、例外処理の方法を理解するためのもの。本来なら、想定外の問題が発生したときに使うもの。0が入るなど想定できることは、例外処理を使わずに事前に値をチェックする方が良いプログラム

```
def warikan(bill, number)
 if number.zero?
   puts "do not 0 person"
   return
 end
 warikan = bill / number
 puts "#{warikan}$ per 1"
end
```

<br>

本来、例外処理を使う場面は、ファイルが開けなかったり、ネットワークに繋がらなかったりする場合。

<br>

## 例外の詳細を調べる方法

```
begin
///
rescue SystemCallError => e
 puts "例外クラス:#{e.class}"
 puts "例外メッセージ:#{e.message}"
end
```

例外オブジェクトを変数`e`に代入する

<br>

- すべての例外は、`Exceptionクラス`を継承している。
- `StandardErrorクラス`は、通常のプログラムでよく発生する例外を束ねるクラス。もちろん、`Exceptionクラス`を継承している

<br>

## raiseメソッド

- `raiseメソッド`とは、例外を発生させるメソッドのこと
- `RuntimeError`とは、raiseメソッドで例外メッセージのみを指定した場合に出るエラー
- `ScriptError`とは、`raise ScriptError, "例外メッセージ"`のようにScriptErrorが発生するように指定が出来る。

<br>

## ensure　例外の有無にかかわらず必ず処理を実行させる

```
begin 
 (例外が発生する可能性のある処理)
rescue
 (例外が発生したときに実行する処理)
ensure
 (例外の有無に関わらず実行される処理)
end
```

<br>

## まとめ

- 例外を使うことで正常な処理と例外処理を分けることができる
- 発生した例外は`rescue節`で受け取れる
- raiseメソッドで例外を発生できる
- 例外の有無に関わらず実行したい処理を`ensure節`に書く

<br>

- `attr_reader`とは、「同名のインスタンス変数を戻り値とするメソッドを定義する」メソッド。`attr_reader`の後ろに、インスタンス変数から`@`を取り除いた名前をシンボルで書く。

```
class Drink
 attr_reader :name
 def name=(text)
   @name = text
 end
end

drink = Drink.new
drink.name = "latte"
p drink.name #=> latte
```

<br>

- `attr_writer`とは、「同名のインスタンス変数へ代入するメソッドを定義する」メソッド。

```
def name=(text)
 @name = text
end

↓のように、書き換えることができる

attr_writer
```

`attr_reader`と`attr_writer`を組み合わせると以下のように書ける

```
class Drink
 attr_reader :name
 attr_writer :name
end

drink = Drink.new
drink.name = "latte"
p drink.name #=> latte
```

<br>

- `attr_accessor`とは、`attr_reader`と`attr_writer`を兼ね備えたオールインワン

```
class Drink
 attr_accessor :name
end

drink = Drink.new
drink.name = "latte"
p drink.name #=> latte
```

<br>

## self

selfは、その場所でのレシーバーを返すもの。レシーバーとは、メソッドを呼び出されるオブジェクト

- selfは、その場所で、メソッドを呼び出すときのレシーバーのオブジェクトを返す
- インスタンスメソッドでのselfは、そのクラスのインスタンスになる
- クラスメソッドでのselfは、そのクラスになる
- selfは、nil、true、falseと同様に予約後のため、変数として代入できない

<br>

## クラスメソッドとインスタンスメソッドでのインスタンス変数は別物

```
class Drink
 def name # インスタンスメソッド`name`を定義
   @name = "latte" # インスタンスメソッドのインスタンス変数`@name`へ代入
 end

 def self.name # クラスメソッド`name`を定義
   @name # クラスメソッドのインスタンス変数`@name`を返す
 end
end

drink = Drink.new #Drinkクラスのインスタンスオブジェクト
drink.name # インスタンスメソッドの`name`を呼び出し
p Drink.name #=> nil # クラスメソッドの`name`を呼び出すとnilになる
```

<br>

## クラス変数とは

- `クラス変数`とは、クラスで共有される変数。継承したクラスでも共有することができる。`@@name`のように`@@`を頭に付ける

<br>

## 正規表現

`match?メソッド`/検索したい文字列/

```
p "tea latte".match?(/latte/) #=> true
p "coffee latte".match?(/latte/) #=> true
p "mocha".match?'(/latte/) #=> false
```

<br>

正規オブジェクト

```
/正規表現パターン/
```

<br>

match?メソッド

```
"文字列".match?(/正規表現パターン/)
```

<br>

- `\z`は、文字列末尾にマッチするパターンを検索 `小文字！`

```
p "cafe latte".match?(/latte\z/) #=> true
p "tea latte".match?(/latte\z/) #=> true
p "latte art".match?(/latte\z/) #=> false
```

<br>

- `\A文字列`は、先頭が文字列で始まるかを検証 `大文字！`

```
p "cafe latte".match?(/\Alatte/) #=> false
p "tea latte".match?(/\Alatte/) #=> false
p "latte art".match?(/\Alatte/) #=> true
```

<br>

- `[文字群]`とは、`[]`で囲むと、中の文字群のどれか1文字とマッチする。`/[abc]/`は、aまたはbまたはcとマッチする。`/[A-Za-z0-9]/`と範囲指定で書くと、アルファベット大文字小文字と数字のいずれか１文字にマッチする

<br>

- `.`は、任意の１文字にマッチする。たとえば、`/a.c/`は`abc`や`adc`などとマッチする

<br>

- `*`は、前の文字が0回以上繰り返す時にマッチする。たとえば、`/ab*c/`は、`abc`や`abbbc`や`ac`にマッチする

<br>

- `+`は、前の文字が1回以上繰り返すときにマッチする。たとえば、`/a.+c/`は、`abbbc`や`abc`にマッチする。少なくとも、1回以上は繰り返さなけれあばならないので、`ac`にはマッチしない。

<br>

## ifとmatchを組み合わせる

```
["latte","cafe latte","mocha","coffee"].each do |drink|
 puts drink if drink.match?(/latte/)
end
```

##　条件と合致する文字列を置換する

- `gsubメソッド`とは、文字列の中で条件と合致する部分を置換することができる。１つ目の引数に置換元となる文字列や正規表現を、２つ目に置換先の文字列を書く。文字列中に複数の該当箇所があるときは、すべて置換する。また、破壊的にオブジェクトを変更するgsub!メソッドもある。

```
p "cafe latte".gsub("cafe", "tea") #=> tea latte
p "latte latte".gsub(/\Alatte/, "cafe") #=> cafe latte
p "latte latte".gsub("latte", "cafe") #=> cafe cafe
```
<br>

## 渡されたブロックを実行する

- `block_given?`メソッドは、ブロックが渡されたかどうかを判定するメソッド。

```
def foo
 p block_given?
end

foo #=> false

foo do 
end #=> true
```

<br>

```
def dice
 if block_given?  # ブロックが渡されたか？
                  # ブロックを渡された時の処理
   puts "run block" 
   yield  # 渡されたブロックを実行
 else

   puts "nomal dice"
   puts [1,2,3,4,5,6].sample
 end
end

# ブロックを渡さないとき
dice

# ブロックを渡すとき
dice do 
 puts [4,5,6].sample
end

#=> normal dice
   4

#=> run block
   6
```

<br>

## 渡されたブロックを引数で受け取る

- `&`は、ブロックを受け取る引数の先頭に付ける
- `callメソッド`は、変数に代入したブロックを、実行するためのメソッド
- `Procオブジェクト`は、ブロック処理をオブジェクト化したもの

```
def foo(&b)   # 引数ｂは先頭に`&`がついているので、ブロックを受け取って代入される
 b.call      # 渡されたブロックを実行
 b.class    #=> Proc
end

　　　　　　　 # fooメソッドをブロックを渡して呼び出し
foo do 
 puts "Chunky bacon!" #=> Chunky bacon!
end
```