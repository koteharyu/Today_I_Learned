## slimとは

Slimとは、Ruby製のテンプレートエンジン。HTMLタグを短く書くことが出来る

### 導入方法


下記gemをインストール

```
# Gemfile

gem 'slim-rails'
gem 'html2slim'
```

`bundle exec erb2slim app/views/layouts/ --delete`コマンドでlayouts配下にあるerbファイルを削除し、slimファイルを作成する

### コメント

`/`を付けることでコメントすることができる

### パイプ `|`

長いテキストなど、改行してテキストを書く際には、`パイプ(|)`を使用する

パイプを使うと, Slim はパイプよりも深くインデントされた全ての行をコピーし、エスケープされ、`p`タグで囲われる

```
# .slim

p
 |
   ほげほげ　ふがふが
   ふがふが　ほげほげ

# タグに改行されたテキスト

<p>
 ほげほげ　ふがふが
 ふがふが　ほげほげ
</p>

# パイプの後ろに書いてもOK

p 
 | ほげほげ　ふがふが
```

[reference](https://github.com/slim-template/slim/blob/master/README.jp.md)
[reference](https://qiita.com/pugiemonn/items/b64171952d958dc4d6be#slim%E3%81%A8%E3%81%AF)
