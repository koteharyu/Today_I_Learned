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

[Carrierwaveを用いて画像を複数アップロードする方法](https://qiita.com/matsubishi5/items/a0ff8ab9a830d2cfcc7e)