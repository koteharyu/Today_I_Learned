# rails6系でのmimemagicに関するエラーについて

rails6系のプロジェクトを`bundle isntall`した際に、以下のようなエラーが発生し、インストールに失敗したので、解決策を残しておこうと思う

```
$ bundle install
...
Your bundle is locked to mimemagic (0.3.5), but that version could not be found
```

ちなみに、このエラーの原因は、Railsの一部である`ActiveStorage`が依存している`mimemagic gem`が、ライセンス関連の問題で、rubygems.orgから取り下げられたことらしい。

これによって、mimemagic <= 0.3.5に依存しているRailsアプリがbundle installに失敗するようになったとのこと。

## 解決策

`shared-mime-info`をインストールする

`$ brew install shared-mime-info`を実行する。

次に、Gemfile内に`gem 'mimemagic', '~> 0.3.10'`を追記する

最後にターミナルにて`$ bundle update mimemagic`を実行する

以上の工程で、mimemagicに関する問題は解決できた。が、自分の場合、次にyarnに関する問題が待っていた...

yarnについて解決したら、その記事のリンクを貼る

## 余談

上記の解決方法以外にも、以下のような手段があるようだ。

それは、Railsのバージョンを以下にすること。以下のバージョンのRailsはmimemagicに依存しなくなったらしい

```
Rails:
  5.2.5
  6.0.3.6
  6.1.3.1
```
