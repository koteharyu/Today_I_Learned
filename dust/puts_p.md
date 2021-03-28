# Rubyにおける`puts`と`p`メソッドの違い

## 疑問点

配列において、putsとpでは出力される値に違いがあることがわかった。

```
a = [1,2]
b = [3,4]
p a + b #=> [1,2,3,4]
puts a + b
#=> 1
#=> 2
#=> 3
#=> 4
```

<br>

## 結論

`puts`では、配列が引数として与えられた際に、`改行 + to_s`の処理が実行され、出力される

## 参考

[puts](https://docs.ruby-lang.org/ja/latest/method/Kernel/m/puts.html)

[p](https://docs.ruby-lang.org/ja/latest/method/Kernel/m/p.html)