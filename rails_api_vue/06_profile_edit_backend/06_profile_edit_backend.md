# 06_profile_edit_backend

## ActiveStorage

#### 導入

以下のコマンドでActiveStorageの導入を行う

```
$ bundle exec rails active_storage:install
$ bundle exec rails db:migare
```

`rails db:migrate`することで、`active_storage_blobs`テーブルと`active_storage_attachment`テーブルが作成される

`active_storage_blobs`...実際にアップロードしたファイルが保存されるテーブル

`active_storage_attachment`...中間テーブル

#### 使い方

```rb
class User < ApplicationRecord
  has_one_attached :avatar
end
```

カラム名は、任意のもので良い。また該当テーブルに指定したカラムを追加する必要はない。良しなにやってくれすぎでは!?

`has_one_attached :カラム名`...1つのファイルをアップロードできるようになるメソッド

`has_many_attached :カラム名`...複数のファイルをアップロードできるようになるメソッド

## active_storage_base64

```gemfile
gem 'active_storage_base64'
```
ApplicationRecordに対してActiveStorageSupport::SupportForBase64をincludeする事で、ApplicationRecordを継承しているモデル(User, Micropost)にもBase64を適用されるようにしている

```rb
# models/application.rb
class ApplicationRecord < ActiveRecord::Base
  include ActiveStorageSupport::SupportForBase64
  self.abstract_class = true
end
```

#### self.abstract_class = true

`self.abstract_class = true`...ApplicationRecordを継承しているクラスをモデルとして作成すると、Railsはそのクラス名に対応したデータベースのテーブルを自動的に探そうとする。対応するデータベースのテーブルを用意しない場合にこの記述をする必要がある。(デフォルトで記述されている)。例としてAnimalクラスを継承するDogクラスを作成する場合、Animalクラスにこの記述をする必要がある

関係性

```rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Animal < ApplicationRecord
  self.abstract_class = true
end

class Dog < Animal

end
```

<br>

```rb
class User < ApplicationRecord
  has_one_base64_attached :avatar
end
```

ちなみに複数アップロードさせたい場合は`has_many_base64_attached`メソッドを使用する

次に、`api::me::acounts`コントローラーを修正し、avatarの情報をパラメーターに含めるようにする

```rb
class Api::Me::AccountsController < ApllicationController
  before_action :authenticate

  def update
    current_user.update!(user_params)
    render json: current_user, serializer: UserSerializer
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :avatar, avatar: :data)
  end
end
```

`avatar: :data`...gem active_storage_base64を使うことで、ファイルの情報が`data`というキーに入るためこの記述が必要になるという解釈

ちなみにパラメーターはこんな感じに

```
pry(#<Api::Me::AccountsController>)> params[:user][:avatar][:data]
=> "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAgAElEQVR4Xty9B5yeV3EuPqsurbSSVqvee5dsuVFsfEO9JBD+uQF8gdACmFASgoEQwIaA...
```

最後まで追うのが面倒であったが、注目ポイントは`"data"=>"data:image/png;base64`ここ。このフォーマットでアップロードするデータが格納される。

<br>

## UserSerializerの編集

次に`UserSerializer`を編集し、画像が設定されていればその画像のURLを返し、設定されていなければplaceholderの画像のURLを返す`avatar_url`という属性を追加する

```rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :introduction, :avatar_url

  def avatar_url
    if object.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_path(object.avatar, only_path: true)
    else
      'https://placehold.jp/300x300.png'
    end
  end
end
```

`rails_blob_path`...アップロードしたファイルにリンクを貼るメソッド。コントローラーやビューのコンテキストの外(バックグランドジョブやcronジョブなど)からリンクを作成することができる。

`user.avarar_url`...実際にvueファイル内で画像を表示させるときに使う。

