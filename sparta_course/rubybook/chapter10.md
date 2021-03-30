## make a Web App

- `ライブラリー`とは、いろいろなプログラムで共有して使える便利なプログラムのこと

- Rubyには３つのライブラリがある

1. `組み込みライブラリ`
  1. `Integer`,`String`,`Hash`などの何も準備せずに使えるクラスなど
2. `標準添付ライブラリ`
  1. `requireメソッド`を実行して準備するクラス
  2. `JSON`クラスなど
3. `Gemライブラリ`
  1. 使う前にインストールが必要なライブラリ

## `Gem`

- `gem isntall`
 - 1回するだけでいい
 - 過去インストールしたものを再度インストールしてもいい
- `$ gem list`
 - 今までインストールしたGemの一覧を表示

- `awesome_print`このGemをインストールすれば、`apメソッド`が使えるようになる

```
requrie "awesome_print"  # 1
ap ["latte", "mocha", "coffee"] #2
```

1. awesome_print gemを読込
2. 表示させたいオブジェクト

- `Bundler`とは、複数のGemを管理する仕組み。

1. Bundlerのインストール
  1. `$ gem install bundler`
2. Gemfileの作成
  1. `$ bundle init`でGemfileを作成する
3. bundle isntall
  1. Gemfileに記載したGemたちをインストールする
  2. Gemfile.lockが作成される
  3. Gemfile.lockは自動で作成されるものなので、編集する必要なし

- `Gemfile`は、発注書
- `Gemfile.lock`は、納品書

<br>

- `bundle update`は、Gemfileに書かれているGemに新しいバージョンがリリースされた際に使うコマンド。Gemfile.lockが更新され、新たにインストールしたバージョンが書き込まれる
- `bundle update <gem名>` することで、指定したgemと、そのGemが依存している（使っている）Gemをまとめてアップデートすることが可能

<br>

## bundle exec

新しいバージョンのGemをインストールしたとき、`古いバージョンのGemは、アンインストールされない`ため、同じGemの複数のバージョンがインストールされた状態になる。通常は、新しいバージョンが利用され、それで問題がないケースが多いが、Gemfile.lockに書かれたバージョンのGemを使って実行したい場合に`bundle exec`コマンドを使用する

つまり、`bundle exec`コマンドを使うと、GemfileやGemfile.lockに書かれたGemバージョンでRubyのプログラムを実行する

<br>

## Sinatra

```
# sinatra_drink.rb

require "sinatra"
get "/drink"
  ["latte","mocha","coffee"].sample
end

#機動コマンド
# $ ruby sinatra_drink.rb -p 4567
# localhost:4567/drink
```

1. getメソッドに、`/drink`を渡し、リクエストのパスが`/drink`の時の処理をブロックで書く
2. 指定したパスに訪れた際に、毎回`sampleメソッド`が起動する

<br>

- ブラウザがリクエストをサーバーへ投げる
- Webアプリがリクエストに対するレスポンスを返す
- ブラウザがレスポンスで返ってきたHTMLを解釈し、表示する

<br>


## WebページへアクセスしてHTMLを取得する

```
# get.rb

require "net/http" 　　　　　　　　　　　　　　　# 1
require "uri"　　　　　　　　　　　　　　　　　　 # 2
uri = URI.parse("https://example.com/")     # 3
puts Net::HTTP.get(uri)                     # 4
```

1の、`require net/http`で標準添付ライブラリ`net/http`を読み込む。
これで、４で、Net::HTTPクラスが使えるようになる。`::`は、前出の名前空間の指定で、`Netモジュールの中にあるHTTPクラス`を指している。

2の`require "uri"`で、標準添付ライブラリ`uri`を読み込む。これで3で、`URIモジュール`が使えるようになる

３の、`URI.parseメソッド`にURLを文字列で渡すことで、URIオブジェクト(URI::HTTPオブジェクト)を作っている。このオブジェクトとは、("https://example.com/")を扱うオブジェクトのこと。

４の、`Net::HTTP.getメソッド`に、３で作ったURIオブジェクトを渡すことで、URIが示す先のWebサーバー(https://example.com)へHTTPのGETメソッドでリクエストを送る

Webサーバーが返したレスポンスをputsで表示しているという流れ

<br>

- `nokogiri Gem`とは、ページの内容を利用したい場合に、取得した文字列をxmlパーサーで扱うためのGem

<br>

## WebページへアクセスしてJSONを取得する

```
# json1.rb

require "net/http"  # 1
require "uri"       # 2
uri = URI.parse("https://igarashikuniaki.net/example.json")  # 3
p result = Net::HTTP.get(uri)  # 4
```

<br>

- `標準添付ライブラリ"json"`を使うことで、JSONをHashへ変換できる

```
# json2.rb

require "net/http"
require "uri"
require "json"  # 1
uri = URI.parse("https://igarashikuniaki.net/example.json")
result = Net::HTTP.get(uri)
hash = JSON.parse(result)
p hash #=> {"caffe latte" => 400}
p hash["caffe latte"] #=> 400
```

1で、jsonライブラリを読み込むことで、JSONモジュールが使えるようになった

<br>

- `to_jsonメソッド`を使うことで、JSONへ変換することができる

```
require "json"
p ({mocha: 400}.to_json) # (を省略するとエラーが出る)

#=> "{¥"mocha": 400}"
```

<br>

## WebページへHTTP　POSTメソッドでリクエストを送る

```
# post.rb

require "net/http"
require "uri"
require "json"
uri = URI("https://www.example.com")
result = Net::HTTP.post(uri, {mocha: 400}.to_json, "Content-Type" => "application/json")
p result

#=> #<Net::HTTPOK 200 OK readbody=true>
```

- `{mocha: 400}.to_json`は、送るJSON形式のデータ
- `"Content-Type" => "application/json"`は、送るデータの形式をJSONだと指定している

<br>

- JSONモジュールを使うことで、JSONとハッシュを変換できる