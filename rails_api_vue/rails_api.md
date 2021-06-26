# Raila APIモードについて

*ちなみに今回の課題では、APIモードは使用しない。が、一応備忘録として...


現在の主流として、Railsで生成したHTMLフォームやリンクをサーバ間のやりとりに使うではなく、Webアプリケーションを単なるAPIクライアントにとどめて、JSON　APIを利用するHTMLと、JavaScriptの提供に徹するようになった

Rackミドルウェアの恩恵を受け、JSON生成専用に徹すつのがベターという考え。主な恩恵は...[Railsガイドを参照](https://railsguides.jp/api_app.html#json-api%E3%81%ABrails%E3%82%92%E4%BD%BF%E3%81%86%E7%90%86%E7%94%B1)

## APIモードとは

Rails APIモードとは...Railsからビュー層を取り除いた全ての機能が使えるモードのこと

`$ rails new my_api --api`と`--api`オプションをつけることでAPIモードでの開発を進めることができる

--apiオプションをつけてAPIモードにすることで...

- ブラウザ向けアプリケーションで有用なミドルウェア(cookiesのサポートなど)を一切利用しなくなる
- `ApplicationController`を通常の`ApplicationController::Base`の代わりに`ApplicationControllr::API`から継承するようになる。そうすることで、ブラウザ向けアプリケーションでしか使われないモジュールを全て除外する
- ビュー・ヘルパー・アセットを生成しないようジェネレーターを設定する

## 名前空間の意識

最初から以下のようにバージョンごとにネームスペースを切ることで、今後のAPIのバージョン管理が容易になる

```ruby
# routes

Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resoureces :任意s
    end
  end
end
```

以下のようなヘルパーを生成する(基本的に本質はいつでも一緒)

```
ap1_v1_任意s
とか
api_v1_任意
とか
```

## Controller

routingで設定した名前空間に合わせて、ディレクトリの構造は以下のようになる

```
---- controllers
  --- api
    --v1
      - 任意s_controller.rb
```

コントローラーの中身を外部からAjaxリクエストなどで情報の作成、取得、削除、編集が可能になるように設定。(今回は例として一般的なPostにする)

```ruby
posts_controller

module Api
  module v1
    class PostsController < ApplicationController
      before_action :set_post, only: %i[show, update, destroy]
      skip_before_action :verify_authenticity_token

      def index
        posts = Post.all.order(created_at: :desc)
        render json: {
          status: 'SUCCESS',
          message: 'Loaded posts',
          data: posts
        }
      end

      def show
        render json: {
          status: 'SUCCESS',
          message: 'Loaded the post',
          data: @post
        }
      end

      def create
        post = Post.new(post_params)
        if post.save
          render json: {
            status: 'SUCCESS',
            data: post
          }
        else
          render json: {
            status: 'ERROR',
            data: post.errors
          }
        end
      end

      def destroy
        @post.destroy!
        render json: {
          status: 'SUCCESS',
          message: 'Deleted the post',
          data: @post
        }
      end

      def update
        if @post.update(post_params)
          render json: {
            status: 'SUCCESS',
            message: 'Updated the post',
            data: @post
          }
        else
          render json: {
            status: 'SUCCESS',
            message: 'Not update',
            data: @post
          }
        end
      end

      private
      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title)
      end
    end
  end
end
```

`skip_before_action :verify_authenticity_token`...SPAなどで、Railsアプリ以外のアプリからXHR(Ajaxとの理解で大丈夫だろう)でリクエストするAPIとして利用する場合は、CSRFトークンの検証ができないためエラーとなる。なので、APIで利用するRailsのコントローラー内にこの記述をすることで、CSRFトークン検証をスキップすることができる。なお、このCSRFトークン検証は、以下のPOSTMANを使ってのHTTPリクエストを投げる際に必要である

## postman

コンソールから２件のpostを作成し、`rails s`でサーバーを起動させる

```
$ rails c
Post.create(title: 'title1')
Post.create(title: 'title2')
```

## 共通認識

取得したJSON形式のデータは、このようになっている

```json
{
  "status": "SUCCCESS",
  "message": "Loaded the post",
  "data": [
    {
      "id": 2,
      "title": "title2",
      "created_at": "---",
      "updated_at": "---"
    },
    {
      "id": 1,
      "title": "title1",
      "created_at": "---",
      "updated_at": "---"
    }
  ]
}
```

## GET

次に、postmanを開き、`GET(http://localhost3000/api/v1/posts)`にアクセスすると、先ほど作成した２つのデータをJSON形式で取得することができる

また、`GET(http://localhost3000/api/v1/posts/1)`とidを指定すると、指定したデータをJSON形式で取得できる

## POST 作成

新規作成したいpostのデータをJSON形式で記述し、`POST(http://localhost3000/api/v1/posts)`にアクセスすると記述しな内容通りのデータを作成できる

## PUT 更新

`PUT(http://localhost3000/api/v1/posts/1)`とidを指定することで、特定のデータを更新できる

## DELETE

`DELETE(http://localhost3000/api/v1/posts/1)`とすると指定したデータの削除ができる

<br>

# APIのテスト

適切なAPIは、HTTPレスポンスのステータスコードと、実際のデータを含んだレスポンスボディを返すため、テストは主に以下の２つを検証する

- 期待したステータスコードが返ってくること
- 期待するレスポンスボディであること

## ステータスコード

APIによって返されるステータスコードは以下の４つに分類できる

- 200: OK...リクエストは成功し、レスポンスとともに要求に応じた情報が返される
- 401: Unauthorized...認証失敗。認証が必要であること
- 403: Forbidden...禁止されている。リソースにアクセスすることを拒否された
- 404: Not Found...未検出。リソースが見つからなかった

## レスポンスボディ

GETの場合...レスポンスボディ内に要求したデータが入っていることをテストする

POST, PUT, DELETEの場合...リクエスト時に、それぞれ要求した通りのデータの動きをするかテストする

## Rspec Request Spec

APIでも通常通り、RSpecが使用可能。APIについては、Request Specで行う

## 実装

の前に、`factory_bot`は実装済と仮定する。[factory_botの実装方法についてはこちらから](https://github.com/koteharyu/TIL/blob/main/insta_clone/15_model_spec/15_model_spec.md#factorybot%E3%81%AE%E6%BA%96%E5%82%99)

factory botの作成

```ruby
# spec/factories/posts.rb

FactoryBot.define do
  factory :post do
    title { 'title'}
  end
end
```

### GETについてのspec

ステータスコードが200を返すこと

要求したデータが正しいこと

```ruby

# spec/requests/api/v1/posts_spec.rb

require 'rails_helper'

RSpec.describe 'PostAPI', type: :request do
  describe 'GET' do
    context 'index' do
      it '全てのpostを取得し、正しい値を返すこと' do
        create_list(:post, 10)
        get 'api/v1/posts'
        json = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json['data'].length).to eq 10
      end
    end

    context 'show' do
      it '特定のpostを取得し、正しい値を返すこと' do
        post = create(:post, title: 'test-title')
        get 'api/v1/posts/#{post.id}'
        json = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json['data']['title']).to eq post.title
      end
    end
  end
end
```

`create_list`...同じデータを指定した回数生成するfactory_botのメソッド

### POST

正しくデータを作成できたか

正しくデータを作成した際に、ステータスコード200が返ってくるか

```ruby

require 'rails_helper'

RSpec.describe 'PostAPI', type: :request do
  describe 'POST' do
    context 'create' do
      it '新規作成後、正しく挙動になること' do
        post_params = { title: 'title'}

        expect { post 'api/v1/posts', params: { post: post_params } }.to change{ Post, :count }.by(1)

        expect(response.status).to eq 200
      end
    end
  end
end
```

### PUT

正しくデータを編集した際に、ステータスコード200が返ってくること。また正しくデータへ更新できたこと

```ruby
require 'rails_helper'

RSpec.describe 'PostAPI', type: :request do
  describe 'PUT' do
    context 'update' do
      it 'ステータスコード200が返ってくること。また正しくデータへ更新できたこと' do
        post = create(:post, title: 'old title')
        put 'api/v1/posts/#{post.id}', params: { post: { title: 'new title' } }
        json = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(json['data']['title']).to eq 'new title'
      end
    end
  end
end
```

### DELETE

指定したデータが正しく削除できたこと。またその際にステータスコード200を返すこと

```ruby

require 'rails_helper'

RSpec.describe 'PostAPI', type: :request do
  describe 'DELETE' do
    context 'destroy' do
      it '指定したデータが正しく削除できたこと。またその際にステータスコード200を返すこと' do
        post = create(:post)

        expect{ delete 'api/v1/posts/#{post.id}' }.to change{ Post, :count }.by(-1)
        expect(response.status).to eq 200
      end
    end
  end
end
```
