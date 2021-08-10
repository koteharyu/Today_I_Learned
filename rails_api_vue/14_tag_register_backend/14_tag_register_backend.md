# 14_tag_register_backend

ユーザー情報に対してタグの登録を行うエンドポイントを実装する

## api/me/accounts_controller

```rb
class Api::Me::AccountsCountroller < ApplicationController
  ##
  def update
    current_user.assign_attributes(user_params)
    current_user.save_with_tags!(tag_names: tag_names)
    render json: current_user, serializer: UserSerializer
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :avatar, avatar: :data)
  end

  def tag_names
    params.dig(:user, :tag_names)
  end
end
```

`assign_attributes`...特定の属性の値だけを変更するためのメソッド。`オブジェクトを変更しただけで、DBには保存されないことに注意`。また、シリアライザとの併用が可能なため、DBへ未保存のまま、新たなオブジェクトを返すことができる

`dig`...ネストしたハッシュから安全に値を取得するためのメソッド。謝ったパラメータを取得する場合や、そもそも存在しないパラメータを取得する際に、`dig`メソッドを使用しないまま実行すると例外(`NoMethodError`)が発生してしまう。そこで`dig`メソッドを使用することで、値を取得できなかった場合に例外ではなく、`nil`が返るため安全に取得できるというわけ

## models/user

```rb
class User < ApplicationRecord
  ##
  def save_with_tags!(tag_names)
    return save! if tag_names.blank?

    ActiveRecord::Base.transaction do
      self.tags = tag_names.map{ |tag| Tag.find_or_initialize_by(name: name) }
      save!
    end
    true
  rescue StandardError => e
    false
  end
end
```

`save_with_tags(tag_names)`...上記コントローラーで受け取った`tag_names`を引数に、tag_namesが空であればタグの登録処理は行われなかったということなのでそのまま上書き。tag_namesに値が格納されている場合、`find_or_initialize_by`を実行することで該当するタグデータがなければ新規作成させる。

`find_or_initialize_by`...該当データがあればそのデータを返し、なければ新しくインスタンスを作成するメソッド。ただし、`DBへの保存は行わないことに注意`。DBへの保存まで済ませる場合は`find_or_create_by`メソッドを使う。

`トランザクション`...あるコードブロックにあるSQL文での変更全てが功することを守る目的。Transactionにより、データの統一性を保ことができる。二つの処理の中一つが失敗すると、コードブロークにあるSQL処理を全部ロールバックされるのが、Transactionの特徴。

`ActiveRecord::Base.transaction`...途中でエラーが発生した場合にロードバックさせるため

```rb
ActiveRecord::Base.transaction do
  例外が発生するかもしれない処理
end
  例外が発生しなかった場合の処理
resque => e
  例外が発生した場合の処理

モデル.transaction do
  例外が発生するかもしれない処理
end
  例外が発生しなかった場合の処理
resque => e
  例外が発生した場合の処理
```

