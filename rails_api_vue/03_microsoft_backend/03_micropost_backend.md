# 03_micropost_backend

## each_serializer

`each_serilazlier`...複数のJSONオブジェクトを返す場合に使うメソッド。

```rb
microposts.each do |micropost|
  serializer: MicropostSerializer(micropost)
end
```

みたいなイメージだろうか。

## microposts/show

投稿詳細ページへのリクエストをした際に返ってくる`response.body`の中身をmicropostに絞って見てみた

```
json['micropost']
=> {"id"=>3,
 "content"=>"im post",
 "created_at"=>"2021-07-27T02:05:59.665Z",
 "updated_at"=>"2021-07-27T02:05:59.665Z",
 "user"=>
  {"id"=>1,
   "name"=>"post",
   "email"=>"post@example.com",
   "introduction"=>nil,
   "avatar_url"=>
    "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--435c19d9651ab9816ad87e8e0277100f1970196b/1627351847"
  }
}
```

userの情報が１つ深い階層にあるため、Specの際に`'user' => include('id' => micropost.user.id)`と書くことに納得。

## 404

存在しない投稿詳細ページへのリクエストがあった際にステータスコード404を返すようにする。

```rb
class ApplicationController < ApplicationController::Base
  class AuthenticationError < StandardError; end
  rescue_from ActiveRecod::RecordNotFount, with: :render_404

  private

  def render_404(execption)
    render json: { error: { messages: exception.message } }, status: :not_found
  end
end
```

JSONデータ

[![Image from Gyazo](https://i.gyazo.com/8d339d63ff29c0fab91d7651e89fc1b5.png)](https://gyazo.com/8d339d63ff29c0fab91d7651e89fc1b5)

console

[![Image from Gyazo](https://i.gyazo.com/00d690f304dbe931e22623fb66de3318.png)](https://gyazo.com/00d690f304dbe931e22623fb66de3318)

```
Completed 404 Not Found in 5ms (Views: 2.4ms | ActiveRecord: 0.2ms | Allocations: 2950)
```
