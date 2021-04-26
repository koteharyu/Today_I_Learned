## yarnとは

JavaScriptのパッケージマネージャーで、npmと互換性があり、`package,.json`が使えるもの

### yarnのインストール

`$ brew install yarn`コマンドを実行しインストール

`yarn init`実行にてpackage.jsonを生成する

### ご利用方法

`yarn add <パッケージ名>`にて、インストールしたいパッケージをpackage.jsonに追加する

`yarn`コマンドでpackage.jsonに記載されたモジュールをインストールする

`yarn remove <パッケージ名>`コマンドでパッケージのアンインストールができる

つまり、イメージとしては、こんな感じ？

`$ yarn add <パッケージ名>` == `Gemfileへの追記`

`$ yarn` == `bundle install`

[yarnとは](https://qiita.com/akitxxx/items/c97ff951ca31298f3f24)
[yarnチートシート](https://qiita.com/morrr/items/558bf64cd619ebdacd3d)