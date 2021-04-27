# Rails with Swiper

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
