## chapter7 機能追加

タスクの新規登録画面と一覧表示画面との間に確認画面を表示させる

confirm_newというアクションを追加し、新規登録画面から受け取ったパラメーターを元にタスクオブジェクトを作成して、`@task`に代入する

```
def confirm_new
 @task = current_user.tasks.new(task_params)
 render :new unless @task.valid?
end
```
今回の実装は、resoucesに対応していないため、自作のルートを作成する必要がある

```
resouces :tasks do
 post :confirm, action: :confirm_new, on: :new
end
```

```
$ bin/rails routes

confirm_new_task POST /tasks/new/confirm(.:format) tasks#confirm_new
```

```
# tasks/confirm_new.html.slim

h1 登録内容の確認

= form_with :@task, local: true do |f|
 table.table.hover
   tbody
     tr
       th= Task.human_attribute_name(:name)
       td= @task.name
       = f.hidden_field :name
     tr
       th= Task.attribute_name(:description)
       td= @task.description
       = f.hidden_field :description
   = f.submit "戻る", name: "back", class: "btn btn-secondary mr-3"
   = f.submit "登録",  class: "btn btn-primary"
```

`hidden_field`を利用することで、ユーザーには見えない形で必要な値を送信することができる

<br>

新規作成画面→確認画面→(データベースに登録)→一覧画面の流れになるため、`tasks/new.html/slim`内の`form_with`で送るURLを変更する必要がある

```
# tasks/new.html.slim

- if @task.errors.present?
 ul#error_explanation
   - @task.errors.each do |message|
     li= message

= form_with model :@task, local: true, url: confirm_new_task_path do |f|
 .form-group
   = f.label :name
   = f.text_field :name, class: "form-control", id: "tasK_name"
 .form-group
   = f.label :description
   = f.text_area :description, rows: 5, class: "form-control", id: "task_description"
 = f.submit "確認", class: "btn btn-primary"
```

<br>

form要素内のsubmitボタンが押されると、パラメータに、押されたボタンの`name属性`の値をキーとしてキャプションが格納される。戻るボタンのname属性に`back`を与えている。つまり、戻るボタンが押された際は、`params[:back]`で戻るという文字列を得られる。

登録ボタンが押された際は、`commit`というname属性の値が格納されるので、`params[:commit]`で`登録`という文字列が得られる

戻るボタンが押された際は、タスクの内容を引き継いで新規登録のフォーム画面を表示する必要があるため,、createアクションは以下のようになる

```
# tasks_controller.rb

def create
 @task = Task.new(task_parasm)

 if params[:back].present?
   render :new
   return
 end

 if @task.save
   redirect_to @task, notice: "タスク「#{@task.name}」を登録しました"
 else
   render :new
 end
end
```

<br>

確認画面を安易に実装するとメンテナンスに手間が掛かったり、ユーザーが登録完了と勘違いするなどデメリットもあるので、本当に必要な箇所にだけ実装するように

<br>

## Ransack　検索機能

1. gem 'ransack'
2. $ bundle

<br>

ransackをインストールすると、検索を行うためのransackメソッドがモデルに追加される

```
# tasks_controller.rb

def index
 @q = current_user.tasks.ransack(params[:q])
 @tasks = @q.result(distinct: true).recent
end
```

```
# tasks/index.html.slim

h1 タスク一覧

= search_form_for @q, class: "mb-5" do |f|
 .form-group.row
   = f.label :name_cont, "名称", class: "col-sm-2 col-form-label"
   .col-sm-10
     = f.search_field :name_cont, class: "form-control"
 .form-group
   = f.submit class "btn btn-outline-primary"

= link_to "", new_task_path, class: "btn"
```

`search_form_for`は、ransackが提供するヘルパー

`nane_cont`nameを含んでいるという意味。nameに検索文字列を含むものを検索してくれる

`_cont`とは、ransackが用意している検索マッチャー。検索文字列を含むものを検索する。SQLの`ILIKE`を発行できる

```
SELECT DISTINCT "tasks".* FROM "tasks" WHERE "tasks"."user_id" = $1 AND "tasks"."name" ILKE '%<検索文字列>%' ORDER BY "tasks"."created_at" DESC
```

このようなSQLが発行される

<br>

## 登録日時による検索

名称以外に登録日時で検索できるようにする

```
# tasks/index.html.slim

h1 タスク一覧

= search_form_for @q, class: "mb-5" do |f|
 .form-group.row
   = f.label :name_cont, "名称", class: "col-sm-2 col-form-label"
   .col-sm-10
     = f.search_field :name_cont, class: "form-control"
 .form-group.row
   = f.label :created_at_gteq, "", class: "col-sm-2 col-form-label"
   .col-sm-10
     = f.search_field :created_at_gteq, class: "form-control"
 .form-group
   = f.submit class "btn btn-outline-primary"

= link_to "", new_task_path, class: "btn"
```

`gteq`とは、検索マッチャーで、`greater than or equal`の略。「該当の項目がフォームに入力した値と同じか、それより大きいこと」を条件にしたいときに使う。

日時の場合は、「入力した日時と同じか、それより未来の日時」を検索してくれる

```
SELECT DISTINCT "tasks".* FROM "tasks" WHERE "tasks"."user_id" = $1 AND "tasks"."created_at" >= "<検索日時>" ORDER BY "tasks"."created_at" DESC
```

<br>

名称と登録日時ダブルで検索

```
SELECT DISTINCT "tasks".* FROM "tasks" WHERE "tasks"."user_id" = 1$ AND ("tasks"."name" ILIKE '%表示機能' AND "tasks"."created_at" >= "<検索日時>") ORDER BY "tasks"."created_at" DESC
```

<br>

## 条件を絞る

画面上、名称と登録日時でしか検索できないが、ユーザーが意図的にdescription_contなどのパラメーターを加工し送れば、descriptionについての検索ができてしまう。したがって、検索に利用するカラムの範囲を制限する必要がある

```
# model/task.rb

class Task < ApplicationRecord
 def self.ransackable_attributes(auth_object = nil)
   %w[name created_at]
 end

 def self.ransackable_associations(auth_object = nil)
   []
 end
end
```

`ransackable_attributes`には、検索対象にすることに許可するカラムを指定する。デフォルトでは、すべてのカラムを対象としている。

ransackable_attributesをオーバーライドして、名称(name)、作成日時(created_at)を指定することで、それ以外のカラムについての検索条件がransackに渡されても無視されるようになる

`ransackable_associations`は、検索条件に含める関連を指定できる。このメソッドを空の配列を返すようにオーバーライドすることで、検索条件に意図しない関連を含めないようにできる

rasnsackを利用する場合は、params[:q]などには何が入っても良いことにしておき、モデル側で制御することが一般的

<br>

## 一覧画面にソート機能

現在はTaskモデルに実装した、`recent`スコープを利用して、登録日時でソートが行われるようになっている。

これを、ユーザーが任意の項目(名称の降順・昇順)でソートできるようにする。

`sort_link`ヘルパーとは、ransackが提供するソート用のヘルパーメソッド。第1引数には、コントローラーでransackメソッドを呼び出して得られた`Ransack::Search`オブジェクト(今回は`@q`)、第2引数には、ソートを行う対象のカラム(:name)を指定する

```
# tasks_controller.rb

def index
 @q = current_user.tasks.ransack(params[:q])
 @tasks = @q.result(distinct: true) # 先ほどまでのrecentを取り消す（ransackでソートするから）
end
```

```
# tasks/index.html.slim

table.table.table-hover
 thead.thead-default
   tr
     th= sort_link(@q, :name)
     th= Task.human_attribute_name(:created_at)
     ...
```

名称をクリックするとまずは、昇順でソートされる。再度クリックすると降順になる

最初のクリックで降順にするためには`sort_link(@q, defailt_order: :desc)`にする

`sort_link`は複合的な条件のソートを指定することもできる。基本的には名称でソートし、名称が同じであれば登録日時順にソートする場合、`sort_link(@q, :name, [:name, "created_at desc"])`

<br>

## メールを送る

`Action Mailer`とは、Railsがメールを送るために用意したコントローラーみたいな仕組みのこと。コントローラーがテンプレートを通じて画面を出力するように、メイラーはテンプレートを通じてメールを作成・送信する

`$ bin/rails g mailer Taskiler`

作成したメイラーに、タスク登録の通知メールを送るためのメソッドを追加

```
# mailers/task_mailer.rb

class TaskMailer < ApplicationMailer
 def creation_email(task) # 1
   @task = task  # 2
   mail(
     subject: "タスク作成完了メール",
     to: 'user@example.com',
     from: 'taskleaf@example.com'
   )
 end
end
```

1の、creation_emailの引数としてTaskオブジェクトを受け取るようにしている。このtaskは、メール本文作成のためにテンプレートで利用するので、@taskに代入しておく

subject(タイトル),to(宛先),from(送信者)、他にもcc,bccも指定できる

どの種類のメールでも、送信者は同じ場合、指定ができる

```
# mailers/task_mailer.rb

class TaskMailer < ApplicationMailer
 default from: "taskleaf@example.com"

 def creation_email(task) # 1
   @task = task  # 2
   mail(
     subject: "タスク作成完了メール",
     to: 'user@example.com',
   )
 end
end
```

<br>

## テンプレートの実装

メイラーから呼び出されるテンプレートのパスは、特に指定していない場合、メイラーのクラス名とメソッド名から推測される。今回は`app/views/task_mailer/create_email.拡張子`ファイルが対応する

メールを作成する際は、テキスト形式のメールを送るか、HTML形式のメールを送るか２つの方法がある。HTML形式のメールを送る場合は、受信者の環境に配慮して、テキスト形式の情報も合わせて送るやりかた(multipart/alternative形式)が一般的

mulipart/alternativeでメールを送るには、html形式とtext形式の２種類のテンプレートを用意する

```
# html形式 app/views/task_mailer/creation_email.html.slim

| 以下のタスクを作成しました

ul
 li
   | 名称:
   = @task.name
 li
   | 詳しい説明:
   = simple_format(@task.descrition)
```

```
# text形式 app/views/task_mailer/creation_email.text.slim

| 以下のタスクを作成しました
= "\n"
| 名称:
= @task.name
= "\n"
| 詳しい説明:
= "\n"
= @task.descrition
```

<br>

## メール送信処理

```
# tasks_controller.rb

def create
 @task = Task.new(task_params)

 if params[:back].present?
   render :new
   result
 end

 if @task.save
   TaskMailer.creation_email(@task).deliver_now # 1
   redirect_to @task, notice: "=="
 else
   render :new
 end
end
```

task_controller createアクション内に、１を追記

`deliver_now`は、即時送信するためのメソッド。

`deliver_later`メソッドは、送信する時刻を指定できる。`TaskMailer.creation_email(@task).deliver_later(wait: 5.minutes)`とすることで、このメソッドが呼び出された５分後にメールを送信するようにできる

<br>

## 動作確認

`mailcatcher gem`を使うことで、シンプルなSMTPサーバーを立てて、送信されたメールをブラウザ上で確認することができる

`$ gem install mailcatcher`コマンドを実行し、インストール(bundle コマンドでインストールすると正常に動作しない場合があるため)

「taskleafのdevelopment環境でmailcatcherのSMTPサーバーを利用する」という設定をアプリ側で追加する必要がある

```
# config/environments/development.rb

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { address: '127.0.0.1', port: 1025 }
```

production環境でも同様の設定が必要なので、実際に使用するSMTPサーバーの設定を追記する必要があるよ

1. mailcatcherの起動 `$ mailcatcher`
2. 新規登録画面に移動してタスクを登録
3. 送信されたメールを`http://127.0.0.1:1080`にアクセスして確認
4. ブラウザ右上の`Quit`ボタンを押し、mailcatcherを終了させる

<br>

## メイラーのテスト

`$ mkdir spec/mailers`

`$ touch spec/mailers/task_mailer_spec.rb`

```
# spec/mailers/task_mailer_spec.rb

require 'rails_helper'

describe TaskMailer, type: :mailer do
 let(:task){ FactroyBot.create(:task, name: "メイラーSpecを書く", description: "送信したメールの内容を確認します")}   # 2

 let(:text_body) do   # 3
   part = mail.body.parts.detect { |part| part.content_type == "text/plain; charset=UTF-8" }
   part.body.raw_source  
 end

 let(:html_body) do   # 4
   part = mail.body.parts.detect { |part| part.content_type == "text/html; charset=UTF-8" }
   part.body.raw_source
 end

 describe '#create_email' do   # 5
   let(:mail) { TaskMailer.creation_email(task) }  # 6

   it '想定通りのメールが生成されている' do
     # header
     expect(mail.subject).to eq("タスク作成完了メール")
     expect(mail.to).to eq(["user@example.com"])
     expect(mail.from).to eq(["taskleaf@example.com"])

     # text形式
     expect(text_body).to match("以下のタスクを作成しました")
     expect(text_body).to match("メイラーSpecを書く")
     expect(text_body).to match("送信したメールの内容を確認します")

     # html形式
     expect(html_body).to match("以下のタスクを作成しました")
     expect(html_body).to match("メイラーSpecを書く")
     expect(html_body).to match("送信したメールの内容を確認します")
   end
 end

end
```

将来的に、他の種類のメールを送ることが考えられるため`5`にてcreation_emailメソッド専用部分に分けている

共通的なテストデータとしてtaskというletを用意(2)。また、生成されるメールをmailという名前で参照できるように想定している。このmailからtext形式とhtml形式のbody内容を手軽に得られるよう、text_bodyとhtml_bodyというletを用意(3.4)

creation_emailメソッドについてのdescription(5)内では、実際にcreation_emailメソッドを使ってメールを生成し、生成したメールオブジェクトをmailという名前で参照できるようにletを定義している(6)

it内で、mailに対する期待を記述

`$ bundle exec rspec spec/mailers/task_mailer_spec.rb `

<br>

## ファイルをアップロードしてモデルに添付する

注意：確認画面の実装をいったん無視する

`Active Storage`とは、ファイル管理gemであり、クラウドストレージサービス(AWS S3など)へファイルをアップロードして、データベース上でActiveRecordモデルに紐づけることが簡単にできる。画像については、サイズや形式の変換、ビデオ・PDFなどについてはプレビュー機能を提供する

Rails5.2以降 rails newしたときにインストールされている

`$ bin/rails active_storage:install`を実行

`db/migration/xxxxx_crete_active_storage_tales.activ_storage.rb`が作成され、以下の２つのテーブルを作成する

`ActiveStorage::Blob`は、添付されたファイルに対応するモデル。ファイルの実体をデータベース外で関することを前提にしており、それ以外の情報、すなわち識別key、ファイル名、Content-Type、ファイルのメタデータ、サイズなどを管理する

`ActiveStorage::Attachment`は、ActiveStorage::Blobとアプリ内の様々なモデルを関連付ける中間テーブルにあたるモデル。関連付けるモデルのクラス名や連携するFKカラム名を、Fk値と共に保持する(`ポリモーフィック関連`)。

一方、ActiveStorage::Blobとは、直接的にidのみで紐づいている

今回、TaskとActiveStorage::Blobを紐づける。

`Task`は、`ActiveStorage::Attachment`に対して`has_many`or`has_one`の関係

`ActiveStorage::Attachment`は、`Task`に対して、`belongs_to`の関係

`ActiveStorage::Attachment`は、`ActiveStorage::Blob`に対して`blongs_to`の関係

`ActiveStorage::Blob`は、`ActiveStorage::Attachment`に対して`has_many`な関係


`$ bin/rails db:migrate`

次に、添付したファイルの実態を管理する場所についての設定をする。設定は`Rails.application.config.active_storage.service`にファイルを管理する場所の名前を与えて、その名前に対応する設定を`config/storage.yml`に定義する

デフォルトでは、development環境のファイル管理場所はlocal

```
# config/environments/development.rb

config.active_storage.service = :local # となっている
```

```
# config/storage.yml

test:
 service: Disk
 root: <%= Rails.root.join("tmp/storage")%>

local:
 service: Disk
 root: <%= Rails.root.join("storage")%>
```

つまり、Railsアプリが配置されたディレクトリ配下の`storage`ディレクトリに格納する設定になっている

Active　Storageの設定は、開発環境ではローカル、本番環境ではS3など複数の管理場所を定義できる

<br>

```
# models/task.rb

has_one_attached :image
```
を追加し、１つのタスクに１つの画像を紐づけること、その画像をTaskモデルからimageと呼ぶことを指定

```
# tasks_new.html.slim

= f.label :image
= f.file_field :image, class: "form-control"
```

を追記

```
# config/locales/ja.yml

description: 詳しい説明
image: 画像
```

を追記

```
# tasks_controller.rb

def task_params
  params.require(:task).permit(:name, :description, :image)
end
```

```
# tasks_show.html.slim

tr
  th= Task.human_attribute_name(:image)
  th= image_tag @task.image if @task.image.attached?
```

`image_tag`を使う場合、実際にが画像が添付されていないとエラーになってしまうため、`attached?`メソッドで判定し、実際に画像が添付されている時だけimage_tagを表示させるようにする

<br>

## CSVのインポート・エクスポート

```
# config/application.rb

require 'csv'
```

タスクをCS出力（エクスポート）するには、Taskモデルで、`to_csv`クラスメソッドを追加する

```
# models/task.rb

def self.csv_attributes
 ["name","description","created_at","updated_at",]  # 1
end

def self.generate_csv
 CSV.generate(headers: true) do |csv|  # 2
   csv << csv_attributes               # 3
   all.each do |task|
     csv << csv_attributes.map{ |attr| task.send(attr) }   # 4
   end
 end
end
```

1. CSVデータにどの属性をどの順番で出力するかを`csv_attributes`クラスメソッドから得られるように定義
2. CSV.generateを使ってCSVデータの文字列を生成する。生成した文字列がgenerate_csvクラスメソッドの戻り値となる
3. CSVの1行目としてヘッダを出力。1の属性名をそのまま属性として使用
4. allメソッドで全タスクを取得し、１レコードごとにCSVの1行を出力する。その際は、1の属性ごとにTaskオブジェクトから属性値を取り出してcsvに与える

次に、`geberate_csv`クラスメソッドを呼び出すコントローラー側の実行

```
# tasks_controller.rb

def index
 @q = current_user.tasks.new(task_params)
 @tasks = @q.result(distinct: true)

 respond_do |format|  # 1
   format.html        # 2
   format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }  # 3
 end
end
```

1. format.htmlは、HTMLとしてアクセスされた場合(URLに拡張子なしでアクセスされた場合)、format.csvは、CSVとしてアクセスされた場合(/tasks.csvというURLでアクセスされた場合)にそれぞれ実行される
2. HTMLフォーマットについては特に処理を指定しない。そのため、今まで通りデフォルトの動作としてindex.html.slimによって画像が表示される
3. CSVフォーマットの場合は、`send_data`メソッドを使ってレスポンスを送り出し、送り出したデータをブラウザからファイルとしてダウンロードできるようにしている。レスポンスの内容は先ほどの`Task.generate_csv`が生成するCSVデータとしている。ファイル名は、ダウンロードするたびに異なるファイル名になるように、現在時刻を使って作成する

```
# views/tasks/index/html.slim

= link_to "", tasks_path(format: :csv), class: "btn btn-primary mb-3"
```

`format: :csv`という指定をすることで、`/tasks.csv`というURLを生成する

<br>

## CSVデータのインポート

インポートの流れ。

一覧画面にインポート操作のUIを設ける → CSVファイルをアップロードして、CSVファイルの内容に沿ってデータベースにタスクを登録する

Taskモデルに`import`というクラスメソッドを実装する(generate_csvメソッドの下に)

```
# models/task.rb

def self.import(file)   # 1
 CSV.foreach(file.path, headers: true) do |row|  # 2
   task = new       # 3
   task.attributes = row.to_hash.slice(*csv_attributes)  # 4
   task.save!  # 5
 end
end
```

1. fileという名前の引数で、アップロードされたファイルの内容にアクセスするためのオブジェクトを受けとる
2. CSV.foreachを使って、CSVファイルを行ずつ読み込む。`headers: true`の指定により、1行目をヘッダとして無視するようにする。つまり１行目をheaderにする
3. CSV１行ごとに、Taskインスタンスを生成する(newはTask.newと同意。ここはクラスメソッドの中で、selfがTaskの状態なので記述を省略している)
  1. 厳密には、このimportメソッドが Task.importのようにクラスに対して直接呼ばれる場合に、Task.newと同意になる。後述するコントローラーのコードのようにcurrent_user.tasks.importという具合に関連を経由して呼ばれる場合には、関連のnewの挙動として、Taskオブジェクトにuserの関連が入った状態で生成する
4. 3で生成したTaskインスタンスの各属性に、CSVの１行の情報を加工して入れ込む。
  1. `rowのto_hash`メソッドを呼ぶことで、「属性1の値、属性2の値、、、」というデータを { 属性1のヘッダ名 => 属性1の値, 属性2のヘッダ名 => 属性2の値 }というハッシュの形に変換している
5. Taskインスタンスをデータベースに登録する

`sliceメソッド`とはRailsがHashクラスに追加しているメソッド。指定した安全なキーに対応するデータだけを取り出して入力用に使うようにしている。

よって、ユーザーがCSVのヘッダを加工してインポートを行うと、本来インポートするつもりがなかった属性まで入力してしまう危険性をなくすことができる。

なお、sliceの引数に指定している`*csv_attributes`は、csv_attributesメソッドの戻り値の配列内の要素をそれぞれ引数に指定する書き方。

slice("name","description","creatde_at","updated_at")と記述しているのと同じ意味

```
# tasks_controller.rb

def import  # 1
 current_user.tasks.import(params[:file])
 redirect_to tasks_url, notice: "タスクを追加しました"  # 2
end
```

1. 画面上のフィールドからアップロードされたファイルオブジェクト(アップロードされたファイルは、Railsが一時的なファイルとして保存している)を引数に、関連越しに先ほど実装したimportメソッドを呼び出している。よって、アップロードされたファイルの内容を、ログインしているユーザーのタスク群として登録することができる
2. インポート完了後、タスク一覧画面にリダイレクト、ノーティスを表示

```
# routes.rb

resources :tasks do 
 post :confirm, action: :confrim_new, on: :new
 post :import, on: :collection
end

import_tasks POST /tasks/import(:formata) Create#import
```

```
# tasks/index.html.slim

= form_tag impot_tasks_path, multipart: true, class: "mb-3" do
 = file_field_tag :file
 = submit_tag "インポート", class: "btn btn-primary"
```

なんらかのcsvファイルを作成する

```
name.description,created_at,upadted_at
餃子を作る,160個作ります 
餃子を冷凍する, 160個は食べきれないので冷凍する
```

1行目はヘッダとして扱われるため、Taskレコードとして取り込まれない。2行目以降がタスクレコードとして取り込まれる。created_at updated_atを指定していない場合は、取り込まれた時刻で登録される

現状だと、ファイルを選択していない状態でインポートボタンを押すと、エラーになったり、CSVファイルの不備のチェックが不親切だったり、重複があっても構わず登録されてしまうなどの課題が残っている

<br>

## ページネーション

`gem 'kaminari'`を追加し、`$ bundle`

修正内容

1. 表示するページの番号が`parasm[:page]`でアクションに渡されるようになる
2. アクションでは、Taskデータを全件検索する代わりに、ページ番号(`params[:page]`)に対応する範囲のデータを検索するようにする
3. ビューでは、アクションから渡されたタスクデータを表示するのに加えて、現在どのページ・全件中何件を表示しているのかなどの情報や、他のページに移動するためのリンクを表示する

<br>

もし、2ページ目を表示したい場合は、`"/tasks?page=2"`というURLでリクエストされ、`params[:page]に2`が入っていると想定する

また、特にページ番号の指定をしない場合は、`"/tasks"`でもアクセスできるようにして、その場合は`params[:page]がnil`だが、1ページ目が指定されたと同様の挙動をする

```
# tasks_controller.rb

def index
 @q = current_user.tasks.ransack(params[:q])
 @tasks = @q.result(distinct: true).page(params[:page])
end
```

デフォルトでは、1ページあたりに表示するレコード件数は、`25件`

<br>

ビューに、ページネーションを行う際に必要となる情報を表示する

1. 現在どのページを表示しているのかの情報
2. ほかのページに移動するためのリンク
3. 全データが何件なのかといった情報

`paginate`は、1.2のためのヘルパーメソッド

`page_entries_info`は、3のためのヘルパーメソッド

```
# views/tasks/index.html.slim

= link_to "", new_task_path, class: "btn btn-primary"

.mb-3
 = paginate@tasks
 = page_entries_info @tasks
```

kaminariが内部的に用意している翻訳ファイルはenのみなため、自分で用意する

```
# config/locales/kaminari.ja.yml

ja:
 views:
   pagination: 
     first: "&laquo; 最初"
     last: "最後 &raquo;"
     previous: "次 &rsaquo;"
     truncate: "&hellip;"
 helpers:
   page_entries_info:
     one_page:
       display_entires:
         zero: "%{entry_name}がありません"
         one: "1件の%{entry_nama}が表示されています"
         other: "%{count}件の%{entry_name}が表示されています"
     more_pages:
       display_entries: "%{total}件中%{first}&nbsp;-&nbsp;%{last}件の%{entry_name}が表示されています"
```

<br>

動作確認のため、テストデータをコンソールで作成する

```
user = User.find(1)
100.times { |i| user.tasks.creat!(name: "サンプルタスク#{i}") }
```

<br>

デザインを整えるため、今回はbootstrap4というテーマのパーシャルテンプレートを生成する

`$ bin/rails g kaminri:views bootstrap4`を実行することで、`app/views/kaminari`配下にいくつかのビューテンプレートファイルが追加される

<br>

表示件数の変更の方法

1. perスコープで指定する
2. paginates_perを使って、モデルごとのデフォルトの表示件数を指定する
3. kaminariの設定ファイルを使って全体的なデフォルト表示件数を指定する

1のperスコープで指定する方法

1ページに50件表示させたい場合(アクション限定の指定)

`@tasks = @q.result(distinct: true).page(params[:page]).per(50)`

<br>

2のper_pageを使って、モデルごとのデフォルトの表示件数を指定する

```
models/task.rb

class Task < ApplicationRecord
 paginates_per 50
```

<br>

3のkaminariの設定ファイルを使って全体的なデフォルト表示件数を指定する

`$ bin/rails g kaminari:config`で設定ファイルを生成

```
# config/initializers/kaminari_config.rb

kaminiari.confiure do |config|
 config.default_per_page = 50
end
```

<br>

## 非同期処理や定期実行を行う(Jobスケジューリング)

`Acrtive Job`とは、Railsでバックグラウンドで非同期処理を行うためのフレームワーク

- アクションの処理が重くてユーザーを待たせてしまっている。重い処理を非同期処理として切り出し、アクションでは処理の受付だけを行うことで快適に操作できるようになる
- 「明日の朝9時に処理を実行する」などの日時を指定して処理を実行できる


今回は、`Sidekiq`という非同期処理ツールを使う。他にも`Resque`,`DelayedJob`などがある。

`Sidekiq`では、キーバリュー型のデータベースの`Redis`を利用しているため、`$ brew install redis` 導入する

`$ redis-server`でRedisサーバーを起動する

これから先に行うSidekiqによる非同期処理の実行は、Redisサーバーが起動されている状態でなければ実行できないので注意！

<br>

`Sidekiq`の導入

`gem 'sidekiq'`

`$ bundle`

`$ bundle exec sidekiq` でsidekiqを起動させる

RedisとSidekiqを連携させる

```
# config/environmets/development.rb

config.active_job.quene_adapter = :sidekiq
```

<br>

ジョブの作成・実行

`$ bin/rails g job sample` sample jobのひな形を作成

```
# app/jobs/sample_job.rb

class SampleJob < ApplicationJob
 quene_as :default

 def perform(*args)
   Sidekiq::Logging.logger.info "サンプルジョブを実行しました"
 end
end
```

処理が実行されていることがわかりやすように、Sidekiqのログにメッセージを表示させる

```
# tasks_controller.rb

def create
 if @task.save
   TaskMailer.creation_email(@task).deliver_now
   SampleJob.perform_later
   ...
 end
end
```

`perform_later`メソッドを使って作成したログ出力のジョブを非同期に実行させる。

`perform_later`は、ジョブの実行を予約するだけ(ジョブを登録)で、ジョブの処理の開始や完了を待つことはない。ジョブの処理は、もしもこの時点で非同期処理ツールが他のジョブの実行で忙しいなどすぐに対応できない状態であれば、処理できる状態になった時点で開始される

ブラウザからタスクを登録し、Sidekiqを起動しているターミナルに"サンプルジョブを実行しました"とログが出ていれば、ジョブ成功

<br>

実行日時の指定

`SampleJob.setz(wait_until: Date.tomorrow.noon).perform_later`とすることで、「翌日の正午」にジョブを実行する予約ができる

`SampleJob.set(wait: 1.week).perform_later`とすることで、1週間後にジョブを実行する

Sidekiqでは、複数のジョブを並列で実行できる（最大25個）。その際、キュー(`queue`)という仕組みを使って優先順位をつけることができる。