## chapter3

## environment database

|環境の種類|環境のシステム名|用途|
|-|-|-|
|開発|development|開発時の動作確認を行う|
|テスト|test|自動テストを行う|
|本番|production|ユーザーが利用可能な形で稼働させる|

<br>

- `bin/rails db:create`したことで以下の環境のためのデータベースが作成された
  - `Created database "taskleaf_develompemt"`
  - `Created database "taskleafe_test"`

- `テンプレートエンジン`とは、HTMLのテンプレートとそこに記述された動的な処理から、最終的なHTMLを生成するための仕組み。アプリケーションの画面をHTMLの構造が直感的にわかりやすいテンプレート形式で書くことができる

- `ERB`
  - <%= @title %>
- `Haml`
  - %h1 = @title
- `Slim`
  - h1 = @title

<br>

## slimを使うために

```Gemfile
# Gemfile
gem `slim-rails`
gem `html2slim`
```
```
$ bundle isntall
```

<br>

`erb2slim`コマンドを利用してSlimに変更

```
$ bundle exec erb2slim app/views app/views -d
```

-d をつけることで、変換後erbファイルを削除する

<br>

## bootsrrap scssを適用するために

1. rm app/assets/stylesheets/application.css
2. touch app/assets/stylesheets/application.scss
3. @import "bootstrap";

## Railsを日本語適用

1. $ touch /config/locales/ja.yml
2. https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/ja.yml
3. 中身を貼り付け
4. $ touch config/initializers/locale.rb
5. Rails.application.config.i18n.default_locale = :ja
6. ５を記述

- `i18n`とは、`internationalization`のアルファベットの数をとったもの

<br>

- データベースのモデル名はモデルのクラス名を複数形にしたもの
- モデルのクラス名はキャメルケース
- モデルのテーブル名はスネークケース

<br>

|属性の意味|属性名・カラム名|データ型|NULLを許可するかどうか|デフォルト値|
|-|-|-|-|-|
|名称|name|string|許可しない|なし|
|詳しい説明|description|text|許可する|なし|

<br>

- `マイグレーション`とは、Railsが用意しているデータベースにテーブルを追加するための仕組み。マイグレーションの主眼は、データベーススキーマ（テーブル構造など）への変更の１つ１つをRubyのプログラムとして実現し、開発の歴史に沿って順番に実行することで、最新のスキーマの状態にできるようにすること。もちろんデータベースの歴史を戻すこともできる

<br>

- リクエストを処理するコントローラーとアクションは、ブラウザからのリクエストに含まれるURLとHTTPメソッドによって決定される
- コンtローラーとアクションを設計する際には、入口となるURLとHTTPメソッドを合わせて考える必要がある
- HTTPメソッドがGETのアクションは同名のビューを使うことが多い
- HTTPメソッドがGETとなるアクション名をジェネレータコマンドの引数として指定するのが効率的

<br>

- `new_task_path`などは`URLヘルパーメソッド`という
- `/tasks/new`というURL文字列が得られる

<br>

- Taskというモデルをアプリケーションでは「タスク」と呼ぶ
- Taskのnameという属性をアプリケーションでは「名称」と呼ぶ

<br>

## リクエストパラメーター

- POSTで送る場合、基本的にはHTMLのform要素をsubmitすることで送ることができる
- GETで送る場合、基本的には、URLの`?`以降に情報を含めることで送る。普通に`?`の着いたURLにブラウザからアクセスする他、form要素のmethod属性にgetを指定して、form要素のsubmitを通じてそのようなリクエストを送ることもできる

- `Strong Parameters`
```
private
def task_params
  params.require(:task).permit(:name, :description)
end
```

<br>

## render redirect_to

- `render`とは、アクションに続けてビューを表示させること。１つのリクエストによって画面が表示される
- `redirect`とは、リダイレクトにより２つ目のリクエストが発生し、それにより画面が表示される

<br>

## Falsh

- redirect_toのオプションに直接渡すことができるFlashのキーは、デフォルトでは、`:notice`と`:alert`のみ
- `add_flash_types`を使うことで、他の任意のキーを許可することができる

<br>

`flash.now`を使うことで、同じリクエスト内（つまり、直後にレンダーするビューに対して）伝えることができる。

<br>

- `human_attribute_name(:属性)`で指定できる

<br>

- `simple_format(h(@task.description), {}, sanitize: false, wrapper_tag: "div")`

複数行に渡るテキストを入れることができる。複数行であるということは、改行コードを含むことがあるということ。しかし、改行コードはHTMLにそのまま出力すると、HTMLコード自体の改行として扱われてしまい、ブラウザの画面上では改行しているように表示されないため、この記述でそれをする

- `simple_format`は、デフォルトでエリアを`pタグ`で囲い、テキストに含まれる一部の危険なHTMLタグを取り除く。（sanitizeオプション）しかし、今回は一部のタグを取り除くのではなく、すべてのタグを安全な形で表示することにする。そのため`sanitize: false`にして、自分で`h`というメソッドを利用して改行コードを取り除いている。

- `wrapper_tag: "div"`を指定することでデフォルトである`pタグ`ではなく`div`で囲うように指定する

<br>

## partial

```
= render "form", locals: { task: @task}
```

- `localsオプション`は、パーシャル内のローカル変数を設定できる。`locals: { task: @task }`と記述することで、「インスタンス変数@taskを、パーシャル内のローカル変数taskとして渡す」という意味になる。

- `localsオプション`を利用するメリット
  - インスタンス変数の定義に依存しない、再利用性の高いパーシャルにすることができる
  - どんな変数を利用しているかわかりやすくなる

<br>

本来リンクは、GETメソッドで遷移するものだが、RailsがJavaScriptを使って簡単にGET以外のメソッドでリクエストを発生させるようにしてくれるため、あたかも自由なHTTPメソッドを使ったリンクを設置できるような感覚で使える

```
= link_to "delete", task, method: :delete, data: { confirm: "delete?"}, class: "btn btn-danger"
```

`method: :delete`を指定することで、DELETEメソッドのリクエストを送ることができる

<br>