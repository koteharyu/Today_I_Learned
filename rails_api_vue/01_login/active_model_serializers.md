# ActiveModel::Serializerについて

`active_model_serializers`...レスポンスを簡単に、かつ綺麗にJSON形式に整形してくれるgemのこと。

## 使用例1

ActiveModel::Serializerを使えば、以下のように、簡単にJSONデータを扱うことができる

`$ rails g serializer MesssageSerializer`

```ruby
class MessageSerializer < ActiveMiode::Serializer
  attributes :content, :author, :role

  def role
    object.role.name
  end
end

# 呼び出し方法

render json: @message, serializer: MessageSerializer

# 複数のデータを出力する際

render json: @messages, each_serilizer: MessageSerializer
```

`serilizer`

`each_serializer`

基本的な使い方は、ActiveMiode::Serializerを継承して使いたいattributesを指定する方法

roleのようにattributeをオーバーライドすることも可能

## 使用例2

```ruby
# users_controller

def list_with_serializer
  users = User.all
  render json: ActiveModel::Serializer.new(
    users,
    each_serializer: UserSerializer
  ).to_json
end
```

```ruby
# user_serializer.rb

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name

  def name
    object.display_name
  end
end
```

`UserSerializer`を作っておくことで、user情報を他のところからでも呼び出せるようになる

## options

```ruby
ActiveModel::ArraySerializer.new(
  users,
  each_serializer: UserSerializer,
  message: message
)
```

serializer内で、`options[:message]`で呼び出すことができる

[参考記事](https://qiita.com/kazusa-s/items/35d849cfd2c485cb1705)
