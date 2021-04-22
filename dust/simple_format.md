## simple_formatメソッドについて

- simple_formatメソッドは、改行文字を含むテキストをブラウザ上で表示させる時に使うヘルパーメソッド
 - 文字列を`pタグ`で囲む
 - 改行には、`brタグ`を付与
 - 連続した改行には、`pタグ`を付与

<br>

## ERBとSlimでの記述方法　

```
<%= simple_format(入力値)%>
= simple_format(入力値)
```

<br>

## sanitizeオプションについて

- sanitizeオプションを付けることで、一部の危険なHTMLタグを取り除いてくれる。一部ではなく、全てのHTMLタグを安全に表示したい場合は、`hオプション`を使う

```
= simple_format(入力値, sanitize: true)
```

<br>

## hオプションについて

- `hオプション`をsimple_formatに付け加えることで、与えられたテキストにhtmlタグが埋め込まれている場合に、エスケープすることが可能。ただし、scriptタグに関しては除去される。

```
= simple_format(h(入力値))
```

<br>

エスケープ処理を行うオプションを追加することで、`XSS`(クロスサイトスクリプティング)攻撃を防ぐことが出来る

<br>

## 追記 2021/4/14

<br>

# simple_formatについて

`text_area`の入力データはそのままビューに出力しても、改行は反映されない

そのため、`simple_format`というRailsのヘルパーを使って、加工する

<br>

`simple_format`の特徴

1. 文字列を`<p>`で括る
2. 改行は`<br />`を付与
3. 連続した改行は`</p><p>`を付与

`= simple_format(text)`

<br>

`safe_join`とは、`<p>`で括りたくない場合に使う

`= safe_join(text.split("\n"), tag:(:br))`