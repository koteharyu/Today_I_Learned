# 08_my_posts

## 要件

- ユーザーの詳細ページに、そのユーザーの投稿を一覧(サムネイル)で表示させる
- 各投稿のサムネイルをクリックすると、該当の投稿詳細ページへアクセスできる
- ヘッダーのユーザーアイコンにcurrent_userの詳細ページのリンクを貼る

<br>

## tumbnail_post

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

<br>

## css

```
.thumbs {
  width: 100%;
  position: relative;
  display: block;

  &::before {
    content: "";
    display: block;
    padding-top: 100%;
  }

  img {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    object-fit: cover;
  }
}
```

<br>

# object-fitについて

`object-fit: cover;`を指定された画像は、縦横比を保ったまま指定したサイズに切り抜くことができるCSS

```
img {
  width: 150px;
  height: 150px;
  object-fit: cover;
}
```

`object-fit`は、「150 * 150px」の枠に画像をどうはめ込むかを決めるもの

`cover`という値は、「画像の比率を保ったまま、枠が埋まるように中央配置して」と指定

<br>

[object-fit](https://code-kitchen.dev/css/object-fit/)

<br>

## &::before

> CSSの::afterと::beforeは、疑似要素と呼ばれるものの1つです。これを使うと「HTMLには書かれていない要素もどきをCSSで作ることができる」のです。

[CSSの疑似要素とは？beforeとafterの使い方まとめ](https://saruwakakun.com/html-css/basic/before-after)

&::beforeを使うことで、HTMLを汚すことなく擬似要素を追加できるとのこと

<br>

## shared/_headerへのリンク追加

現在ログイン中のcurrent_userの詳細ページへのリンクを貼り付ける

```
# shared/header

li.nav-item
  = link_to user_path(current_user), class: "nav_link" do
    = icon 'far', 'user', class: "fa-lg"
```
