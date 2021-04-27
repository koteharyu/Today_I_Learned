# 02_post_crud

<br>

## add_flash_typesについて

application_controllerに`add_flas_types`の記述があり、気になったので調べたみた

ざっくりいうと、`add_flas_types`メソッドを使うことで、flashのキーを自由に指定できるらしい

つまり

```
# application_controller.rb

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
end
```

と記述することで、bootstrap対応のキーを使用することができるようになるというわけ

[RailsでflashメッセージをBootstrapで表示するスマートな方法](https://www.tom08.net/entry/2017/02/08/215921)
[Railsドキュメント](https://railsdoc.com/page/add_flash_types)

<br>

## Carrierwave and Mini_Magick

```
# gemfile

gem 'carrierwave'
gem 'mini_magick'
```

<br>

`$ bundle exec rails g uploader post_image`コマンドで、`app/uploaders/post_image_uploader.rb`が作成される

<br>

```
$ bundle exec rails g migration AddImagesToPosts images:string
```

```
# migration file

def up
  add_column :posts, :images, :string, null: false
end

def down
  remove_column :posts, :images, :string, null: false
end
```

$ bundle exec rails db:migrate:redo

<br>

モデルを編集

```
# models/post.rb

mount_uploaders :images, PostImageUploader
serialize :images, JSON
```

`serialize :images, JSON`とすることで、imagesという属性をJSONにシリアライズして1カラムに保存してくれる

[serialize](https://qiita.com/sonots/items/14b9693b64d7825dddfb)

<br>

コントローラーの編集

```
def post_params
  params.require(:post).permit(:body, :images []) # 複数枚可なので配列に入れる
end
```

<br>

ビューの編集

```
= f.file_field :images, class: "form-control", multiple: true
```

`multiple: true`を付与することで、画像を複数枚選択出来るようになる

```
- @post.images.each do |image |
  = image_tag image.url
```

<br>

## mini_magick

```
# app/uploaders/post_image_uploader.rb

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process resize_to_fill: [100, 100]
end
```

のように、include CarrierWave::MiniMagickを追記し、その下にサイズ設定を記述する。

<br>

## デフォルトでの上限枚数

5枚までデータベースに登録することができた

枚数制限は、以下のヒントをもとに実装してみたい

```
pry(#<PostsController>)> params[:post][:images].count
=> 4
```

恐らく、モデルとコントローラーで制御が出来そうな予感

<br>

[Carrierwaveを用いて画像を複数アップロードする方法](https://qiita.com/matsubishi5/items/a0ff8ab9a830d2cfcc7e)

<br>

## Fakerを使ってダミーデーターを作成する

## 導入

```
# Gemfile

group :development, :test do
  gem 'faker'
end
```

## 使い方

`Faker::[ジャンル].[タイトルなど]`を.rbファイル内に記述する

```
# seeds.rb

100.times do |n|
  name = Faker::Pokemon.name
  email = Faker::Internet.email
  password = "password"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password
  )
end
```

`$ bundle exec rails db:seed`コマンドを実行することで、seeds.rbに記述したデータを反映できる

<br>

```
# factories/book.rb

FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    publisher { Faker::Book.publisher }
  end
end
```

<br>

[Fakerで生成できるもの](https://github.com/faker-ruby/faker)
[Fakerを使ってみました！](https://qiita.com/ginokinh/items/3f825326841dad6bd11e)
[テストに使うダミーデータを用意する](https://qiita.com/koki_73/items/60c2441fb873a8db35d5)

<br>

## yarn add [###]をした際に、エラーが出た

swiperをyarnを通して導入しようとしてました。

既にプロジェクト内には`package.json`があったので、`yarn init`をする必要はなかった。

`yarn add swiper`を実行した際に以下のようなエラーが発生し、インストールが出来なかった、

```
$ yarn add swiper

dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.60.dylib
...
```

## 原因

macOSでは、libicucore.dylib というライブラリが提供されていて、icu4cをインストールする必要がなくなっているらしい。

つまり、原因としては、brewにてnodeをインストールしたことにあるみたい

## 解決

解決方法は４通り程あるみたい

すべて、依存関係を張りなおしているとのこと

<br>

### 1

```
brew reinstall node
```

自分は、この方法で、yarn add ~ yarn installまで想定通り動くようになった

[Macでnpmとかnodeが使えなくなった](https://info.yama-lab.com/mac%E3%81%A7npm%E3%81%A8%E3%81%8Bnode%E3%81%8C%E4%BD%BF%E3%81%88%E3%81%AA%E3%81%8F%E3%81%AA%E3%81%A3%E3%81%9F%E3%80%82%E3%82%A8%E3%83%A9%E3%83%BCdyld-library-not-loaded-usrlocalopticu4cliblib/)

<br>

### 2

```
brew reinstall node --without-icu4c
```

<br>

### 3

```
brew upgrade node
```

<br>

### 4

```
brew uninstall –ignore-dependencies node icu4c
brew uninstall –force icu4c
brew install node
```

<br>

## てか、icu4cってなんだ??

icu4cとは、共通コンポーネントであり、C/C++ プログラム言語で グローバルなアプリケーションを作成するためのグローバリゼーション・ユーティリティーをする

[ICU4C ライブラリー](https://www.ibm.com/docs/ja/aix/7.1?topic=programs-icu4c-libraries)

つまり、OSで足りていない部分のテキスト処理を埋めるもの

んー、わからん！！

<br>

[npmのエラー解決](https://qiita.com/SuguruOoki/items/3f4fb307861fcedda7a5)

<br>

## Swiper

## バージョンへの注意

2020/7/3にv6.0.0がリリースされ、仕様が大きく変更された

今回は、`v6以上のSwiper`の実装についてまとめる

<br>

## 導入 ~ 設定

[swiperをyarnで導入](https://qiita.com/kenkentarou/items/bdf04d8ecab6a855e50f)この記事を参照

導入したファイルの読込設定

```
# assets/javascript/application.js

//= require swiper/swiper-bundle.js
//= require swiper.js

# ↑の順番を間違えると上手く動かなくなるため注意
```

```
# assets/stylesheets/application.scss

@import 'swiper/swiper-bundle';
```

```
# config/initializers/assets.rb

Rails.application.config.assets.paths << Rails.root.join('node_modules')
```

<b>

## JSファイルの作成

yarnでインストールしてnode_module配下に置かれるJSファイルとは別に、新しくJSファイルを自分で作成する必要がある

[公式サイト](https://swiperjs.com/get-started)

```
# assets/javascripts/swiper.js(任意)

$(function() {
    new Swiper('.swiper-container', {
        pagination: {
            el: '.swiper-pagination',
        },
    })
})
```

<br>

## HTML

ざっくりなイメージ

```
.swiper-container
  .swiper-wrapper
    .swiper-slide slide1
    .swiper-slide slide2
    .swiper-slide slide3
  .swiper-pagination
  .swiper-button-prev
```

<b>

## CSS

```
.swiper-container {
    width: 600px;
    height: 300px;
}
```

<br>

[RailsでSwiperを導入する方法](https://qiita.com/miketa_webprgr/items/0a3845aeb5da2ed75f82)




