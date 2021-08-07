# 12_filter_users_backedn

[いい復習になりました。](https://tech-essentials.work/courses/11/tasks/15/outputs/409)

## 要件

ユーザーを「名前」か「登録しているタグ」で絞り込むこと

## モデルの追加

userに紐づくtagを実装するために、`tags`テーブルと `user_tags`テーブルを新規に作成。`user_tags`テーブルが、usersとtagsの中間テーブルとなる

```rb
class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
```

```rb
class UserTag < ApplicationRecord
  belongs_to :user
  belongs_to :tas

  validates :user_id, uniqueness: { scope: :tag_id }
end
```

user_idとtag_idの組み合わせを一意に制限

```rb
class User < ApplicationRecord
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags
end
```

user_tagが持つtagsを参照する

## api::tags_controller

```rb
class Api::TagsController < ApplicationController
  def index
    tags = Tag.all
    render json: tags, each_serializer: TagSerializse
  end
end
```

## TagSerializer

`$ bundle exec rails g serializer Tag`コマンドを実行しファイルを作成し、`id`, `name`をJSON形式で返すように定義する

```rb
class TagSerializer < ActiveModel::Serializer
  attributes :id, :name
end
```

## UserSerializer

User has many tagsとなるためUserSerializerに追記する

```rb
class UserSerializser < ActiveModel::Serializer
  has_many :tags
end
```

## フォームオブジェクトを使った検索機能の実装

`app/forms/search_users_form.rb`を作成

```rb
class SearchUsersForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :tag_ids, array: :integer

  def search
    relation = User.distinct
    relation = relation.by_name(name) if name.present?
    relation = relation.by_tag(tag_ids) if tag_id.present?
    relation
  end
end
```

必要なモジュールをincludeし、擬似的な属性である`name`(string型)と`tag_ids`(integer形の配列)を定義する

`search`というメソッドを作成する。

`distinct`...重複したレコードを１つと見なすメソッド。万が一同じユーザーが存在した場合の処理

`by_name`, `by_tag`メソッドは、次にmodels/userで定義するメソッド

## models/user

SearchUsersFormのsearchメソッド内で使用する２つのメソッドを定義する

```rb
class User < ApplicationRecord
  scope :by_name, -> (name) { where('name LIKE ?' "%#{name}%") }
  scope :by_tag, -> (tag_ids) { joins(:user_tags).where(user_tags: { tag_id: tag_ids }) }
end
```

`by_name`...引数`name`と部分一致するnameの値を持つレコードを返すメソッド

`joins`メソッド...このメソッド使いことで`usersテーブル`と`user_tags`テーブルを結合させている

`by_tag`...`usersテーブル`と`user_tags`テーブルが結合した新たなテーブルが仮想的に作られたとイメージすれば理解しやすかった。引数`tag_ids`と紐づいているユーザーを返すメソッド

## users_controller

indexアクションを変更し、検索に対応させる

```rb
class Api::UsersController < ApplicationController
  PER_PAGE = 12
  def index
    search_users_form = SearchUsersForm.new(search_params)
    users = search_users_form.seach.order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    render json: users 以下省略
  end

  private

  def search_params
    params[:q]&.permit(:name, tag_ids: [])
  end
end
```

1. search_paramsを引数として、SearchUsersFormオブジェクトを作成する
2. SearchUsersForm内で定義した`search`メソッドを実行し、その返り値をusersに格納

`params[:q]`...qというキーで検索文字列を受け取るように実装する。URLは`localhost:3000/api/users?q[name]=haryu&q[tag_ids][]=3`のような形で送られる

`tag_ids: []`...tag_idsは配列に指定しているため`[]`を忘れないように。また、nilが渡された際に例外処理が発生しないように`&.`をかましている

## JSON

[![Image from Gyazo](https://i.gyazo.com/63227cf17e95407d92d08ed1d30dc258.png)](https://gyazo.com/63227cf17e95407d92d08ed1d30dc258)

id と　nameの組み合わせが少しややこしいが、正常にデータを返すことを確認

<br>

[![Image from Gyazo](https://i.gyazo.com/d0f813579f570f489ae932168d46ac5c.png)](https://gyazo.com/d0f813579f570f489ae932168d46ac5c)

検索条件に合致するユーザー情報が返ってきたこと確認

## Rspec

```rb
# users_spec
##
context 'ページングなしの場合' do
  let!(:users) { create_list(:user, 5) }
  it 'ユーザーの一覧取得に成功すること' do
    get api_users_path
    expect(response).to have_http_status(200)
    json = JSON.parse(response.body)
    expect(json['users']).to match_array(users.map { |user|
      include(
        'id' => user.id,
        'name' => user.name,
        'tags' => be_a(Array)
      )
    })
  end
end
```

`tags`は配列で返ってくるため`be_a(Array)`とかける

ちなみに`be_a`とは、同一クラスかを確認できるマッチャ
