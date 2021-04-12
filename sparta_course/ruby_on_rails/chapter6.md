## chapter 6 Railsを取り巻く世界

Railsは基本的な前提として、HTTPでクライアントとやりとりするサーバーサイドのプログラムを作るためのフレームワークである

そのため、HTTPや、主要な利用クライアントであるブラウザ、ブラウザが画面を描画する基本となるHTML,ブラウザ側で動的な処理を行えるJavaScript(ブラウザ上で動作することに限定されず、クライアント再度のJavaScriptのこと)などの理解が重要

<br>

## ルーティング

`ルーティング`とは、リクエストをアクションへ道案内する「ルート」の集合として捉えることができる。

|要素の名前|要素の内容の例|説明|
|-|-|-|
|HTTPメソッド|GET,POST,PATCH,PUT,DELETE|サーバーへのリクエストの際に指定するもので、情報の送信・取得の方法を表す。一般的なブラウザから送ることができるのは、GET,POSTのみだが、Railsでは、`_method`というリクエストパラメーターの値に"PATCH","PUT","DELETE"という文字列が入ったPOSTリクエストを、それぞれPATCH,PUT,DELETEリクエストと解釈する|
|URLパターン|/tasks, /tasks/:id|URLそのものや、:idのように一部の任意の文字がhじゃいるようなパターンを指定する|
|URLパターンの名前|new_task, tasks|定義したURLパターンごとに一意な名前をつける。この名前をもとに、対応するURLを生成するための、new_task_path, new_task_urlといった`ヘルパーメソッド`が用意される|
|コントローラー|tasks(TasksController)|呼び出したいアクションのコントローラクラスを指定する|
|アクション|index|呼び出したいアクションを指定する|

<br>

`get "/login", to: "sessions#new"`とすることで、GETメソッドで、"/login"というURLに対してリクエストが来たら、SessionsControllerのnewアクションを呼び出して欲しい。また、"/login"というURLを、`login_path`というヘルパーメソッドで生成できるようにしている

複数のルートのURLパターンが同じ場合は、基本的に同じURLパターン名をつけて、同じURLヘルパーメソッドを利用することが多くなる。URLパターン名はルートごとというよりも、URLパターンごとにつけるという理解で

`match :via`オプションを組み合わせることで、複数のHTTPメソッドを受け付ける１つのルートを定義できる。

もし、`sessions#create`を`POST`だけでなくPATCHやPUTでリクエストされた際にも呼び出したい時は

`match '/login', to: "sessions#create", via: [:post, :patch, :put]`と書く

<br>

URLを得るための方法

1. "/tasks"などの文字列を直接記述する
   1. 後々そのアクションに対するURLを変更したくなった時に、修正箇所が多くなり、修正漏れが発生しやすいため、避ける
   2. URLの書き方や本番サーバで運用するときの設定によって、リンクが正しく機能しなくなる(指し示したURLと実体がズレた状態になる)恐れがあるため、避ける
2. { controller: :tasks, action: :index }といったハッシュを利用する
   1. link_to form_withなどにこのハッシュをURL代わりに渡すことができる
   2. url_forというメソッドにこのハッシュを渡せばURLの文字列を得ることができる
3. URLヘルパーメソッドを利用する

<br>

## RESTful (めちゃ大事重要大切)

1. HTTPリクエストはそのリクエストで必要な情報を全てもち、前のリクエストからの状態が保存されている必要がない（ステートレス）
2. `個々の情報（リソース）への「操作」の表現がHTTPメソッドとして統一されている`
3. 個々の情報（リソース）がそれぞれ一意なURIで表されている
4. ある情報（リソース）から別の情報を参照したいときは、リンクを利用する

解説

URLが表す情報（の１単位）のことをリソースと呼ぶ。例えば「`/tasks/3`というURLが示しているのは３という一意な識別子をもつtaskというリソースだ」と考える

２の理由により、Railsでは、一般的なブラウザのサポートするGET/POSTの２種類だけでなく、（わざわざ`_method`という特殊なリクエストパラメータを使ってまで）PATCH,PUT,DELETEといったHTTPメソッドをサポートする

２の理由により、RESTfulなシステムでは、操作はHTTPメソッドで表現するものであり、URLで表現するものではない。そのため、URLはなるべく、情報（リソース）の名前を表す形、「名詞」にする発想で作られている

<br>

RESTfulなインターフェースのメリットは、美しいわかりやすいインターフェースを実現できること。Railsのレールに乗れ、URLやHTTPメソッドを何にするか悩む時間を節約でき、他の開発者が設計を理解しやすくなる、潜在的に外部のシステムと連携がしやすくなること

<br>

`参照`とは、「リソース○○を取得したい」というようなリクエストのこと。「取得したい」というのが操作、つまりGET、「リソース○○」が操作の対象となる。

`resources`とは、一発でアクションに対応する７つのルートを定義できる優れもの。

`resource`(単数形)とは、対象リソース（データ）が１つしか存在しないケースで定義する。リソースが１つしかないため識別の必要がなくなるので、URL内にidを使わなくて済む。また`indexアクション`を用意しない

<br>

get, post, match, resources など、ルートを定義する記述は、前提となるURL階層や、コントローラークラスを修飾するモジュール、コントローラークラス、URLパターン名のプリフィックスなどで構造化することができる

構造化のためのメソッドとしては、`scope`,`namespace`,`controller`などがある

`scope`は、URL階層(:path),モジュール(:module),URLパターン名のプリフィックス(:as)などをオプションに指定することで、ブロック内の定義にまとめて一定の制約をかける

`namespace`は、URL階層、モジュール、URLパターン名に一括で一定の制約をかける。scopeとの違いは、一括であること。URL階層だけに制約をかけたりはできない

`controller`は、コントローラーを指定する

<br>

```
namespace :admin do
  resources :users
end
```
とすることで、`Admin::UsersController`のCRUDを、`/admin/users`といったURL,`admin_users_path`といったURLヘルパーメソッドとともに実現できる

<br>

## routes.rbの整理のこつ

どちらかに統一すべし

1. インターフェース(URL)の構造
2. コントローラーの構造

```
# バラバラなroutes.rb

Rails.application.routes.draw do
  # 常設の機能
    resources :products, only: [:index, :show]
    resources :photos, only: [:index, :show]

  # 特設系の機能
  scope: path: 's' do
    get 'special_products', to: "products#special_offers"
    get 'photo_contest', to: "photos#contest"
  end
end
```

```
# 整ったroutes.rb

Rails.application.routes.draw do
  controller :products do
    resources :products, only: [:index, :show]
    scope path: 's' do
      get 'special_products', action: :special_offers
    end
  end

  controller :photos do
    resources :photos, only: [:index, :show]
    scope path: 's' do
      get 'photo_contest', action: :centest
    end
  end
end
```

<br>

## 国際化

`ローカライズ`とは、アプリケーションの文字列表現を日本向けにすること（一部の言語むけ）

文字列表現をローカライズしたり、複数の言語を切り替えて利用するための方法

1. 利用するロケールに対応する翻訳データの`ymlファイル`を`config/locales`の下に配置する
2. 現在のロケールを示す`I18n.locale`が正しく設定された状態にする
   1. `config/initializers/locale.rb`などの中で、デフォルト値である`config.i18n.default_locale`を適切に設定
   2. 複数の言語を切り替えて利用したい場合は、アプリケーションのフィルタなどで、リクエストごとに`I18n.locale`の値を変更する
3. 目的の翻訳データを利用する。基本的に`I18n.locale`に設定されたロケールの翻訳データが使われルガ、個別にロケールを指定することができる
   1. `I18n.tメソッド(I18n.traslateメソッド)`を呼ぶことで任意の翻訳データを利用できる
   2. `I18n.lメソッド(I18n.localozeメソッド)`に`Date系`、`Time系`のオブジェクトを渡すと、ローカライズされた文字列表現を得ることができる
   3. モデルクラスやRailsのヘルパーメソッドが内部的に利用する翻訳データもある

<br>

## ユーザーごとに言語を切り替える

Userクラスのlocaleという属性に`ja`,`en`などを入れるものとする。current_userから言語情報を取得で切れれば、次のようなフィルタによって`I18n.locale`の値を切り替えることができる

```
class ApplicationController < ActionController::Base
  before_action :set_locale

  private
    def set_locale
      I18n.locale = current_user&.locale || :ja # ログインしていなければ日本語
    end
end
```

<br>

翻訳ファイルには以下のような設定ができる

- (ActiveRecordベースではない)ActiveModelベースのモデルの翻訳情報
- localizeメソッドによって得られる日や日時の文字列表現
- よくあるボタンのキャプションなど、Railsが内部的に利用する文字列
- そのほか、任意の階層に任意のデータを定義できる

ymlファイルは、末尾に<ロケール名>.ymlが付く任意の名前にすることができる。`config/locales`以下のファイルは全て読み込まれるので、複数のファイルに分割して整理することができる。例えば、モデル系だけを分けたければ、models.ja.ymlなどにすることが可能

`I18n.tメソッド`は、Railsのビューでは、i18nをつけずに`.t(...)`と呼ぶことができる

```
ja.yml

ja:
  taskleaf:
    page:
      title:
        tasks: "タスク一覧"
```

`I18n.t("taskleaf.page.title.tasks")`を実行すると、`"タスク一覧"`を得ることができる

現在のロケールに関係なく、以下のようにlocaleオプションを指定することで、指定したロケールの翻訳情報を得ることもできる

```
Task.model_name.human(locale: :en) # 英語をとってくる
Task.human_attribute_name(:name, locale: :ja) # japanese
I18n.t("taskleaf.page.title.tasks", locale: :en) # english
```

<br>

`ActiveSupport::TimeWithZone`クラスとは、Timeの代わりに使うことで、Railsで扱う日時を指定できる（地域ごとに）。`created_at`などのタイムスタンプを記録する際には、自動的にこのクラスが利用されている

<br>

コンソール内で、`Time.zone = "Asia/Tokyo"`を実行することで、日本時間に変更できる

Time.zoneを切り替えてからオブジェクトを生成する必要がある。以前に生成したオブジェクトのcreatd_atは、当時のTime.zoneに対応した状態となる

<br>

ActiveSupport::TimeWithZoneオブジェクトに関して２点を設定できる

1. どのタイムゾーンの表現で日時をDBに保存し、読み出し時にどう解釈するか
2. １に基づいて取り出した日時データを、どのタイムゾーンのTimeWithZoneオブジェクトとして生成するか、また、ユーザーの入力などに由来する日時データをモデルに代入する時、どのタイムゾーンの時刻であると解釈し、どのタイムゾーンのTimeWithZonrオブジェクトとして生成するか

１については、`config/application.rb`などで`config.active_record.default_timezone`に設定する。`:utc`,`:local`の２種類から選択できる。`:utc`は、世界基準時刻。デフォルトで設定されている　`:local`は、Rubyの動作している環境のシステム時刻。

<br>

## アプリのフェフォルトのタイムゾーンを日本時間にする

`config/application.rb`に、`config.time_zone = "Asia/Tokyo"`を追記

`Time.current`,`Time.zone.now`,`Time.zone.today`,`Date.current`は、現在の日付を取得できる

<br>

## デバッグ用/本番用のエラー画面の切り分け

`config/environments/development.rb`などの環境ごとの設定ファイル内の`cofig.consider_all_requrests_local = true`の時はデバッグ用。`false`の時は本番用のエラー画面が表示される。development,testではデフォルトでtrueになっている

`config.action_dispatch.show_exception = false`に設定すると、Railsでのエラー処理機構を解さずに、例外が生じるままにすることができる

|ステータスコード|例外の内容|
|-|-|
|404|ルーティングで行き先となるActionが見つからない、モデルで指定したidのレコードが見つからないなど、ユーザーの求めているリソースが提供できないことにつながる例外|
|500|システムエラー全般|

<br>

`rescue_fromメソッド`を利用することで、特定のアクションの特定の例外について専用的な処理をしたい場合や、比較的手軽にエラー画面を出したい場合に、コントローラーに用意されているこのメソッドを使う。

次のようにすることで、`custom_error.html.slim`の`@error`の内容を適宜表示するようなエラー画面用のテンプレートを用意することで、Railsの用意した500.htmlに到達する前に自分でエラー処理を行うこができる

```
# コントローラーファイル

resuce_from MyCustomError, with: show_custom_error_page

private
  def show_custom_error_page
    @error = error
    render :custom_error
  end
```

しかし、`config.consider_all_requests_local`の値にかかわらず、常に発生するので、デバッグ時に不便。

また、コントローラーの外側で発生したエラーを拾うことができない

<br>

## ログについて

動作環境ごとにログに出力先が異なる。 `log/<環境>`

これ意外にも自力でコントローラーなどからログを出力させることができる

```
# controllers/tasks_controller.rb

def create
  ...
  if @task.save
    logger.debug "task:#{@task.attributes.inspect}"
    redirect_to @task, notice: "comment"
  else
    ...
end
```

`loggerオブジェクトのdebugメソッド`を呼び出し、ログにタスク作成時に保存したタスクの情報をdebugレベルで出力できる。

<br>

## log revel

|ログレベル(数字)|ログレベル|意味|
|-|-|-|
|5|unknown|意味不明のエラー|
|4|fatal|エラーハンドリング不可能な致命的エラー|
|3|error|エラーハンドリング可能なエラー|
|2|warn|警告|
|1|info|通知|
|0|debug|開発者向けデバッグ用詳細情報|

<br>

## ロガーの設定

ログレベルの設定は、(development環境の場合)`config/environments/development.rb`に`config.log_level = :warn(設定したいログレベルをシンボルで)`を記載する。こうすることで、`warn`以上のログのみを出力することができる。config/envirenments配下の各環境に合わせて設定しよう

<br>

## アプリケーションログの特定パラメータ値をマスクする

アプリのログには、コントローラーに渡ってきたパラメーターなどの出力される。パラメーターにパスワードやカード番号など、セキュアな情報が含まる場合、意図せず出力されてしまう可能性がある。ログに出力したくないパラメータを`config/inilializers/filter_parameter_logging.rb`の`Rails.application.config.filter_parameters`に設定すると、特定のパラメーターの値を隠して出力することができる。この設定には、デフォルトでpasswordが設定されている。ログ上では`[FILTERD]と出力される

```
Rails.application.config.filter_parameters += [:password]
```

<br>

## アプリケーション内共通で使いたいロガーの設定

ロガーの設定は、`config/environments`配下の環境ごとに設定する。development環境のログを設定するには、`config/environments/development.rb`に以下を追記する

```
config.logger = Logger.new('log/development.log', 'dairy')
```

こうすることで、一日ごとのログを取ることができる。

`weekly`　にすると、週ごと

`montyly`　にすると、月毎

設定したロガーの呼び出しは

```
logger.debug "loggerに出力"
Rails.application,config.custom_logger.debug "custom_loggerに出力"
```

<br>

## オリジナルのロガーを作成する

app/controllers/tasks_controller.rbにtask_loggerメソッドを実装して、タスクに関するログだけを専用ファイルに出力できる

```
def task_logger
  @task_logger ||= Logger.new("log/test.log", "dairy")
end

task_logger.debug "taskのログを出力"
```

<br>

## ロガーのフォーマット

ロガーのフォーマットは、`config.logger.formatter`に、`severity(ログレベル)`,`timestamp(タイムスタンプ)`,`progname(ログファイル作成時に扱うプログラム名)`,`msg(ログメッセージ)`の４つの引数を扱える

```
# config/environments/development.rb

config.logger.formatter = proc{ |severity, timestamp, progname, msg| 
  "#{timestamp} :#{severity}: #{message}\n"
}
```

<br>

# セキュリティを強化する

## Strong Parameters

`strogn parameters`とは、コントローラーでリクエストパラメーターを受け取る際に、想定通りのパラメーターかどうかをホワイトリスト方式でチェックする機能

`マスアサインメント`とは、コントローラーで受け取ったパラメーターの一部を直接モデルに渡して、複数の属性値を一括で割り当てること

有料の会員(premium)しかtaskのspecialフラグを立てれない想定

```
task_params = if user.premium?
  params.requrie(:task).permit(:name, :description, :special)
else
  params.require(:task).permit(:name, :description)
end

Task.new(raask_params)
```

上記実装により、一般ユーザーからのリクエストにsepcialが混ざっていても、params[:task]にアクセスした際に、specialフラグに関する属性は入っていない状況にすることができる

<br>

## CSRF対策を利用する

`CSRF(Cross-site Request Forgery)`とは、別のサイト上に用意したコンテンツのリンクを踏んだり、画像を表示したりしたことをきっかけに、ユーザーがログインしているWebアプリに悪意ある操作を行う攻撃。Forgeryとは、偽造のこと。`シーサーフ`と呼ばれる

POSTリクエストの際にform_withが発行する`セキュリティトークン`を元に、証明する。このセキュリティトークンは、GETメソッドからは生成されないので、データを変更するような処理をする際には、POSTメソッドを使うようにする

<br>

## Ajaxリクエストへのセキュリティトークンの埋め込み

JavaScriptによってPOSTメソッドでサーバーにリクエストを投げる`Ajaxリクエスト`がある。

Ajaxリクエストでセキュリティトークンを送るための基本的な仕組みは、JavaScriptが動く画面内にRailsが予めセキュリティトークンを出力しておき、そのトークンをJavaScriptが`X-CSRF-Token`というHTTPヘッダーで送る。つまり、トークンの出力(JavaScriptへの引き渡し)と、送信(JavaScriptによるサーバーへの送信)の２ステップが必要になる

トークンの出力は、`csrf_meta_tagsヘルパー`を使って行われる(`application.html.slim内の「csrf_meta_tags」`)の記述がそれ

トークンの送信は、Railsの機能が内部的に行うAjaxリクエストでは、自動的に行われる。また、自分でAjaxリクエストを送信する場合もRailsがある程度サポートしている

- 「`Rails.ajax()`」関数を利用することで、トークン付きのAjaxリクエストを行うことができる。ただし、Content-Typeを`application/x-www-form-urlencoded`で送信するため、データをJSONで送信したい場合などは不便
- jQueryを利用する場合、`jQuery.ajax()`関数によるリクエストには、自動的にトークが付与される。ただし、`rails-ujs`の読み込みよりも前に`Query`が読み込まれている必要がある

<br>

上記を使わず、fetch APIでAjaxリクエストを送信する場合などでは、自分でトークンを埋め込む必要がある。その際に使うのが、`Rails.csrfToken()`関数で、`csrf_meta_tag`ヘルパーの出力したトークンを簡単に取得することができる。この関数は`rails-ujs`が提供する関数であり、この関数を利用して、fetch APIでPOSTリクエストを送信する

```
# viewファイル

fetch('/tasks', {
  method: "POST",
  headers: {
    "X-CSRF-Token": Rails.csrfToken(),
    "content-type": "application/json"
  },
  body: JSON.stingify(data),
  credentials: "same-origin"
});
```

<br>

`rails-ujs`を使ったAjaxリクエストのは、link_to method: :deleteなどの動作がそれ

<br>

## インジェクション

`インジェクション`とは、Webアプリケーションに悪意のあるスクリプトやパラメーターを入力し、それが評価される時の権限で実行させる攻撃のこと

代表的なインジェクション

`XSS(クロスサイトスクリプティング)`

`SQLインジェクション`

`Rubyコードインジェクション`

`コマンドラインインジェクション`

<br>

`XSS(クロスサイトスクリプティング`とは、ユーザーに表示するコンテンツに悪意のあるスクリプトを仕掛け、そのコンテンツを表示したユーザーにスクリプトを実行させることで任意の操作を行う攻撃のこと。

JavaScriptは、ブラウザ上で動作し、ユーザーの行動を読み取ったり、任意のアクションを実行させたりすることができる。さらに、Cookieの読み書きも行える権限を持っているので、セキュリティ上の危険性がある。

このような事情から、ブラウザは、JavaScriptの悪用を防ぐために、`同一オリジンポリシー(same-origin policy)`という権限を設けている。あるオリジンのJavaScriptから他のオリジンへはAjax通信することができないため、ユーザーの安全性が保たれる。

もし、第三者がWebアプリと同じオリジンから悪意のあるJavaScriptを実行させようとしてきたら、同一オリジンポリシーの制限は適用されず、JavaScriptが実行可能な全ての操作を行うことができてしまう。

Railsのビューでは、ユーザーの入力した文字列を出力する際に自動的にHTMLをエスケープしてくれる。

|エスケープ前|エスケープ後|
|-|-|
|&|&amp;|
|"|&quot;|
|<|&ly;|
|>|&gt;|

<br>

この仕組みは大変便利だが、どんな時にもビューに動的に埋め込む文字列を必ずエスケープしたいかというとそうとも限らない。ユーザー由来の文字列ではなく、プログラマが意図的に用意した文字列の場合もある。ユーザーの入力データであっても、ある程度のマークアップをユーザーに許可したい場合などには、`rawヘルパー`,`String#html_safe`を使うとエスケープをスキップできる。また、`Slim`では、`==`で値を展開するとHTMLエスケープされない

`= raw @comment`

`= @comment.html_safe`

`== input_value`

このようにエスケープをスキップする場合には、XSSが発生しないように自分で注意する必要がある

`sanitize`ヘルパーは、ある程度タグをそのまま出したいものの、危険なタグは出力しないようにするためのヘルパー。出力できるタグをホワイトリスト形式で制限する。マークアップに必要な基本的なタグは標準で許可されるようになっているが、`:tag`オプションで明示的に許可するタグを指定することができる。`sanitize`はフィルタした結果のHTMLに対して、`String#html_safe`を実行して返すため、`raw`,`String#html_safe`を使う必要がない

`= sanitize @comment`

<br>

## SQLインジェクション

whereメソッドなどActiveRecordのいくつかのクエリメソッドはSQL文字列を直接渡して条件指定することができる。この時、SQL文字列にユーザーが入力した値を直接埋め込まないよう注意が必要。SQLインジェクションに対する脆弱性を作ってしまうリスクがあるため。

例えば、ユーザー名の入力欄に`' OR '1') --`という文字列を入力したとする。この入力値を`params[:user_name]`として受け取って次のようのデータベースを検索するコードがあったとする

`emails = User.where("name = '#{params[:user_name]}'").map(&:email`

本来は、このコードが指定されたユーザー名をもつユーザーのメアドを取り出す意図だが、入力値をそのまま埋め込んでいるため、次のようなSQL文字列が生成され、実行されてしまう

`SELECT "users".* FROM "users" WHERE (name = '' OR '1') --')`

悪意あるユーザーが紛れ込ませた`' OR '1') --)'`が巧妙に埋め込まれ、いつも真となる`OR '1'`という検索条件が追加されている。`--`以降は、SQLでは全てコメントとみなされるので、他の条件が続いていた場合もそれらを無視することができる。そのため、悪意あるユーザーの狙い通りに、全ユーザーのメアドを取り出せてしまう。

SQLインジェクションを防ぐためには、ユーザーの入力した文字列をそのままSQLに埋め込むのではなく、エスケープ処理を行ってから埋め込む必要がある

Railsでは、クエリメソッドに対してハッシュで条件を指定すると、自動的に安全化のための処理を行ってくれる。(Prepared Statementsが有効な場合は、`$!`のような位置パラメーターを利用したSQLが生成される。そうでない場合はエスケープされる)

`users = User.where(name: params[:name])`

こうすることで、次のようなSQLが生成され、実行される。これなら、アプリ本来の意図通りに、安全に検索が行われる

`SELECT "users".* FROM "users" WHERE "users"."name" = $1 [["name", "' OR '1') --"]]`

ただし、ハッシュでは作れないSQLを作るために、クエリメソッドにSQLを直接描きたい場合がある。その時は、SQLに文字列を直接埋め込まずにプレースホルダを利用する。そうすると、SQLを操作する際に、`'`のような入力をエスケープしてくれる

`users = User.where('name = ?', params[:name])`

こうすることで次のSQLを生成・実行する

`SELECT "users".* FROM "users" WHERE (name = ''' OR ''1'') --')`

また、`sanitize_sql`,`sanitize_sql_for_assignment`などのActiveRecord::Baseのクラスメソッドを使って安全なSQL文字列を作成することができる。これは、ActiveRecordモデルを経由せずに直接的にSQLを実行したい場面で利用できる

<br>

## Rubyインジェクション

Rubyには、あるオブジェクトのメソッドを任意に呼び出せる`Object#send`メソッドがある。このメソッドは動的に動作を変えたりするのに便利な反面、使い方を誤ると重大なセキュリティ問題を引き起こす可能性がある。

`特に、ユーザーからの入力をそのままsendに渡すことは避ける`

`users = User.send(params[:scope])`

Userモデルに適用する`scope`を任意に切り替えられるようにしている。これでは、意図せぬ範囲のデータまで見せてしまう危険はもちろん、プライベートメソッドまで呼び出せてしまう危険がある。もしもユーザーが`exit`という文字列を`params[:scope]`に入力してきたとしたら、このコードが実行された途端に、アプリが終了してしまう

避ける方法

1. ユーザーの入力を`case式`などで切り分けて、個々のメソッドを呼び出す部分を固定的にコーディングする方法
2. sendに渡して良いメソッド名を次のようにホワイトリスト形式で固定する方法

```
raise "Invalid scope! #{params[:scope]}" if whitelist.exclude?(params[:scope])
users = User.send(params[:scope])
```

<br>

最も危険なことは、`Kernel.#evalメソッドにユーザーからの入力を渡すこと`。例えば。サイトにチャットボットを常駐させて、特定のRubyコマンドを実行させたいとしても、次のように入力内容をそのまま`eval`で実行できるようにしてはいけない。アプリの全権限を攻撃者に明け渡すようなもの

`eval(params[:command])`

<br>

## コマンドラインインジェクション

RailsアプリからOSのコマンドを実行したい場合に起こるインジェクション

Rubyでコマンドを呼び出す方法。以下のメソッドでは、「コマンド名、パラメーター」の形で引数を指定できる

`Kernel.#system`

`Kernel,#spawn`

`Open3モジュール`

``

<br>

`Content Security Policy(CSP)`は、XSSやパケット盗聴などの特定の攻撃をブラウザ側で軽減するための仕組み。Webページのコンテンツの取得元や取得方法のポリシーを、Webサーバーからブラウザに伝えることができる。ポリシー違反を検知すると、ブラウザはスクリプトの実行を停止したり指定したURLに報告したりする

実行を許可するスクリプトのドメインをCSPでホワイトリスト形式で指定すると、ブラウザはそのホワイトリストに載っているドメインのスクリプトしか実行しない。また、インラインスクリプトの実行を禁止することもできる。これにより、たとえXSSへの脆弱性があった場合でも、Webアプリが信頼していないスクリプトが意図せず実行されることを防げる。また、コンテンツを取得するプロトコルをHTTPに強制し、盗聴のリスクを軽減することもできる

CSPを設定するには、WebサーバーからHTTPヘッダーに`Content-Security-Policy`を組み込む。他にも`<meta>タグ`を使う方法がある

RailsではHTTPヘッダーにCSPを組み合わせる機能がついており、`config/initializers/content_security_policy.rb`内にある有効にしたい記述をコメントアウトすればおk

引数でディレクティブのポリシーを指定する。`policy.script_src :self, :https`であれば、サイト自身のドメイン(サブドメインを除く)から、または、HTTPSを使用して提供されるスクリプトのみの実行を許可するという意味になる

`report-only`モードを使うことで、スクリプトがポリシーに違反していても実行はブロックされず、指定したURLに違反内容が報告される。`config/initializers/content_security_policy.rb`内に以下を追記する

`Rails.application.config.content_security_policy_report_only = true`

<br>

<br>

## アセットパイプライン

`アセットパイプライン`とは、JavaScript,CSS,画像などのリソース（アセット）を効率的に扱うための仕組み。`sprockets-rails gem`にて提供される`Sprockets`の機能。開発者が書いたJavaScript,CSSを最終的にアプリを使う上で都合の良い状態（ブラウザが読み取れる形式で、実行速度が速く、ブラウザキャッシュに対して最適化される）にするためのパイプライン処理を行う

アセットパイプラインの流れ

1. users.js.coffee, tasks.js.coffeeなどの高級言語のコンパイル
  1. CoffeeScript, SCSS, ERB, Slim等で記述されたコードをコンパイルして、ブラウザが認識できるJavaScript, CSS ファイルとして扱う
2. users.js, tasks.js
3. それぞれのファイルを`application.js`へまとめる。アセットの連結
  1. 複数のJavaScript,CSSファイルを１つのファイルに連結することで、読込に必要となるリクエスト行を減らし、すべての読込が終わるまでの時間を短縮する
4. アセットの最小化。
  1. application.js内のスペース、改行、コメントを削除してファイルを最小化し、通信量を節約する
5. ダイジェストの付与
  1. コードの内容からハッシュ値を算出してファイル名の末尾に付与。こうすることで、コードが変更されればファイル名が変更されるため、ブラウザのキャッシュの影響が修正されるまで反映されないという問題を防ぐことが出来る

<br>

## 環境による挙動の違い

アセットパイプラインは、development環境とproduction環境で、それぞれの目的に対して便利になるよう、挙動が異なっている

### development環境

高級言語のコンパイル、ダイジェスト付与は逐次自動で行われる。処理速度は悪いが、開発者が自分でコンパイルを実行する必要がなく、スムーズに開発を行うことが出来る

デバッグのしやすさを考慮して、アセットの連結と最小化は行わない

アセットの連結を行っていないため、ページのソースを確認すると、ファイル数分のlink, scriptタグが生成されている

<br>

### production環境

セットパイプラインの機能をフルに活用して、１つのJavaScriptファイル・１つのCSSファイルを生成しておき、それを配信する形が基本

development環境と異なり、高速化のためにアセットの連結・最小化が行われる。連結が行われているため、ページのソースを確認すると、１つのJavaScriptファイル・１つのCSSファイルが読み込まれている

<br>

## ブラウザにアセットを読み込ませる

`stylesheet_link_tag`は、CSSを読み込むためのヘルパーメソッド。第一引数に読み込みたいアセットファイル(拡張子は省略可)を指定する

`javascript_include_tag`は、JavaScriptを読み込むためのヘルパーメソッド。第一引数に読み込みたいアセットファイル(拡張子は省略可)を指定する

```
# application.html.slim

= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
= javascript_include_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
```

ここで読み込んでいる`application.css`,`application.js`は、アセットパイプラインにて連結された結果のファイル

<br>

## 連結結果のファイルをどうやって生成するのか

`マニュフェストファイル`とは、ファイルをどんな風に連結して出力するかを`app/assets/application.css`,`app/aseets/application.js`などに指定するファイル

マニュフェストファイルには、管理しやすいうように分類して別々のファイルとして作成した個別のCSSファイルや、JavaScriptファイル（形式はSCSSやCoffeeScriptなどの高級言語である場合が多い）をこのように連結したいという指定を記述

最終的出力したい`application.css`などのファイルごとに作成する

CSSやJavaScriptをそれぞれ`application.css`,`application.js`として１つに連結するのがRailsのデフォルトのやり方だが、自由に変えることもできる。`admin.css`,`user.css`の２つのCSSファイルをアセットパイプラインによって生成し、各ページでは必要に応じてどちらかを`include`することが可能

<br>

## マニュフェストファイルの記述方法

`ディレクティブ`とは、指示文のこと

アセットパイプラインの結合機能を利用するには、具体的にどのソースコード同士を連結するのかを決め、アセットパイプラインに伝える必要がある。

新規にRailsアプリを作成した時点で、以下の２つのマニュフェストファイルが生成される

`app/assets/javascript/application.js`

`app/assets/stylesheets/application.css`

taskleafでは、`Bootstrap`を導入する際に、`application.scss`にリネームしている。`sass-rails gem`が有効であれば、Sassでマニュフェストファイルを記述できる

```
# app/assets/javascript/application.js

//= require rails-ujs
//= require activestrage
//= require turbolinks
//= require_tree .
```

- `require`...指定したJavaScriptファイルの内容を、記述した位置に取り込む。taskleafでは、`rails-ujs`や`turbolinks`などのJavaScriptを指定している。拡張子は省略できる
- `require_tree`...指定されたディレクトリ配下の全ファイルの内容を結合し、記述した位置に取り込む。`.`を指定する場合は、`application.js`or`applicaiton.css`が配置されているディレクトリ配下が対象になる

<br>

Sassを利用する場合は、`@import`ディレクティブを使う。もしtaskleafで新たに`tasks.scss`を取り込みたい場合は以下のようになる

```
# app/assets/stylesheets/application.scss

@import, "bootstrap"
@import, "tasks"
```

Sassでマニュフェストファイルを記述する場合は、Sprocektsの方法と併用しないように！Sassの@importディレクティブで取り込んだファイルと変数が共有できなくなる等の問題が発生し、想定通り動かないことがあるため。

<br>

## アセットの探索パス

マニュフェストで指定するJavaScriptやCSSのファイル名は、アセットの探索パスの設定をもとに引き当てられる。デフォルトでは、`app/assets/*`,`lib/assets/*`,`vendor/assets/*`が探索パスに設定されている。(sprockets-railsによって設定されている)探索はパスの出現順で行わえれるため、この中では`app/assets/*`が最優先される

JavaScriptのマニュフェストを例に。`lib/assets/javascripts/slider.js`,`vendor/assets/javascripts/modal.js`の２つのファイルを取り組みたい場合、`lib/assets`,`vendor/assets`はそれぞれ探索パスに設定されているので、マニュフェストファイルには以下を記述する

```
# application.js

//= require slider
//= requrie modal
```

<br>

デフォルトの探索パス以外に、他のディレクトも探索パスとして設定したい場合は、`Rails.application.config.assets.paths`に探索パスを追加する。この設定は通常、`config/initializers/assets.rb`の中に記述する。デフォルトでは、`node_modules`が追加済みとなっている

コンソール内で`puts Rails.application.config.assets.paths`を実行すると、探索パスの対象を確認できる

<br>

`config/initializers/assets.rb`の設定は、すべての環境で読み込まれるため、環境共通の設定を記述する

`Rails.applicaiton.config.assets.version = '1.0'`は、アセットのバージョンを文字列で設定している。この値はアセットに付与するダイジェストの生成に関わっているので、変更することで全てのアセットを強制的に期限切れにすることができる

`Rails.applicaiton.config.assets.paths << Rails.root.join('node_modules')`は、探索パスの設定。初期状態では`Yarn`というパッケージマネージャー用のディレクトリ`node_module`が追加されるようになっている。

`# Rails.applicaiton.config.assets.precompile += %W(admin.js admin.css)`は、プリコンパイルするファイルを配列で設定する。初期状態ではコメントアウトされている。applicaiton.js,application.css,app/assets配下のJavaScript・CSS以外の全てのファイルがデフォルトで対象となっているので、それ以外のファイルをプリコンパイルの対象にしたいときに利用する。例。管理者向け機能で利用する.js,.cssファイルをユーザー向け機能とは別にadmin.js,admin.cssとしてプリコンパイルする場合

<br>

```
# config/environments*
config.assets.debug = true
```
にすることで、アセットの連結や前処理を行わないデバッグモードで動作する

`config.assets.quiet = true`にすることで、アセットへのリクエストに関するログを出力を抑制する。アセット関係のログは大量になることが多いため

<br>

```
config.assets.js_compressor = :uglifier
# cnofig.assets.css_compressor = :sass
```
JavaScriptとCSSの圧縮方法を指定。デフォルトでは、Gemfileに含まれるsass-rails gemがCSSの圧縮を担うため`css_compressor`は初期状態ではコメントアウトされている。本番環境のみ設定されている

`cnofig.assets.compile = false`このフラグをfalseにすると、プリコンパイル済みのアセットが存在しない時に動的なコンパイルを行わない。このフラグがtrueのとき、いちいちプリコンパイルをせずに動作を確認できるため、開発時に便利。

`# config.action_controller.asset_host = 'http://assets.example.com'`アセットファイルを配信するサーバーを設定。CDNにアセットを置く場合、ブラウザに対してRailsサーバーではく、CDNからアセットを取得するように伝える設定

<br>

## ローカル環境でproduction環境でアプリを立ち上げる

`プリコンパイル`とは、production環境で、リクエストを高速に処理できるように、予めアセットパイプラインを実行して生成ファイルを生成しておき、生成済みのファイルをリクエストのたびに配信する。この予めアセットパイプラインを実行して静的ファイルを生成するという処理のこと

production環境では、ソースコードを更新してサーバーを起動する際には、必ずプリコンパイルを実行する必要がある

`$ bin/rails assets:precompile`を実行することで、プリコンパイルできる

コマンド実行時に`Yarn executable was not detected in the system.`というエラーメッセージは、`Yarn`というJavaScriptのパッケージマネージャがインストールされていないというメッセージ。今回のtaskleafでは、JavaScriptのパッケージを利用していないため、いったん無視

`$ bin/rails assets:precompile`を実行することで、`public/assets/`ディレクトリ配下に`js`,`css`ファイルが作成される

<br>

## 静的ファイルの配信サーバーを設定する

Railsアプリがブラウザに配信するHTMLや画像、CSSファイル、JavaScriptファイルなどのコンテンツは動的に生成される場合もあれば、静的にファイルとして存在しているものをそのまま配信する場合もある。エラー処理の`404.html`のエラー画面や、production環境でアセットをプリコンパイルしたファイルが`public/`or`public/assets`配下にあるのは、静的ファイルだから。

つまり、`public`配下のものは、静的ファイルであり、静的ファイルを配信する機能のこと

ただし、本番環境では、静的ファイルの配信は、NginxやApacheなどのWebサーバーに担わせることが一般的。Railsには動的なコンテンツの配信に専念させることでパフォーマンスの向上に努めさせる

production環境をローカルPCで扱う際には、`config/environments/production.rb`の`config.public_file_server.enable`での設定が必要。これは、静的ファイルの配信機能。環境変数`RAILS_SERVER_STATIC_FILES`が存在しない限りfalseになっている

```
# config/environments/prodction.rb

# Disable serving static files from the '/public' folder by default since
# Apache or NGINX already headless this.
config.public_file_server.enable = ENV['RAILS_SERVE_STATIC_FILES'].present?
```

これをtrueに変えたければ、`~/.bash_profile`に以下の行を追加すべし

`export RAILS_STATIC_FILES=1`

<br>

## production環境のデータベースの作成

`$ bin/rails db:create`コマンドはデータベース設定ファイル(`config/database.yml`)の設定内容にっしたがって動作するため、まずは`config/database.yml production環境部分`を設定

postgresqlでのデータベース作成前に２つの準備が必要

1. postgresqlにtaskleafというユーザー(ROLE)を追加する
2. taskleafユーザーがデータベースに接続する際に使うパスワードを、環境変数`TASKLEAF_DATABASE_PASSWORD`で取得でいるようにする

まずは１

```
$ createuser -d -P taskleaf
パスワードを設定(仮にpassowrd)
確認用パスワードを入力
```

`~/.bash_profile`内に`export TASKLEAF_DATABASE_PASSWORD=password`を設定する

`$ RAILS_ENV=production bin/rails db:create db:migrae`を実行

`RAILS_ENV=production`は、production環境用のデータベースを指定する方法

<br>

`config/master.key`,`RAILS_MASTER_KEY(環境変数)`は、productionモードでアプリを利用する場合、Railsがproduction環境用の秘密情報を復元するために利用する鍵となる情報のこと

<br>

## productionモードでサーバーを起動する

`$ bin/rails s --environment=production`コマンドでローカルにて本番環境のサーバーを起動する

ちなみに、本当に本番環境を構築して起動する場合には、`Capistrano`などのツールを使ってデプロイを自動化することが多く、rails s 　コマンドを直接打ち込むことは少ない

`Credential`とは特定の方式で管理されるproduction環境用の秘密情報。管理される秘密情報そのものを指すと同時に、そのような管理の仕組みを指す言葉でもある。

`Credential`では、秘密情報を構造化して記述してリポジトリで管理できるようにしているが、このときリポジトリに入る内容はある１つのキーで復元できる。そのキーは、リポジトリの外で管理しておき、アプリケーションに伝えて、アプリケーションが復号して利用できるようにしている。

`master.keyファイル`や`RAILS_MASTER_KEY(環境変数)`は、この唯一リポジトリ外で管理できるキー

<br>

## 秘密情報の暗号化・復号

production環境用の秘密情報(`credential`)は、`config/credential.yml.enc`に記述する。このふぁいるは常に暗号化された状態で保存される。編集する際は、専用のコマンドを使う必要がある。Railsアプリがproduction環境で起動された際には、master.keyかRAILS_MASTER_KEY環境変数からキー情報を取り出して、秘密情報を内部的に復号している

`config/credential.yml.enc`は、rails newで新規アプリを作成した際に、自動生成される。

`$ bin/rails credentials:show`は、credentialの中身を確認するコマンド

`$ bin/rails credentials:edit`は、credentialを編集するためのコマンド。`New credentials encrypted and saved`と表示されれば、編集完了

<br>

## アプリからcredentialsを参照する

`Rails.application.credentials.aws`をコマンドで実行することで「aws」のキーを参照できる。もし存在しないキーを参照した場合は、`nil`が返る

もしも存在しないキーを参照する意図がなく、そのような場合には確実に例外を発生させたいのであれば`!`をキーの最後につける

```
Rails.application.credentials.somethig_missing!
# 例外発生
```

<br>

## マスターキーの扱いには注意

暗号化に使ったマスターキー(`master.keyファイル`や`RAILS_MASTER_KEY(環境変数)`)を万が一紛失してしまうと、２度とCredentialsを復号できなくなる。マスターキーはチームが参照できるパスワード管理アプリケーションで保存するなど、安全に管理する必要がある

本当にマスターキーを紛失してしまった場合、古いcredentials.yml.encファイルを削除して、再度`credentials:edit`で新しく作成する必要がある

`./gitignore`には、デフォルトで`/config/master.key`が記述されている

<br>

## secret_ky_base

Credentialsには初期状態で`secret_key_base`というキーの値が入っている。`secret_key_base`は、暗号化cookieや署名付きcookieの整合性確認などに利用される秘密鍵のこと。

`secret_key_base`はRailsをproductionモードで起動するために必要な存在

もし、外部に`secret_key_base`の値が漏れてしまった際は、必ず再生成する必要がある。`$ bin/rails secret`

<br>

## カスタム暗号化ファイル(Encrypted)

Credentialsを汎用化した機能として`Encrypted`という機能がある。任意のキーで任意のyamlファイルをCredentialsのようなやり方で暗号化・復号し、アプリケーションから参照することができる。Encryptedを使うと、staging環境でだけ使いたい秘密情報をCredentialsと分けて管理することが可能になる

`$ bin/rails encrypted:edit config/staging-credentials.yml.enc --key config/staging.key`

`--key`オプションには、暗号化・復号に使うマスターキーのファイルを指定している

CredentialsはEncryptedをベースとして作られているため、Credentialsコマンドで同様に操作、参照することができる

`$ bin\rails encrypted:show config/credentials.yml.enc`