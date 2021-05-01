# slimでjqueryを書くときに使う｜ってなんだ？

```
# edit.html.slim

| $("#modal-container").html("#{j(render 'modal_form', comment: @comment)}");
| $("#comment-edit-modal").modal('show');
```

<br>

## 結論

`|`は、`パイプ`と言う

パイプを使うことで、`foo`,`bar`の間に改行が含まれないようにできる

```
| foo
| bar
```

<br>

`|`を使って複数行に渡って記述する方法

```
| foo
  bar

もしくは

|
  foo
  bar
```

<br>

JavaScriptで、`;`が省略できるのは、改行で区切られているときなので、改行がないとSyntaxError になってしまうので注意

<br>

[slimでjQueryを複数行書く](https://qiita.com/suzuki-r/items/c32ba16ab5090459e4a2)
