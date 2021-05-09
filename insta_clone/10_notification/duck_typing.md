# ダックタイピングについて

ポリモーフィズムの前提知識として`ダックタイピング`, `インターフェース`を勉強する必要があるとのことなので調べてみた。

<br>

## ダックタイピング

> "if it walks like a duck and quacks like a duck, it must be a duck"
> もしもそれがアヒルのように歩き、アヒルのように鳴くなら、それはアヒルだよ

```
class Animal
  def initialize(animal)
    @animal = animal
  end

  def dark
    @animal.sound
  end
end

def Dcuk
  def sound
    `quack`
  end
end

def Cat
  def sound
  `myaa`
  end
end

#使い方
Animal.new(Duck.new).dark #=> 'quack'
Animal.new(Cat.new).dark #=> 'myaa'
```

ダックタイピングのメリット・特徴

- `Animal`クラスの`@animal`に入るオブジェクトは、`#sound`を呼べるオブジェクトであること
- `#sound`が存在すること、`#sound`の返り値の形式が同じこと　が守られていれば、引数となるクラスは`#dark`メソッドの内部実装を知る必要がないし、手を加える必要がない

もし、Dogクラスを追加した場合も以下の様に、既存のコードはいじらずに、新しく追加するコード側のインターフェースだけ気をつければ良くなるので、複雑度をあげずに実装できる

```
class Dog
  def sound
    'bow-bow'
  end
end

Animal.new(Dog.new).dark #=> 'bow-bow'

#既存のコードには手を咥えてないため、もちろん挙動は同じ
Animal.new(Duck.new).dark #=> 'quack'
Animal.new(Cat.new).dark #=> 'myaa'
```

<br>

## インターフェース

`ダッグタイピング`とは、「違うものがある決まった振る舞い/入出力を持つことで、同じ様に扱える様にすること」

`インターフェース`とは、その「歩きまった振る舞い」「入出力の定義」のこと

`ポリモーフィック`とは、ダッグタイピングの一種

[Railsのポリモーフィック関連とはなんなのか](https://qiita.com/itkrt2y/items/32ad1512fce1bf90c20b)
