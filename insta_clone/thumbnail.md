# thumbnail

```
# posts/_tumbnail_post.html.slim

.col-md-4.mb-3
  = link_to post_path(thumbnail_post), class: 'thumbs' do
    = image_tag thumbnail_post.images.first.url
```

```
# users/show.html.slim

.row
  = render partial: 'posts/thumbnail_post', collection: @user.posts
```

上記記述について自分なりの見解をまとめる

まず処理の流れだが、ユーザー詳細ページにそのユーザーが投稿した投稿たちがタイル形式で並んでおり、各投稿の１枚目の写真がサムネイルとして表示されている。そのサムネイルをクリックするとその投稿の詳細ページへリダイレクトされるというもの。

変数名である`(thumbnail_post)`は、パーシャル名(_thumbnail_post)に合わせる必要がある

post_path(URLヘルパーメソッド)は、/post/:idを生成する

`thumbnail_post.images.first.url`の記述をすることで、CarrierWaveが`public/uploads/post/images/`フォルダから１枚目の画像を持ってくる

collectionオプションを使うことで、posts/_thumbnail_post内でeachを使う必要をなくしている

