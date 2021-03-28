## chapter7 Method

- メソッドとは
- 「処理の部品」に名前をつけたもの
- メソッド定義（作成）は、`def`を行う
- メソッドは定義しただけでは中の処理は実行されない
- 定義したメソッドを呼び出すことで実行される
- メソッドはオブジェクトを呼び出し元に返す戻り値の仕組みがある
- メソッドで最後に実行した結果が戻り値になる

```
def メソッド名
  処理
end

メソッド名　#メソッド呼び出し
```

<br>

```
def area(x) #引数
  x * x
end

puts area(2) #引数が２　つまり　２＊２

#=> 4
```

<br>

- 引数とは、メソッドへオブジェクトを渡す機能のこと。複数の引数を渡すことができる。
- 戻り値とは、メソッドから呼び出し元へオブジェクトを返す機能のこと

<br>

- `return`とは、メソッドを途中で終わらせる手段
- `return`には戻り値を指定することもできる

```
def thanks_and_receipt(receipt)
  greeting = "thanks!"
  unless receipt  # 引数receiptがfalseであればこの行は処理される
    return greeting  # returnを実行し、変数greetingに格納されたオブジェクトを戻り値にする
  end
  greeting + "this is your receipt"
end

puts thanks_and_receipt(true)

#=> "thanks! this is your receipt"

puts thanks_and_receipt(false)

#=> "thanks!"
```

<br>

- methodの`()`は省略可能
- `area(2)`
- `area 2`
- 同じ意味

<br>

- 引数のデフォルト値の設定
  - 引数を指定しなかったら、いつもこの値を引数にすることを設定できる

```
def order(item = "coffee") # coffeeがデフォルト値
  "#{item}を下さい"
end

puts order #デフォルト値が引数になる
#=> coffeeを下さい

puts order("mocha")
#=> mochaを下さい

puts order(latte)
#=> latteを下さい
```

<br>

- `キーワード引数`とは、引数の順番を可変にできる手法
- 引数名の後ろに`:`をつけることでキーワード引数になる
- デフォルト値の指定も可能

```
def order(item:, size: "tall") #キーワード引数とsizeにデフォルト値を指定
  "#{item}を#{size}サイズで下さい"
end

puts order(item: "coffee", size: "big")
#=> coffeeをbigサイズで下さい

puts order(size: "small", item: "latte")
#=> latteをsmallサイズで下さい

puts order(item: "coffee")
#=> coffeeをtallサイズで下さい
```

<br>

- `ローカル変数`とは、定義したメソッド内だけで有効な変数のこと。（メソッドの前でも後ろでもだめ、中だけ！）
- `スコープ`とは、変数の有効な範囲と寿命のこと。メソッドの実行が終了すると、ローカル変数は破棄される。

<br>

## practice7-7

my answer

```
def price(item:, size:)
  if item == "coffee"
    case size
    when "short"
      puts 300
    when "tall"
      puts 350
    when "venty"
     puts 400
    end 
  elsif item == "latte"
    case size
    when "short"
      puts 300
    when "tall"
      puts 350
     when "venty"
       puts 400
    end
  else
    puts "nothing"
  end
end

price(item: "coffee" ,size: "short")
price(item: "coffee" ,size: "tall")
price(item: "coffee" ,size: "venty")
price(item: "coffee" ,size: "short")
price(item: "coffee" ,size: "tall")
price(item: "coffee" ,size: "venty")
price(item: "orange" ,size: "short")
price(item: "orange" ,size: "tall")
price(item: "orange" ,size: "ventyu")
```

correct answer

```
def price(item, size)
  if item == "coffee"
    item_price = 300
  elsif item == "latte"
    item_price = 400
  end 

  if size == "short"
    size_price = 0
  elsif size == "tall"
    size_price = 50
  elsif size == "venty"
    size_price = 150
  end

  puts item_price + size_price
end

price("coffee", "venty")
```

美しすぎる。あと簡潔、汎用性◎・コード量少ない・可読性高い

まけた