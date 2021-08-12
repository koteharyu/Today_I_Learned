# undefined method flash for

Rails APIモードで開発をしている際に、`undefined method `flash=' for #<ActionDispatch::Request:0x000000012a199a08>`のエラーが出たため、この解決策について調べたことをまとめる

### 現状

```rb
user:
  :name,
  :email,
  :password,
  :password_digest
```

```rb
class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    user.save!
    render json: user
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

curlにてユーザーを新規作成してみる

```
$ curl -X POST -d '{"name": "test", "email": "test@example.com", "password": "password", "password_confirmation": "password"}' -H "Content-Type: application/json" http://localhost:3000/api/users

NoMethodError at /api/users
===========================

undefined method `flash=' for #<ActionDispatch::Request:0x000000012a199a08>

> To access an interactive console with this error, point your browser to: /__better_errors


actionpack (6.0.4) lib/action_controller/metal/request_forgery_protection.rb, line 167
--------------------------------------------------------------------------------------

``` ruby
  162
  163           # This is the method that defines the application behavior when a request is found to be unverified.
  164           def handle_unverified_request
  165             request = @controller.request
  166             request.session = NullSessionHash.new(request)
> 167             request.flash = nil
  168             request.session_options = { skip: true }
  169             request.cookie_jar = NullCookieJar.build(request, {})
  170           end
  171
  172           private
```

`api_only = true`の指定をしているため`flash`についてのエラがー出るのは不思議である。

### 解決策

`config/application.rb`に以下を追記

```rb
config.middleware.use ActionDispatch::Flash
```

おそらくAPIモードであっても、500エラーが返った際に`flash`を使用するコードがどこかに書かれているのだろうという結論だが、それがどこにあるかはまた今度のお話に...
