# 11_mail_on_activity

## 実装要件

以下の場合に、通知のメールが送られるようにしたい

- 投稿にコメントされたとき
- 投稿にいいねされたとき
- フォローされた時

つまり、notificationオブジェクトが生成された時をトリガーにすれば良さそう。

- メイラーの名前は`user_mailer`とする
- 送信元アドレスは`instaclone@example.com`

### config 導入

[`config`...Yaml形式で定数を管理することができるgemのこと。](https://github.com/koteharyu/TIL/blob/main/insta_clone/11_mail_on_activity/config.md)

```
# Gemfile

gem 'config'
```

`$ bundle exec rails g config:install`コマンドで必要なファイルを生成

後述するletter_opner_webで使用する定数の定義を行う

```
# config/settings/development.yml

default_url_options:
 host: 'localhost:3000'
```

`Settings.default_url_options.host`とすることで`'localhost:3000'`が返ってくる

ActionMailerのviewファイル作成の際に、urlを簡単に設定できるようにhostを定義する

```
# config/environments/development.rb

config.action_mailer.default_url_options = Settings.default_url_options.to_h
```

`to_h`...hashに変換するメソッド。{host: "localhost:3000"}のようなハッシュに変換させて使う

### letter_opner_web 導入

[letter_opner_web...railsの開発環境で送信したメールをブラウザで簡単に確認するためのgem]()。developmentグループ内に追記するのがベター

```
# Gemfile

group :development do
 gem 'letter_opner_web'
end
```

`/letter_opner`というパスで確認できるようにするために、`LetterOpnerWeb::Engine`をroutes.rbにマウントする

```
# routes.rb

//一番最後の行に

mount LetterOpnerWeb::Engine, at: '/letter_opener' if Rails.env.development?
```

## ActionMailerの実装

### ApplicationMailerの編集

[ActionMailerについて](https://github.com/koteharyu/TIL/blob/main/insta_clone/11_mail_on_activity/action_mailer.md)

`$ rails g mailer UserMailer`コマンドでメイラーを生成

送信元メアドの変更をする

```
class ApplicationMailer < ActionMailer::Base
 default from: 'instaclone@example.com'
 layout 'mailer'
end
```

### UserMailerの編集

コメントがあったとき、いいねされたとき、フォローされた時にメールを送るので、以下のようなメイラーアクションを定義する

```
class UserMailer < ApplicationMailer
 def comment_post
   @user_from = params[:user_from]
   @user_to = params[:user_to]
   @comment = params[:comment]
   mail(to: @user_to.email, subjct: "#{@user_from.name}があなたの投稿にコメントしました")
 end

 def like_post
   @user_fomr = params[:user_from]
   @user_to = params[:user_to]
   @post = params[:post]
   mail(to: @user_to.email, subject: "#{@user_from}があなたの投稿にいいねしました")
 end

 def follow
   @user_from = params[:user_fomr]
   @user_to = params[:user_to]
   mail(to: @user_to.email, subject: "#{@user_from.name}があなたをフォローしました")
 end
end
```

### それぞれのテンプレートの作成

コメント・いいね・フォローそれぞれのテンプレートを作成する

```
# /views/user_mailer/comment_post.html.slim

h2= "#{@user_to.name}さん"
p= "#{@user_from.name}さんがあなたの投稿にコメントしました"
= link_to "確認する", post_url(@comment.post, anchor: "comment-#{@comment.id}")
```

```
# /views/user_mailer/like_post.html.slim

h2= "#{@user_to.name}さん"
p= "#{@user_from.name}さんがあなたの投稿にいいねしました"
= link_to "確認する", post_url(@post)
```

```
# /views/user_mailer/follow.html.slim

h2= "#{@user_to.name}さん"
p= "#{@user_from.name}さんがあなたをフォローしました"
= link_to "確認する", user_url(@user_from)
```

### メイラーアクションの呼び出し

各コントローラーのcreateアクション内で、適切なメイラーアクションが呼び出されるようにしていく

```
# comments_controller

def create
 @comment = current_user.comments.build(comment_params)
 @comment.save
 UserMailr.with(user_from: current_user, user_to: @comment.post.user, comment: @comment).comment_post.delivery_later
end
```

```
# likes_controller

def create
 @post = Post.find(params[:post_id])
 current_user.like(@post)
 UserMailer.with(user_from: current_user, user_to: @post.user, post: @post).like_post.delibery_later
end
```

```
# relationships_controller

def create
 @user = User.find(params[:user_id])
 current_user.follow(@user)
 UserMailer.with(user_from: current_user, user_to: @user).follow.delivery_later
end
```

`with`...コントローラーでいうparamsのこと。ここで指定した変数たち(user_from, user_toなど)は、UserMailerアクション内のparamsからそれぞれ取得できる

再々の確認にはなるが、current_userを主語とすると、follower = current_user.id, followed = フォローしたユーザー.idが格納されていることを思い出そう

## メールの確認

メールが送信されるアクションを行った後、`localhost:3000/letter_opener`にアクセスすると、letter_opener_webのダッシュボードに行き、そこでメールの確認ができる

<br>

## もしだっぐタイピングをするなら...

### メイラーアクションの呼び出し

各メイラーアクションをnotificationオブジェクトが生成される処理内で呼び出すようにする

まずは、`models/concenrs/noticeable`から(今回追加する項目のみ抜粋)

```
module Noticeable
 ////////
 after_create_commit :send_notificaiton_mail

 private
   def send_notification_mail
     raise NotImplementError
   end
end
```

次に、comment, like, relationshipの順にorverrideしていく

```
# models/comment

private
 def send_notification_mail
   UserMail.with(user_from: user, user_to: post.user, comment: self).comment_post.deliver_later
 end
```

```
# models/like

private
 def send_noification_mail
   UserMailer.with(user_from: user, user_to: post.user, post: post).like_post.deliver_later
 end
```

```
# models/relationship

private
 def send_notification_mail
   UserMailer.with(user_from: follower, user_to: followed).follow.deliver_later
 end
```

コールバックでのメール関連はあまり良くないらしい。
