# 01_login

## rails new

`$ rails new . --database=mysql --webpack=vue --skip-turbolinks`

`--webpack=vuew`...新規プロジェクトにvue.jsを追加するためのオプション

自分の場合、初回install時にmysqlについて怒られinstallできなかったため以下に対処方法を残しておく。

まずは、`$ bundle config build.mysql2 --with-opt-dir=/opt/homebrew/opt/openssl@1.1`をターミナルで実行する

次に、関係ないかもしれないが、gemのバージョンを以下のように指定する

```Gemfile
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
```

で、bundle isntallをすると正常にインストールできた。

## rails webpacker:install

次に、`$ bundle exec rails webpacker:install`を実行し、webpackerをinstrallする

## databaseの作成

`$ bundle exec rails s`をすると以下の画像のようなエラーが出たため

[![Image from Gyazo](https://i.gyazo.com/16122e2c145d3219b82cf33c103e90b7.png)](https://gyazo.com/16122e2c145d3219b82cf33c103e90b7)

`$ be rails db:create`コマンドでmysqlにdevelopmentとtest環境のデータベースを作成する

## git flow

1. gitignoreファイルを編集
2. リモートリポジトリを作成
3. git add .
4. git commit -m "initial commit"
5. リモートリポジトリの設定
6. git flow init
   1. 全てEnter
7. git push -u origin --all
8. git flow feature start 01_login

## 不要なファイルが生成されないように

```ruby
# config/application.rb

config.generators do |g|
  g.skip_routes true
  g.assets false
  g.helper false
end
```

`skip_routes true`...routes.rbを自動変更

`assets false`...JS,CSSファイルを自動生成しないように

`helper false`...helperファイルを自動生成しない

## GEMs 前処理

今回追加したgemを抜粋

```gemfile
gem 'slim-rails'
gem 'html2slim'
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'active_model_serializers'
gem 'faker'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'webdrivers'
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'
  gem 'pry-rails'
end
```

#### slim

`$ bundle exec erb2slim app/vies/layouts/ --delete`...既存のERBファイルを削除

#### annotate

`$ bundle exec rails g annotate:install`を実行することで、`lib/tasks/auto_annotate_models.rake`が作成される

`bundle exec rails db:migrate`することで、各モデルファイルにスキーマ情報がコメントで追記される

#### rubocop

`$ bundle exec rubocop --auto-gen-config`コマンドで設定ファイルを作成

.rubocop.ymlを以下のように設定

```
inherit_from: .rubocop_todo.yml

# 追記した規約ファイルの読込
require:
  - rubocop-rails

# This file overrides https://github.com/bbatsov/rubocop/blob/master/config/default.yml

AllCops:
 # 除外ファイル
  Exclude:
    - 'vendor/**/*'
    - 'db/**/*'
    - 'bin/**/*'
    - 'spec/**/*'
    - 'node_modules/**/*'
 # どのCOPに引っかかったのかを表示する
  DisplayCopNames: true
Rails:
  Enabled: true

# ブロックが正しく記述されているかのCOP
Layout/MultilineBlockLayout:
 # 除外
  Exclude:
    - 'spec/**/*_spec.rb'

Metrics/AbcSize:
  Max: 25

Metrics/BlockLength:
  Max: 30
  Exclude:
    - 'Gemfile'
    - 'config/**/*'
    - 'spec/**/*_spec.rb'
    - 'lib/tasks/*'

Metrics/ClassLength:
  CountComments: false
  Max: 300

Metrics/CyclomaticComplexity:
  Max: 30

Metrics/LineLength:
  Enabled: false

Metrics/MethodLength:
  CountComments: false
  Max: 30

Naming/AccessorMethodName:
  Exclude:
    - 'app/controllers/**/*'

# 日本語でのコメントを許可
Style/AsciiComments:
  Enabled: false

Style/BlockDelimiters:
  Exclude:
    - 'spec/**/*_spec.rb'

# モジュール名::クラス名の定義を許可
Style/ClassAndModuleChildren:
  Enabled: false

# クラスのコメント必須を無視
Style/Documentation:
  Enabled: false

# 文字リテラルのイミュータブル宣言を無視
Style/FrozenStringLiteralComment:
  Enabled: false

Style/IfUnlessModifier:
  Enabled: false

Style/WhileUntilModifier:
  Enabled: false

Bundler/OrderedGems:
  Enabled: false
Rails/OutputSafety:
  Enabled: true
  Exclude:
    - 'app/helpers/**/*.rb'

Rails/InverseOf:
  Enabled: false

Rails/FilePath:
  Enabled: false

```

#### RSpec

`$ bundle exec rails g rspec:install`コマンドを実行し、必要なファイルを生成させる

`config/application.rb`にて`$ rails g`コマンドで自動生成するファイルについての設定を行う。今回は、Model spec と System specのみを使用する場合は以下のように設定すれば良い

```ruby
# config/application.rb

config.generators do |g|
  g.test_framework :rspec,
    view_spec: false,
    helper_spec: false,
    controller_spec: false,
    routing_spec: false,
    request_spec: false
end
```

`.rspec`内に`--format documentation`を記述することで、実行結果を見やすくすることができる

先ほど追加した`gem 'spring-commands-rspec'`をbundle installしたのち、`bundle exec spring binstub rspec`コマンドを実行することで、binディレクトリに`rspec`ファイルが生成される。

よって、`bin/rspec`コマンドでテストを実行することができる様になる(高速)。100件以上のテストをする場合は、`bundle exec rspec`コマンドで実行したほうが速いとの噂もあるそう

#### FactoryBotの準備

`spec/rails_helper.rb`内に以下を記述することで、FactoryBotシンタックスを省略することができる様になる

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```

#### Capybara

`/spec/rails_helper.rb`内に`requrie 'capybara/rspec'`の一行を追記することでRSpecでCapybaraを扱えるようになる

```ruby
# spec/rails_helper.rb

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rspec'  # この一行を追加
end
```

<br>

## create User

`$ bundle exec rails g model User name:string email:string password_digest:string`

作成されたマイグレーションファイルに`add_index :users, :email, unique: true`を追加し、DB層からemailの一意性を担保させる

## models/user

```ruby
class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
end
```

`has_secure_password`...仮想的にpassword, password_confirmationカラムを生成する

## routes

```ruby
namespace: api do
  resources :users, only: %i[create]
  resource :session, only: %i[create destroy]
end
```
名前の衝突を防ぐなどの目的でnamespace`api`を切る。今回はAPIモードではいが、一般的に`api < v1`のようにapi配下にバージョンを分けて管理するとのこと

## api::users_controller

```ruby
class Api::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    user.save!
    render json: user, status: :created, serializer: UserSerializer
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

`render json: user`...作成した`user`情報をJSON形式で返すためのメソッド

`serializer: UserSerializer`...gem `active_model_serializer`により、JSONデータを簡単に作成させ、のちに作成する`serializer/user_serilizer.rb`内に定義した情報を返させるメソッド

## UserSerializer

gem`active_model_serializer`をインストールしたことで、`$ bundle exec rails g serializer User`コマンドが使えるようになる

```ruby
class UserSerializer < ActiveModel:Serializer
  attributes :id, :name, :email
end
```

`attributes`メソッド...このメソッドにシンボルを渡すことで、JSONオブジェクトを表示させた際にレスポンスされるkeyとvalueを絞り込むことができるようになる

```json
[
  {
    id: 1
    name: "hoge"
    email: "hoge@hoge.com"
  }
]
```

レスポンスされるJSONのアダプターを設定する

```ruby
# config/initializers/active_model_serilizer.rb
ActiveModelSerializers.config.adapter = :json
```

ちなみに、ActiveModelSerializerは、３種類のアダプターを用意している

`:attributes (default)`...デフォルト

`:json`...上の例のように出力

`:json_api`...親にdataが付く。下記参照

```json
# adapterを:json_apiにした場合

{
  "data": [
    {
      "id": "1",
      "type": "users",
      "attributes": {
        "name": "hoge",
        "email": "hoge@hoge.com",
      }
    }
  ]
}
```

<br>

## JWT

JWT(ジェット)...JSON Web Tokenの略であり、Cookiesを使用せずに認証機能を実現させるための技術。

従来のWebアプリケーションでは、認証情報をCookiesを利用して保持し、ログイン情報を保つことを表現している。

APIでは、ブラウザを介さないことから、Cookiesを使用したセッションの保持が行えないため、認証時に生成したトークンを使って認証済み(ログイン状態)であることを表現できる

JWTの実態は、`JSONオブジェクトをエンコードした文字列`で、この文字列のことを`トークン`と呼ぶ

```JSON
23jaihsofhasifhisahf. //ヘッダ
sajj4htwniio5ihaiugft7t384hit4ht. //ペイロード
hasihfi44068048w4--w39uwoeihgusagyfyasfy  //署名
```

### トークンを３つに分解

JWTが発行するトークンは３つに分類することができ、それぞれがぞれぞれの情報を保持している

`<ヘッダ要素>.<ペイロード要素>.<署名要素>`

### ヘッダ要素

最初の文字列をヘッダと呼ぶ

ヘッダには、トークンのタイプや、使用されている署名アルゴリズの情報を持っている

```JSON
// エンコード => デコード
23jaihsofhasifhisahf.
=> { "alg": "HS256", "type": "JWT"}
```

alg: HS256...下記の通り、開発者が鍵を使用するユーザーを制御できるアルゴリズムを使うことわかる

#### HS256 RS256

トークンのヘッダ要素内にあるアルゴリズムである、HS256やRS256について

これらは、IDプロバイダがJWTに署名するために使用するアルゴリズムのこと。

この署名するとは、トークンの受信者が、トークンが改ざんされていないことを検証するための仕組み。

#### RS256

RS256...非対称アルゴリズムであり、公開鍵/秘密鍵のペアを使用する。IDプロバイダは署名を生成するために使用される秘密鍵をもち、JWTのコンシューマーは、署名を検証するための公開鍵を取得する。秘密鍵とは対照的に、公開鍵は保護されている必要がないため、ほとんどのIDプロバイダは、IDのコンシューマーが(通常はメタデータURLを介して)入手して使用できるようにする

- 開発者がクライアントを制御できない場合
- 秘密鍵を保護する方法がない場合

の場合は、RS256が適している


#### HS256

HS256...対象アルゴリズムであり、２つの当事者間で共有される１つの(秘密)鍵のみを使用する。署名を静止絵して検証するために同じ鍵が使用されるので、鍵が侵害されていないことを保証するように注意が必要。JWTを使用するアプリケーションを開発する場合は、誰が秘密鍵を使用するかを開発者が制御できるため、HS256を安全に使用することができる

<br>

### ペイロード

`ペイロード`...2番目の文字列のこと。任意の情報を指定することができる

基本的には、このペイロードをカスタマイズしてユーザー認証に必要な情報を埋め込む

```JSON
// エンコード => デコード

sajj4htwniio5ihaiugft7t384hit4ht.
=> { "exp"=>1600596431, "sub"=>1, "name"=>"user0" }
```

exp, sub...それぞれの値のことを`クレーム`と呼ぶ

デフォルトで指定されている値を`予約クレーム`、使用者が任意に指定した値を`パブリッククレーム`と呼ぶ

exp...Expiration Time つまり、JWTの有効期限を示すクレーム。expクレームを処理する際には、expが現在時刻以前でないことを確認しなければならない

sub...Subject つまり、JWTの主語となる主体の識別子のこと。JWTに含まれるクレームは、通常このsubについて述べたもの。

[JWTについてまとまってるサイト](https://openid-foundation-japan.github.io/draft-ietf-oauth-json-web-token-11.ja.html)


### 署名

`署名`...３番目の文字列。署名情報が入っている

この署名は、トークンが改竄・変更されていないことを確認するために使用される

```JSON
// エンコード => デコード

hasihfi44068048w4--w39uwoeihgusagyfyasfy
=> HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  your-256-bit-secret
)
```

さらっと見たけどさっぱり[HMACSHA256などについて](https://qiita.com/TakahikoKawasaki/items/8f0e422c7edd2d220e06)

<br>

### JWTでの認証の流れ

1. フロント側からログインフォームからユーザー名・メアド・パスワードなどのログインに必要な情報を送る
2. その情報をバックエンドで受け取り、登録しているユーザー名とパスワードが一致していれば、tokenを発行してレスポンスする。発行されたtokenは秘密鍵で暗号化してJWTとして送られる
3. 送られてきたトークンをlocalstorageに保存して、常に使える状態にする。vue.jsならvuexに, react.jsならreduxに保存する。ログインしていないとできないリクエストは、このトークンをヘッダーに乗せてリクエストを送る
4. バックエンド側は、リクエストのヘッダー情報を元に認証・認可を行い、レスポンスを返す
5. 返ってきたレスポンスをフロント側で表示する

## jWT実装

## Application_controller

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  class AuthenticationError < StandardError; end

  rescue_from ActiveRecord::RecordInvalid, with: :render_422
  rescue_from AuthenticationError, with: :not_authenticated

  def authenticate
    raise AuthenticationError unless current_user
  end

  def current_user
    @current_user ||= Jwt::UserAuthenticator.call(request.headers)
  end

  private

  def render_422(exception)
    render json: { error: { messages: exception.record.errors.full_messages } }, status: :unprocessable_entity
  end

  def not_authenticated
    render json: { error: { messages: ['ログインしてください'] } }, status: :unauthorized
  end
end
```

application_controllerには、エラーに関する処理を記載する

`protect_from_forgery with:`メソッド...自動でCSRF対策を行うための設定。

`:null_session`オプションは...トークンが一致しなかった場合にsessionを空にするためのオプション

`class AuthenticationError < StandardError; end`...例外を束ねているStandardErrorクラスを継承させた独自のAuthenticationErrorクラス

`rescue_from`...例外処理

`rescue_from ActiveRecord::RecordInvalid, with: :render_422`...ActiveRecord::RecordingInvalid(Rails自前のバリデーションエラー)が起きは場合に、render_422を実行させる例外処理

`rescue_from AuthenticationError, wiht: :not_authenticated`...AuthenticationErrorが発生した場合に、not_authenticatedメソッドを実行させるという例外処理

`current_user`メソッド...現在ログイン中のユーザーかどうかを判定するメソッド。Jwt::UserAuthenticatorで定義したcallメソッドを呼ぶ。引数にはリクエストのヘッダー情報を指定する。また、user情報が取得できた場合は、@current_userに代入(メモ化)され、取得できなければfalseを返す

`authenticate`メソッド...current_userメソッドがfalseを返した場合(現在ログイン中のユーザーでなければ)、AuthenticationErrorを発生させるメソッド。`raise`は手動でエラーを発生させるメソッド

`render_422`, `not_anthenticated`...JSON形式でエラーメッセージとstatusを返すメソッド

`:unprocessable_entity`...バリデーションエラー時に返すステータスコード

`:unauthorized`...認証が必要な場合に返すステータスコード

## Api::SessionsController

続いて、先ほど編集したApplicationControllerを継承させたApi::SessionsControllerを定義していく

```ruby
class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(email: session_params[:email])

    if user&.authenticate(session_params[:password])
      token = Jwt::TokenProvider.call(user_id: user.id)
      render json: ActiveModelSerializers::SerializableResource.new(user, serializer: UserSerializer).as_json.deep_merge(user: { token: token })
    else
      render json: { error: { messages: ['メールアドレスまたはパスワードに誤りがあります。'] } }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
```

`token = Jwt::TokenProvider.call(user_id: user.id)`...TokenPrividerというサービスファイルで定義したcallメソッドを呼び出し、引数であるuser_idを元にトークンを取得する

`ActiveModelSerializers::SerializableResource.new`...新しくserializserインスタンスを作成する。通常は、serializerファイルを作っていればこのように記述する必要がなくなるが、sessionの中身はuserモデルと同じなので、user情報とuserのserializerを引数にとり、その情報を元にserializerインスタンスを作成している。

`as_json`...作成したserializerの形式をJSON形式に変換させるメソッド

`deep_merge(user: { token: token })`...UserSerializerにuserの持っているtoken情報を結合させている。ハッシュの中にハッシュがある場合に`deep_merge`メソッドを使う

## app/services/jwt/user_authenticator.rb

```ruby
module Jwt::UserAuthenticator
  extend self

  def call(request_headers)
    @request_headers = request_headers
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

`extend self`...レシーバーが`module Jwt::UserAuthenticator`そのものであり、module内で定義したメソッドが`Jwt::UserAuthenticator.メソッド名`として使えるようにするための記述。

`call(request_headers)`メソッド...ApplicationControllerのcurrent_userメソッド内で呼ばれているメソッド。extend selfと記述したため、`Jwt::UserAuthenticator.call(request.headers)`で呼び出すことができている

`begin rescue end`...例外処理。begin内にエラーが起きそうなアクションを定義し、rescue内にエラーが起きた際のアクションを定義する。

`rescue StandardError`...特定のStandardErrorと指定している。つまり、StandardErrorが発生したらnilを返すということ。

`payload, = Jwt::TokenDecryptor.call(token)`...services/jwt配下にあるtoken_decryptorファイルにあるcallメソッドを呼び出し、payload,に格納する。ちなみに。`,`はタイポではない。`payload,_`と書く場合も多く、`_`にヘッダー情報が格納される。実際にこのコードでは、トークンを暗号化しており、その際に、payloadの属性情報と一緒にヘッダー情報も返している

`User.find`...取得したpayloadのuser_idの情報を元にuserを探す。そしてapplication_controllerのcurrent_userに代入される

`token`メソッド...ヘッダーのauthorizationのtokenのみを取得している。ちなみに、request_headersの中身は、`Authorization: Bearer tokentokentoken...`
となっているため、tokenだけを取得するように記述している

## app/services/jwt/token_decryptor.rb

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
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
```

`issue_token`メソッド...引数のpayload(今回はuser_id)を元に暗号化させるためのプライベートメソッド。暗号化するには復号化同様Railsの秘密鍵が必要になるため、第二引数として指定する

`call`メソッド...暗号化のためのメソッド。このメソッドは、sessions_controllerから呼ばれるメソッドだが、user_idを元にtokenを暗号化している

#### login時の流れ

1. ログインリクエストがフロントから送られる
2. ルーティングでsessionsコントローラーに振り分けられる
3. リクエストのemailとpassword情報が正しければ、暗号化してレスポンスを送る

ログイン時しかできないアクションの流れ

1. リクエストを送る
2. ルーティング該当のコントローラーに振り分ける
3. コントローラー内でcurrent_userメソッドが呼ばれる
4. リクエストを暗号化し、特定のユーザーを探す
5. userがいればcurrent_userに格納する

<br>

## POSTMAN

#### POST / api_session

成功時

[![Image from Gyazo](https://i.gyazo.com/5c4f6d933d57f34ab4ce0e8191542d2b.png)](https://gyazo.com/5c4f6d933d57f34ab4ce0e8191542d2b)

失敗時

[![Image from Gyazo](https://i.gyazo.com/094a0c558b2907e90afcb1fb9deaafaf.png)](https://gyazo.com/094a0c558b2907e90afcb1fb9deaafaf)

#### POST / api_users

成功時

[![Image from Gyazo](https://i.gyazo.com/7f80687f2341a381afe58fbe57f62338.png)](https://gyazo.com/7f80687f2341a381afe58fbe57f62338)

失敗時(パスワードの不一致)

[![Image from Gyazo](https://i.gyazo.com/0b42190a2aee4a863689937440b11927.png)](https://gyazo.com/0b42190a2aee4a863689937440b11927)

失敗時(メールアドレスの重複)

[![Image from Gyazo](https://i.gyazo.com/6e4ddfab2d2473e0b5b1d1812be2626d.png)](https://gyazo.com/6e4ddfab2d2473e0b5b1d1812be2626d)

失敗時(パスワードの不一致 + メールアドレスの重複)

[![Image from Gyazo](https://i.gyazo.com/3d60c1d2a16f3d02a4a62e0d8a6c3cf2.png)](https://gyazo.com/3d60c1d2a16f3d02a4a62e0d8a6c3cf2)

しっかりサーバー側のログにも指定したステータスコードが返っていることを確認

[![Image from Gyazo](https://i.gyazo.com/d6becc921e22816cb6b9a7aab42d05c2.png)](https://gyazo.com/d6becc921e22816cb6b9a7aab42d05c2)
