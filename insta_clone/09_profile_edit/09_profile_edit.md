# 09_profile_edit

<br>

## 要件

- 編集画面は`/mypage/account/edit`というパスとする
- アバターとユーザー名を変更できるようにする
- アバター選択時(ファイル選択時)にプレビューを表示する
- mini_magicを使用して、画像は横幅or縦幅が最大400pxとなるようにリサイズ
- 以降の課題でもマイページに諸々追加するのでそれを考慮した設計とする(ルーティングやコントローラーやレイアウトファイルなど)

<br>

## avatarカラムの追加

`rails g migration AddAvatarToUsers avatar:string`コマンドを実行し、usersテーブルにavatarカラムを追加する

```
# migration file

def change
  add_column :users, :avatar, :string
end
```

<br>

## avatar_uploader

`rails g uploader avatar`コマンドで、avatar_uploaderを作成

作成された`uploaders/avatar_uploader.rb`の編集(必要な箇所だけ抜粋)

```
# uploaders/avatar_uploader.rb

#リサイズは、公式推奨のMiniMagickを使用
include CarrierWave::MiniMagic

# 画像の保存先が、public/uploads配下になる
storage :file

# 画像の保存先の設定
def store_dir
  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
end

# ファイルがアップロードされていない場合のデフォルト画像を設定
def default_url
  'profile-placeholder.png'
end

# アップロード過程で最大400*400までになるようリサイズ
process resize_to_limit: [400, 400]

# アップロードできる拡張子を制限
def extension_whitelist
  %w(jpg jpeg gif png)
end
```

<br>

### resize_to_limit: [width, height]

このリサイズ方法は、画像の縦横比を保持したまま、widthとheightの最大値を指定できる

注意点としては、`対象の画像のサイズが引数に指定した縦横サイズ以内の場合はリサイズしないということ！`

[CarrierWave+MiniMagickで使う、画像リサイズのメソッド](https://qiita.com/wann/items/c6d4c3f17b97bb33936f)

<br>

## アップローダーの設定

models/user.rb内に以下の記述をして、avatarカラムとAvatarUploaderクラスを紐付ける

```
# models/user

mount_uploader :avatar, AvatarUpoader
```

上記の記述により、AvatarUploaderクラスの設定を利用できるようになる。

<br>

## namespaceの追加

### routes.rb

```
# routes.rb

namespace :mypage do
  resource :accounts, only: %i[edit update]
end
```

上記により、以下のルーティングが生成させる

```
edit_mypage_account GET    /mypage/account/:id/edit(.:format)    mypage/account#edit
    mypage_account PATCH  /mypage/account/:id(.:format)          mypage/account#update
                    PUT    /mypage/account/:id(.:format)         mypage/account#update
```

<br>

### コントローラーの作成

今回は、mypage/account_controllerとmypage/base_controllerを作成する。

mypage/account_controllerは、mypage/base_controllerを継承する流れで実装

`rails g controller mypage::base`

`rails g controller mypage::accounts`

### mypage/base_controller

```
# mypage/base_controller

class Mypage::BaseController < ApplicationController
  before_action :requrie_login
  layout 'mypage'
end
```

`layout 'mypage'`について

layoutメソッドとは

layout `XXX`とすることで、コントローラーやアクション毎に使用するレイアウトを切り替えるこができるようになる

特にlayoutメソッドを使用しない場合は、`app/views/layouts/application.html.slim`ファイルがアプリケーションに含まれる全てのテンプレート用レイアウトとして使用され、それぞれのコントローラーのアクション毎にレンダリングされるviewファイルが異なる

例えば、posts_controllerのindexアクションが呼ばれた場合は、`/layouts/application.html.slim`と`posts/index.html.slim`がレンダリングされる

<br>

特定のコントローラーに含まれるアクションから呼び出されるテンプレートに指定したレイアウトを設定したい場合は、`app/views/layouts/コントローラー名.html.slim`というファイルを作成する

今回の例でいうと、`app/views/layouts/mypage`ファイルを作成しておくと、自動的に適用される

[コントローラやアクション毎に使用するレイアウトを切り替える](https://www.javadrive.jp/rails/template/index3.html)

<br>

つまり今回の場合は、この`mypage/base_controller`を継承しているコントローラーのアクションに対応するビューは`app/views/layouts/mypage.html.slim`になるということ

その`app/views/layouts/mypage.html.slim`の中に`app/views/mypage`内に作成するファイルが必要に応じてレンダーされるイメージ

<br>

### mypage/account_controller

このコントローラーは、baseを継承させる必要があることに注意

```
# mypage/account_controller

class Mypage::AccountsController < Mypage::BaseController

  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(current_user.id)
    if @user.update(account_params)
      redirec_to edit_mypage_account_path, success: 'プロフィールを更新しました'
    else
      flash.now[:danger] = 'プロフィールの更新に失敗しました'
      render :edit
    end
  end

  private
  def account_params
    params.require(:user).permit(:name, :email, :avatar, :avatar_cache)
  end
end
```

base_controllerを継承しているため、before_actionやlayout 'mypage'ももちろん適用されている

対象がcurrent_userに限定できる処理はこのようにコントローラーを切り分けると管理がしやすくなる

`avatar_cache`については後述する

<br>

## Views

今回の実装で新規に作成する必要があるviewは全部で3つ

1. app/views/layouts/mypage.html.slim
2. app/views/mypage/accounts/edit.html.slim
3. app/views/mypage/shared/_slidebar.html.slim

### app/views/layouts/mypage.html.slim

このファイルは、先に述べた通りnamespaceであるmypage配下のアクションでレンダーされるファイルであることを意識

よって、`= stylesheet_link_tag 'mypage', media: 'all'`や`= javascript_include_tag 'mypage'`となる

```
= stylesheet_link_tag 'mypage', media: 'all'
= javascript_include_tag 'mypage'
  body
    = render 'shared/header'
    = render 'shared/flash_messages'
    main
      .container
        .row
          .col-md-8.offset-md-2
            .card
              .card-body
                .row
                  .col-md-3
                    = render 'mypage/shared/sidebar'
                  .col-md-9
                    .mypage_content
                      = yield
```

application.html.slim同様`= yield`に`app/views/mypage/accounts/edit.html.slim`などがレンダーされる

### app/views/mypage/accounts/edit.html.slim

```
= form_with model: @user, ulr: mypage_account_path, local: true do |f|
  = render 'shared/error_messages', object: @user
  .form-group
    = f.label :avatar
    = f.file_field :avatar, onchange: 'previewFileWithId(preview)', class: "form-control", accept: 'image/*'
    = f.hidden_field :avatar_cache
    = image_tag @user.avatar.url, class: 'rounded-circle', id: 'preview', size: '100*100'
  .form-group
    = f.label :name
    = f.text_field :name, class: "form-control"
  = f.submit class: "btn btn-raised btn-primary"
```

`onchange`を使うことで、後で実装するJavaScriptをファイルアップロード時に発火するようにできる

`accept`オプションを使い、受け付けるファイルタイプを画像ファイルのみに限定

`avatar_cache`により、バリデーションエラーが発生した際に再度画像を選択する必要がなくなる

### cacheについて

Cacheとは、バリデーションの失敗後でも選択したファイルを記憶・保持してくれる機能のこと

```
# models/user

validates :name, presence: true
validates :email, presence: true
```

models/userでは、nameとemailにpresence: trueのバリデーションが設定されているため、プロフィールを更新する際に、name, emailどちらか、または両方が空欄であればバリデーションエラーが発生し、edit.html.slimにレンダーされる流れである。

そうなれば、再度必要事項を記入し、再度アバターにしたい画像を選択する必要が生じてしまう。

このcache機能を使えば、再度画像ファイルを選択する必要を省くことができる

### 実装方法

以下の２点を実装することで、cache機能を使うことができる

- 画像アップロード時に`<カラム名>_cache`という名前のhidden_fieldを追加する
- ストロングパラメーターに`<カラム名>_cache`の記述を追記する

<br>

### app/views/mypage/shared/_slidebar.html.slim

アカウント編集ページへのリンクを設定

```
nav
  ul.list-unstyled
    li
      = link_to 'プロフィール編集', edit_mypage_account_path
      hr
```

<br>

## /config/initializers/asset.rbの編集

今回の実装では、app/assets/javascripts/mypage.js と app/assets/stylesheets/mypage.scss のファイルと作成するため、これらのファイルをprecompileするよう設定する必要がある

```
# /config/initializers/asset.rb

//一番下に追記
Rails.application.config.assets.precompile += %w[mypage.js mypage.css]
```
<br>

## JS プレビュー機能

先ほど出来てた`onchange`が呼び出すJS(app/assets/javascripts/mypage.js)を作成する

プレビュー機能の大まかな流れとしては、`f.file_field`が生成するinputタグを取得→そのタグからアップロードしたファイルを取得→取得したファイルを読み込み、元のアバターと差し替えるイベントを実行

```
# 必要なライブラリの読み込み
//= require jquery3
//= require popper
//= require rails-ujs
//= require bootstrap-material-design/dist/js/bootstrap-material-design.js

function previewFileWithId(selector) {
    const target = this.event.target;
    const file = target.files[0];
    const reader  = new FileReader();
    reader.onloadend = function () {
        selector.src = reader.result;
    }

    reader.readAsDataURL(file);
}
```

`event.target`...イベントの発生源である要素を取得するjQueryのメソッド

`target`には、`= f.file_field :avatar, onchange: 'previewFileWithId(preview)', class: "form-control", accept: 'image/*'`が生成する要素が入る

`files`...ファイルにアクセスするメソッド

`const file = target.files[0];`...targetが持つfile(画像データ)を定数fileに代入

`const reader  = new FileReader();`...読み込んだファイルを出力するための`FileReaderクラス`をインスタンス化し、定数readerに格納。インスタンス化することで、`readAsDataURL`メソッド(画像ファイルの場所をURLとして読み込む)などが使えるようになる

`onloadedn`...FileReaderオブジェクトのイベント。成功・失敗問わず読み込みが終了した時にイベントを発生させるイベント

[File Reader でファイルを取得する](https://qiita.com/mikakane/items/f0eed51556937420daee)
[FileReader.onload](https://lab.syncer.jp/Web/API_Interface/Reference/IDL/FileReader/onload/)

`reader.result`...readerに格納されているファイルの内容を返す[FileReader.result](https://developer.mozilla.org/ja/docs/Web/API/FileReader/result)

`selector.src = reader.result`...返ってきたファイル(画像のURL)をimgタグのsrc属性に代入

<br>

## CSS

`= stylesheet_link_tag 'mypage'`の記述で、application.scssではなく、mypage,scssを読み込むように指定したので、mypage.scssファイルを作成する

```
@import 'bootstrap-material-design/dist/css/bootstrap-material-design';
@import 'font-awesome-sprockets';
@import 'font-awesome';

main {
  padding-top: 50px;
}
```

<br>

## 編集ページへのリンクの追加

current_userが自身の詳細ページにいる場合のみ、編集ページへのリンクを表示させたい

```
# users/show.html.slim

.card-body
  - if current_user&.id == @user.id
    .text-center.mb-3
      = link_to "プロフィール編集", edit_mypage_account_path
```

`&.(ぼっち演算子)`を使うことで、ログインしていない場合に例外処理が発生することを防げる

```
# posts/index.html.slim

- if logged_in?
  .profile-box.mb-3
    = image_tag current_user.avatar.url, size: '50x50', class: 'rounded-circle mr-1'
    = link_to current_user.name, edit_mypage_account_path
```

<br>

## デフォルト画像の表示方法を変更

これまでは、`image_tag 'profile-placeholder.png'`とデフォルト画像のパスを指定指定たが、avatar_uploderの設定で`default_url`を設定したので以降は、`image_tag @user<user>.avatar.ulr`で表示することができる

<br>

## ja.ymlへの追記

```
attributes:
  user:
    email: 'メールアドレス'
    password: 'パスワード'
    password_confirmation: 'パスワード確認'
    username: 'ユーザー名'
    avatar: 'アバター'
```
