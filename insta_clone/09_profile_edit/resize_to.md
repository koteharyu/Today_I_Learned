# リサイズの種類について

### resize_to_fit: [width, height]

画像の縦横比を保持したまま、widthとheightの最大値を指定できる

### resize_to_limit: [width, height]

resize_to_fitとほぼ同じで、画像の縦横比を保持したまま、widthとheightの最大値を指定できる

`resize_to_fitとの決定的な違いは、対象の画像のサイズが引数に指定した縦横サイズ以内の場合はリサイズしないと言うこと！`

また、リサイズ後のファイルの余白部分を指定した色で塗りつぶすことも可能

第三引数で塗りつぶしの色を指定し、第四引数で余白が発生した際の画像の配置を指定

```
process resize_to_limit: [300, 200, "#fff", "Center"]
```

もし余白が発生したら、塗りつぶしの色を#fffに、画像の配置を中央に指定している

### resize_to_fill: [width, height, gravity]

上の２つと違い、resize_to_fillは画像の縦横比を保持しないことに注意

元の画像からwidth 100px, height 100pxで切り抜きを行い、第三引数で切り抜きを行う際の中心点を指定する

```
process resize_to_fill: [100, 100, "Center"]
```

画像の端っこが一部切れてしまうこともあるが、投稿した画像サイズがバラバラでも全て同じサイズにリサイズされ、縦横比の調整によって画像が横に表示されることもないため、画像投稿一覧を表示させるにはこのリサイズ方法が相性が良いらしい

<br>

[CarrierWave+MiniMagickで使う、画像リサイズのメソッド](https://qiita.com/wann/items/c6d4c3f17b97bb33936f)
