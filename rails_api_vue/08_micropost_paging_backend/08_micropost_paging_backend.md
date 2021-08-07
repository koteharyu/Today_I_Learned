# 08_micropost_paging_backend

## kaminari

```gemfile
gem 'kaminari'

$ bundle install
```

`microposts_controller`を編集し、1ページに最大１０件までのページネーションの設定・メタ情報の設定を行う

```rb
class Api::MicropostsController < ApplicationController
  PER_PAGE = 10
  def index
    microposts = Micropost.includes(:user).order(created_at: :desc).page(:params[:page]).per(PER_PAGE)
    render json: microposts, serialize: MicropostSerializer, meta: {
      total_pages: microposts.total_pages,
      total_count: microposts.total_count,
      current_page: microposts.current_page
    }
  end
end
```

`meta`データとして、total_pages, total_count, current_pageを定義する

レスポンスの中身

```
json = JSON.parse(response.body)
json['meta']
=> {"total_pages"=>1, "total_count"=>4, "current_page"=>1}
```

コントローラーで定義したメタデータがしっかり含まれていることがわかる

テスト時は`expect(json['meta'])`となることに注意。
