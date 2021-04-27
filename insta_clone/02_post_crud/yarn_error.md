# yarn add [###]をした際に、エラーが出た

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
