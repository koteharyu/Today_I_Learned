# モジュールのincludeのextendについて

## 先に結論

- `include`...モジュールのメソッドをインスタンスメソッドとして使用できる
- `extend`...モジュールのメソッドをクラスメソッドとして使用できる

<br>

## 例

例として、セリフを言わせるをphrasingというモジュールがあるとする

```
module phrasing
 def phrase(words)
   puts words
 end
end
```

phrasingモジュールをincludeすると、インスタンスメソッドとしてphraseメソッドが使えるようになる

```
class Doraemon
 include phrasing
end

doraemon = Doraemon.new
doraemon.phrase("僕ドラえもん")
```

<br>

phrasingモジュールをextendすると、クラスメソッドとしてphraseメソッドが使えるようになる

```
class Kureyonsinchan
 extend phrasing
end

Kureyonsinchan.phrase("春日部防衛隊ファイヤー！")
```

<br>

## included

moduleに`included`メソッドを定義しておくと、moduleがincludeされた時に呼び出される

```
module phrasing
 def self.included(base)
 end
end

class Doraemon
 include phrasing
end
```

流れの説明

Doraemonクラス内でphrasingモジュールをincludeすると、baseにDoraemonクラスが渡されるという流れ

[Rails: includeされた時にクラスメソッドとインスタンスメソッドを同時に追加する頻出パターン](https://www.techscore.com/blog/2013/03/01/rails-include%E3%81%95%E3%82%8C%E3%81%9F%E6%99%82%E3%81%AB%E3%82%AF%E3%83%A9%E3%82%B9%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%A8%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%83%A1/)

[さっぱりだが、いつか理解できるようになる](http://hir-aik.hatenablog.com/entry/2014/07/07/164238)

[ActiveSupport::Concern](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/concern.rb)

[ActiveSupport::Concernを読む](https://www.techscore.com/blog/2013/03/25/activesupport%E3%82%92%E8%AA%AD%E3%82%80-activesupportconcern/)
