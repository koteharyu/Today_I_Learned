# object-fitについて

サムネイルに指定した`object-fit: cover;`が何者で、何の仕事をしているのか調査します。

<br>

## 解説

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
