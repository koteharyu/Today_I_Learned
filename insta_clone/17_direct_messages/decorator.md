# decorator and draper

## decoratorとは？

`decorator`とは...デザインパターン(オブジェクト指向言語で開発を行うときに、先達がまとめた「よく出会う問題とそれに対する良い設計」のこと)の１つであり、既存のオブジェクトを新しい`Decorator`オブジェクトでラップすることで既存のメソッドやクラスの中身を直接触ることなく、その外側から機能を追加したり書き換えたりできる機能のこと。

プレゼンテーション層(view, controller (今回はdecorator))に専用にメソッドを定義することで、view内でのロジックや、モデル内でロジックを減らすことができる。

## gem draperの導入

```gemfile
gem 'drpaer'

$ bundle install
```

```terminal
$ bundle exec rails g draper:install
```

上記コマンドを実行することで、以下の様なコマンドが使えるようになる

```terminal
$ be rails g decorator XXX(モデル名)
```

### XXX_decorator.rb

以下の様な記述内容になる

```ruby
class XXXDecorator < Draper::Decorator
  delegate_all

  def full_name
    "#{object.last_name} #{model.first_name}"
  end
end
```

`delegate_all`...これを記述することで、XXXモデルで定義した全てのメソッドがdecorator内でも使える様になる。これがつまり、既存のオブジェクトを新しいDecoratorオブジェクトでラップすることで既存の関数やクラスの中身を直接触ることなく、その外側から機能を追加したり書き換えたりする。」という部分のこと。

`object`...デコレートしているモデルを参照するためのメソッド。XXXモデルの`last_name`メソッドを利用することを明示する。

`model`...`object`メソッドのエイリアス。

### view

decoratorで定義した`full_name`メソッドをviewから呼び出す

```ruby
<%= current_user.decorate.full_name %>
```

`.decorate`メソッド...デコレーター層のメソッドを使う時に必要なメソッド

### Controllerからviewにインスタンス変数を渡す

```ruby
class UserDecorator < Draper::Decorator
  delegate_all

  def created_at
    object.created_at.strftime("%Y/%-m/%-d")
  end
end
```

```ruby
def index
  @users = UserDecorator.decorate_collection(User.all)
end

def show
  @user = User.find(params[:id]).decorate
end
```

```ruby
# index.html
<% @users.each do |user| %>
  <%= user.created_at %> #=> 2021/6/12
<% end %>
```

```ruby
# show.html

<%= user.created_at %>
#=> 2021/6/12
```

何もデコらずにcreatd_atメソッドを呼ぶと、すごく見づらいデータが返ってくるが、`decorate_collection`, `decorate`メソッドを使ってデコらせることで、デコ内で定義したメソッドが適用される

[draper](https://github.com/drapergem/draper)
