# 10_user_index_backend

`api::users_controller`にindexアクションを追加し、microposts/index同様ページング・metaデータを設定する

```rb
class Api::UsersController < ApplicationController
  PER_PAGE = 12

  def index
    users = User.order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    render json: users, each_serializer: UserSerializer, meta: {
      total_pages: users.total_pages,
      total_count: users.total_count,
      current_page: users.current_page
    }
  end
end
```

## rspec

```rb
require 'rails_helper'

RSpec.describe 'Api::UsersController', type: :request do
  describe 'GET /api/users' do
    context 'ページング有りの場合' do
      let!(:users) { create_list(:user, 25) }
      it 'ユーザーの一覧取得に成功すること' do
        get api_users_path
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json['meta']).to include(
          'total_pages' => 3,
          'total_count' => 25,
          'current_page' => 1
        )
      end
    end
  end
end
```

metaの中身をテストするため`json['meta']`にすることに注意
