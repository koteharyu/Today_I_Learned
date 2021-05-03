# メモ化ってなんだろ

<br>

## メモ化

メモ化とは...メソッドが最初に呼び出された時に戻り値がキャッシュされ、それ以降は、同じスコープ内でメソッドが呼び出されるたびにキャッシュされた値が返ること

以下のままだと、current_userのメソッドが呼び出されるたびにSQLが走り、パフォーマンスが悪くなってしまう。

```
def current_user
  User.find_by(id: session[:user_id])
end
```

そのため、メモ化を使って、キャッシュに残しておき、パフォーマンスを向上させようというわけ

`||=`...もしnilだったら〜してねって構文

今回の場合であれば、次のようにすることで、2回目以降、User.find_by(id: session[:user_id])の処理が走らなくなる

```
def current_user
  @current_user ||= User.find_by(id: session[:user_id])
end
```

[rails メモ化とは](https://qiita.com/kt215prg/items/3c0fd89468dcfe6075df)

<br>

## キャッシュ

キャッシュ（caching）とは、リクエスト・レスポンスのサイクルの中で生成されたコンテンツを保存しておき、
次回同じようなリクエストが発生したときのレスポンスでそのコンテンツを再利用すること。
