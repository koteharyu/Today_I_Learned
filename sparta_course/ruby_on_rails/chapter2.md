## rails new

<br>

- `bin/rails`コマンドとは、`binディレクトリ`にある`rails`というスクリプトを呼び出すことで、`bundle exec rails`として実行した時と同様に、`Gemfile`通りのgemを利用できる環境上でrailsコマンドを実行することができる

- `Spring`とは、Railsの起動を効率的に行う機能。
- `binstub`とは、よく使うコマンドを包み込んで使いやすくするスクリプトのこと

- `CRUD`とは`Create(作成)`,`Read(読み出し)`,`Update(更新)`,`Delete(削除)`の頭文字

- `テンプレートファイル`とは、決まったHTMLの中に動的なデータを流し込むための`Viewファイル`のこと

- `ヘルパーメソッド`とは、`link_toメソッド`が`aタグ`を生成するなど、ビューで利用できる便利な機能のこと
- `独自メソッド`の定義場所は、`app_name/helpers/フォルダ下にモジュールファイル`を用意して、そこに定義する

<br>

- `app/controllers/concerns`...複数のコントローラーで使われる共通処理を定義
- `app/lib`...自作のライブラリを定義
- `app/vendor`...外部ライブラリ用

## database.yml

|項目名|説明|
|-|-|
|adapter|データベースの接続に使用するアダプタの名前を指定する。アダプタには各データベースに対応する`sqlite3`,`postgresql`,`mysql2`,`oracle_enhanced`などがある|
|encoding|文字コード|
|pool|コネクション数|
|database|データベース名|
|username|データベースに接続するユーザー名|
|password|データベースに接続するユーザーのパスワード|
|host|データベースが動作しているホスト名またはIPアドレス|

<br>

## YAMLの基本

<br>

YAMLは構造家されたデータを表現するためのフォーマット。用途としてはXMLと似ている。人間に優しいシンプルな記法。Rubyではかなりポピュラー。YAMLはインデントでデータの階層構造を表現し、配列やハッシュも表すことができるため、データの保存や設定ファイルなどによく利用される。

```
anilal:
  cat: "猫"
  dog: "犬"
```
`キー: 値`の形でハッシュを表現することで、スペースによるインデントを使って入子構造にすることも可能

複数の箇所で共通して使いたいキーに浮いては`エイリアス`,`アンカー`という機能を使って、共通化することができる。共通化して使いたい箇所の親となるキーに`&エイリアス名`を書くことでエイリアスを定義する。

そしてエイリアスを参照したい箇所で`<<: *参照するエイリアス名`と書くことで、エイリアスの内容まるまる扱うことができる

```
animal: &animal
  cat: "猫"
  dog: "犬"

animal_shop_1:
  <<: *animal
  hamster: "ハムスター"

animal_shop_2
  <<: *animal
  parrot: "オウム"
```

<br>

上記YAMLを`app直下`に`example.yml`ファイルを設置し、`bin/rails c`で中身を確認できる

<br>

- `bin/rails routes`
- `resources :users`
  - `Prefix Verb URI Pattern Controller#Action`

- URI Pastternのところに表示されているURLnのパターンにマッチするURLにブラウザからアクセスする（もしくはフォームを送信する）と、Controller#Actionのところに表示されているコントローラーのアクションが呼び出され、処理が実行される

|Prefix|Verb|URI Pattern|Controller#Action|
|-|-|-|-|
|users|GET|/users|users#index|
|users|POST|/users|users#create|
|new_user|GET|/users/new|users#new|
|edit_user|GET|/users/:id/edit|users#edit|
|user|GET|/users/:id|users#show|
||PATCH|/users/:id|/users/update|
||PUT|/users/:id|users#update|
||DELETE|/users/:id|users#destroy|

<br>

## MVC

- `MVC`とは、`UI(ユーザーインターフェース)`を持つソフトウェアのアーキテクチャの１種である。`Model`, `View`, `Controller`を分けることで、管理しやすくなる

- Modelとは、データとデータに関わるビジネスロジック（アプリケーション特有の処理）をオブジェクトととして実装したもの。データの多くの場合、データベースで永続化されるが、データベースへの保存や読み込みもモデルが担当する
- Viewは、ブラウザに表示する画面、HTMLなどのHTTPレスポンスの中身を実際に組み立てる部分。必要に応じてコントローラーからモデルのオブジェクトなどを受け取り、画面表示に利用する
- Controllerは、ユーザーが操作するブラウザなどのクライアントからの入力（リクエスト）を受け、適切な出力（レスポンス）を作成するための制御を行う部分。必要に応じてモデルを利用したり、ビューを呼び出して、レスポンスを作り上げる。MとVのコントロールを行う部分