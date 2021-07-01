# JWTの実装例

[この記事の続き~]()

## Gemのインストール

```Gemfile
gem 'active_model_serializers'
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'　# コメントアウト
```

`active_model_serializers`...レスポンスを簡単に、かつ綺麗にJSON形式に整形してくれるgem。より詳細には[こちらで...]()

`bcrypt`...パスワードのハッシュ化を行うgem。使用するには`password_digest`カラムと、`has_secure_password`メソッドが必要。

`has_secure_password`メソッド...DBには対応しないpasswordカラムとpassword_confirmationカラムを擬似的に生成する

## ルーティング

```ruby
Rails.application.routes.draw do
  root 'home#index'
  namespace :api do
    resources :users, only: %i[create]
    resources :sessions, only: %i[create, destroy]
  end
end
```

api開発は、基本的にapi, v1などのネームスペースを切ってバージョン管理をしやすくする

## Model

仮に以下のようなUserModelがあるとする

```ruby
name: string, null: false
emai: string, null: false
password_digest: string, null: false

class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true
end
```

## ApplicationController

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  class AuthenticationError < StandardError; end

  rescue_from ActiveRecord::RecordInvalid, with: :render_422
  rescue_from AuthenticationError, wiht: :not_authenticated

  def current_user
    @current_user ||= Jwt::UserAuthenticator.call(request.headers)
  end

  def authenticate
    raise AuthenticationError unless current_user
  end

  private

  def render_422(exception)
    render json: { error: { messages: expection.record.errors.full_massegas } }, status: :unprocessable_entity
  end

  def not_authenticated
    render json: { error: { messages: ['please login'] } }, status: :unauthorized
  end
end
```

applications_controllerには、エラーに関する処理を記載する

`protect_from_forgery with:`メソッド...自動でCSRF対策を行うための設定。

`:null_session`オプションは...トークンが一致しなかった場合にsessionを空にするためのオプション

`class AuthenticationError < StandardError; end`...例外を束ねているStandardErrorクラスを継承させた独自のAuthenticationErrorクラス

`rescue_from`...例外処理

`rescue_from ActiveRecord::RecordInvalid, with: :render_422`...ActiveRecord::RecordingInvalid(Rails自前のバリデーションエラー)が起きは場合に、render_422を実行させる例外処理

`rescue_from AuthenticationError, wiht: :not_authenticated`...AuthenticationErrorが発生した場合に、not_authenticatedメソッドを実行させるという例外処理

`current_user`メソッド...現在ログイン中のユーザーかどうかを判定するメソッド。Jwt::UserAuthenticatorで定義したcallメソッドを呼ぶ。引数にはリクエストのヘッダー情報を指定する。また、user情報が取得できた場合は、@current_userに代入(メモ化)され、取得できなければfalseを返す

`authenticate`メソッド...current_userメソッドがfalseを返した場合(現在ログイン中のユーザーでなければ)、AuthenticationErrorを発生させるメソッド。`raise`は手動でエラーを発生させるメソッド

`render_422`, `not_anthenticated`...JSON形式でエラーメッセージとstatusを返すメソッド

## Api::SessionsController

続いて、先ほど編集したApplicationControllerを継承させたApi::SessionsControllerを定義していく

```ruby
class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(email: session_params[:email])
    if user&.authenticate(session_params[:password])
      token = Jwt::TokenProvider.call(user_id: user.id)
      render json: ActiveModelSerializer::SerializableResource.new(
        user,
        serializer: UserSerializer
      ).as_json.deep_merge(user: { token: token} )
    else
      render json: { error: { messages: ['mistake email or password'] } }, status: :unanthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

`token = Jwt::TokenProvider.call(user_id: user.id)`...TokenPrividerというサービスファイルで定義したcallメソッドを呼び出し、引数であるuser_idを元にトークンを取得する

`ActiveModelSerializer::SerializableResource.new`...新しくserializserインスタンスを作成する。通常は、serializerファイルを作っていればこのように記述する必要がなくなるが、sessionの中身はuserモデルと同じなので、user情報とuserのserializerを引数にとり、その情報を元にserializerインスタンスを作成している。

`as_json`...作成したserializerの形式をJSON形式に変換させるメソッド

`deep_merge(user: { token: token })`...UserSerializerにuserの持っているtoken情報を結合させている。ハッシュの中にハッシュがある場合に`deep_merge`メソッドを使う

## Api::UsersController

```ruby
class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    user.save!
    render json: user, serialziser: UserSerializer
  end

  private

  def user_params
    params.require(:user).permit(:emai, :name, :password, :password_confirmation)
  end
end
```

## UserSerializer

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
end
```

## services/jwt/user_authentication.rb

```ruby
module Jwt::UserAuthentication
  extend self

  def call(request_headers)
    @request_headers = requrest_headersss
    begin
      payload, = Jwt::TokenDecryptor.call(token)
      User.find(payload['user_id'])
    rescue StandardError
      nil
    end
  end

  private

  def token
    @request_headers['Authorization'].split(' ').last
  end
end
```

`extend self`...レシーバーが`module Jwt::UserAuthentication`そのものであり、module内で定義したメソッドが`Jwt::UserAuthentication.メソッド名`として使えるようにするための記述。

`call(request_headers)`メソッド...ApplicationControllerのcurrent_userメソッド内で呼ばれているメソッド。extend selfと記述したため、`Jwt::UserAuthentication.call(request.headers)`で呼び出すことができている

`begin rescue end`...例外処理。begin内にエラーが起きそうなアクションを定義し、rescue内にエラーが起きた際のアクションを定義する。

`rescue StandardError`...特定のStandardErrorと指定している。つまり、StandardErrorが発生したらnilを返すということ。

`payload, = Jwt::TokenDecryptor.call(token)`...services/jwt配下にあるtoken_decryptorファイルにあるcallメソッドを呼び出し、payload,に格納する。ちなみに。`,`はタイポではない。`payload,_`と書く場合も多く、`_`にヘッダー情報が格納される。実際にこのコードでは、トークンを暗号化しており、その際に、payloadの属性情報と一緒にヘッダー情報も返している

`User.find`...取得したpayloadのuser_idの情報を元にuserを探す。そしてapplication_controllerのcurrent_userに代入される

`token`メソッド...ヘッダーのauthorizationのtokenのみを取得している。ちなみに、request_headersの中身は、`Authorization: Bearer tokentokentoken...`
となっているため、tokenだけを取得するように記述している

## services/jwt/token_decryptor.rb

```ruby
module Jwt::TokenDecryptor
  extend self

  def call(token)
    decrypt(token)
  end

  private

  def decrypt(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base)
    rescue StandardError
      raise InvalidTokenError
    end
  end
end

class InvalidTokenError < StandardError; end
```

`decrypt`メソッド...引数のtokenを元に復号化している。復号には、railsの秘密鍵が必要になるため、第二引数として指定する

`call`メソッド...復号化のためのメソッド。user_authentication.rbで特定のuserを探すために暗号化されたトークンを復号化している

## services/jwt/token_provider.rb

```ruby
module Jwt::TokenProvider
  extend self

  def call(payload)
    issue_token(payload)
  end

  private

  def issue_token(payload)
    JWT.encode(payload, Rails.application.creadentials.secret_key_base)
  end
end
```

`issue_token`メソッド...引数のpayload(今回はuser_id)を元に暗号化させるためのプライベートメソッド。暗号化するには復号化同様Railsの秘密鍵が必要になるため、第二引数として指定する

`call`メソッド...暗号化のためのメソッド。このメソッドは、sessions_controllerから呼ばれるメソッドだが、user_idを元にtokenを暗号化している

## まとめ

ログイン時の流れ

1. ログインリクエストがフロントから送られる
2. ルーティングでsessionsコントローラーに振り分けられる
3. リクエストのemailとpassword情報が正しければ、暗号化してレスポンスを送る

ログイン時しかできないアクションの流れ

1. リクエストを送る
2. ルーティング該当のコントローラーに振り分ける
3. コントローラー内でcurrent_userメソッドが呼ばれる
4. リクエストを暗号化し、特定のユーザーを探す
5. userがいればcurrent_userに格納する
