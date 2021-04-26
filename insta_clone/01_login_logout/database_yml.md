## database.yml 

`&(アンカー)<アンカー名>`とは、名前を付ける機能

`*<アンカー名>`とは、エイリアスで、指定したアンカーを呼び出す機能


### credentials.yml.encを使って環境変数の設定

`$ EDITOR="vi" bin/rails credentials:edit`

```
# credentials.yml.enc

db:
 username: sample_user
 password: sample_password
```

```
# database.yml

default: &default
 username: <%= Rails.application.credentials.db[:username]%>
 password: <%= Rails.application.credentials.db[:password]%>
```

のようにして、credentialsに設定した環境変数を取り出す

[Railsのdatabase.ymlについてなんとなく分かった気になっていた記法・意味まとめ](https://qiita.com/terufumi1122/items/b5678bae891ba9cf1e57)
[database.yml](https://qiita.com/ryouya3948/items/ba3012ba88d9ea8fd43d)
[database.ymlのパスワード管理方法2パターン](https://qiita.com/d01masatooo11/items/b780dce36a61ad95a08b)
