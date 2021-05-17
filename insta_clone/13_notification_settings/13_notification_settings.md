# 13_notification_settings

## 要件

- マイページに通知設定というメニューを追加する
- コメント時の通知メール, いいね時の通知メール, フォロー時の通知メールのオンオフを切り替えられるようにする

userモデルにそれぞれの通知が必要かどうかをboolean型で格納するカラムを作成。チェックが付けばtrueになり、通知が届くような実装にしていく

通知に関するコントローラー(notification_settings)を新規に作成し、edit, updateで対応する

## routes

accountのユーザー情報更新と同じように、mypage配下に設定する。mypage以下にcurrent_user以外のユーザーを扱う予定はないため、`resouce`(単数形)を使う

```
# routes.rb

namespace :mypage do
  resource :account, only: [:edit, :upadte]
  resources :notifications, only: [:index]
  resource :notification_setting, only: [:edit, :update]
end
```

```
# 生成されるルーティング(notification_settingのみ抜粋)

edit_mypage_account GET    /mypage/notification_setting/:id/edit(.:format)    mypage/account#edit
    mypage_account PUT  /mypage/notification_setting/:id(.:format)          mypage/account#update
```

## usersテーブルにカラムを追加

`$ bundle exec rails g migration AddNotificationFlagsToUsers`コマンドでマイグレーションファイルを作成

コメント・いいね・フォローに関するboolean型のカラムを追加する。デフォルトはtrueにする。`notification_on_comment`, `notification_on_like`, `notification_on_follow`

```
# migration file

class AddNotificationFlagsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_on_comment, :boolean, default: true
    add_column :users, :notification_on_like, :boolean, default: true
    add_column :users, :notification_on_follow, :boolean, default: true
  end
end
```

## コントローラーの作成

mypage配下に作成するため

`$ bundle exec rails g controller mypage/notification_settings`コマンドを実行

mypage配下のコントローラーはMypage/base_controllerを継承することに注意。再三にはなるが、baseを継承することで、`require_login`や`layout 'mypage'`が継承される

```
class Mypage::NotificationSettingsController < Mypage::BaseController

  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(current_user.id)
    if @user.update(notification_settings_params)
      redirect_to edit_mypage_notification_setting_path, success: "メール通知設定を更新しました"
    else
      flash.now[:danger] = "メール通知設定の更新に失敗しました"
      render :edit
    end
  end

  private
  def notification_settings_params
    params.require(:user).permit(:notification_on_comment, :notification_on_like, :notification_on_follow)
  end
end
```

## edit_mypage_notification_setting_pathのリンク貼り付け

mypage/shared/_sidebarにリンクを貼る

```
# mypage/shared/_sidebar

nav
  ul.list-unstyled
    li
      = link_to 'プロフィール編集', edit_mypage_account_path
      hr
    li
      = link_to '通知一覧', mypage_notifications_path
      hr
    li
      = link_to '通知設定', edit_mypage_notification_setting_path
      hr
```

## edit.html.slimの作成

それぞれの通知のオンオフ切り替えをチェックボックスを使って実装していく。チェックされればtrue, なにもされなければfalse

```
# mypage/notification_settings/edit

= form_with model: @user, url: mypage_notification_setting_path, method: :post, local: true do |f|
  = render 'shared/error_messages', object: @user
  .form-group
    = f.check_box :notification_on_comment
    = f.label :notification_on_comment

  .form-group
    = f.check_box :notification_on_like
    = f.label :notification_on_like

  .form-group
    = f.check_box :notification_on_follow
    = f.label :notification_on_follow

  = f.submit class: "btn btn-raised btn-primary"
```

生成されるHTML

```
# 生成されるHTML

```

## ja.ymlの編集

notification_on_comment, notification_on_like, notification_on_followそれぞれ日本語に対応させるため`ja.yml`に追記する

```
# (一部抜粋)

avatar: 'アバター'
notification_on_comment: 'コメント時の通知メール'
notification_on_like: 'いいね時の通知メール'
notification_on_follow: 'フォロー時の通知メール'
```

### 各コントローラーのロジック変更

それぞれ、notification_on_XXXがtrueであれば通知メールを送信すれば良いため、以下のように変更すれば良いだろう

```
# comments_controller

def create
  @comment = current_user.comments.build(comment_params)
  @comment.save
  # notification_on_commentがtrueであれば
  if @comment.post.user.notification_on_comment
    UserMailer.with(user_from: user_to @comment.post.user, comment: @comment).comment_post.deliver_later
  end
end
```

```
# likes_controller

def create
  @post = Post.find(params[:post_id])
  current_user.like(@post)
  if @post.user.notification_on_like
    UserMailer.with(user_from: current_user, user_to: @post.user, post: @post).like_post.deliver_later
  end
end
```

```
# relationships_controller

def create
  @user = User.find(params[:followed_id])
  current_user.follow(@user)
  if @user.follower.notification_on_follow
    UserMailer.with(user_from: current_user, user_to: @user).follow.deliver_later
  end
end
```
