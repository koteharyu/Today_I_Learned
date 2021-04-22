## Everyday Rspec

```
# Gemfile

group: :development, :test do
 gem 'rspec-rails', '~> 3.6.0'
end
```

`binstub`を使うことで、テストスイートの起動時間を速くすることが出来る。なぜなら`Spring`の恩恵を受けることが出来るから。

`Spring`とは、アプリケーションをバックグラウンドで実行し続けることで、開発スピードをアップすることができる。

`$ bundle exec rspec`コマンドでRSpecを実行することで、binstubを使うことができる

```
# Gemfile

group: :development do
 gem 'spring-commands-rspec'
enb
```

`$ bundle exec spring binstub rspec`コマンドで、新しいbinstubを作成する

`$ bin/rspec`コマンドで、まだテストを書いていなくてもRSpecが正しくインストールされているか確認できる


```
# config/application.rb

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

...
config.generates do |g|
 g.test_framework :rspec,
   fixtures: false,
   view_specs: false,
   helper_specs: false,
   routing_spec: false
end
```

- fixtures: false は、テストデータベースにレコードを作成するファイルの作成をスキップする
- view_specs: false　は、ビュースペックを作成しないことを指定する。今回は、ビュースペックを使わない代わりに、`feature spec`を利用する
- helper_specs: false　は、ヘルパーファイル用のスペックを作成しないことを指定する。ヘルパーファイルは、Railsがコントローラーごとに作成するファイル。
- routing_spec: false　は、config/routes.rb 用のスペックファイルの作成を省略する。アプリが大きくなったらtrueにするものよし

<br>

Factory Botのインストール

```
# Gemfile

group :development, :test do
 gem 'rspec-rails', '~> 3.6.0'
 gem 'factory_bot_rails', '~> 4.10.0'
end
```

config/application.rb内の`fixture: false`の行を削除する

```
# config/application.rb

config.generators do |g|
 g.test_framework :rspec,
   view_specs: false,
   helper_specs: false,
   routing_specs: false
end
```

'$ bin/rails g factory_bot:model user'コマンドで、新しいファクトリを作成するためのフォルダ・ファイルを作成

```
# spec/factories/users.rb

FactoryBot.define do
 factroy :user do
   first_name "Aaron",
   last_name "Sumner",
   email "tester@example.com",
   password "password"
 end
end
```

上記の記述により、テストコード内で、`FactoryBot.create(:user)`と記述するだけで、ファクトリを使えるようになる

ファクトリが正しく書けたかのテスト

```
# spec/models/user_spec.rb

describe User do
 it 'has a valid factory' do
   expect(FactoryBot.build(:user)).to be_valid
 end
end
```

<bt>

`FactoryBot.build`を使うと、新しいテストオブジェクトをメモリ内に保存する

`FactoryBot.create`を使うと、アプリケーションのテスト用データベースにオブジェクトを永続化する

<br>

`sequence`を使うことで、ユニークバリデーションを持つフィールドを扱うことが出来る。シーケンスはファクトリから新しいオブジェクトを作成するたびに、カウンタの値を1ずつ増やしながら、ユニークにならなければいけない属性に値を設定する

```
FactoryBot.define do
 factory :user do
   first_name "Aaron"
   last_name "Sumner"
   sequence(:email) { |n| "tester#{n}@example.com" }
   password "password"
 end
end
```

<br>

ファクトリで関連を扱う

```
FactoryBot.define do 
 factory :note do
   message "My importrant note"
   association :project
   association :user
 end
end
```

<br>

以下のような関連を持つ、projectモデルある場合

```
# models/project.rb

class Project < ApplicationRecord
 validates :name, presence: true, uniqueness: {scope: :user_id} # 同じユーザーIDの重複を防止する記述

 belongs_to :owner, class_name: User, foreign_key: :user_id
 has_many :tasks
 has_many :notes
end
```

下記、porjects.rbのためにエイリアスを定義する

```
# factories/users.rb
FactoryBot.define do
 factory :user, aliases: [:owner] do
   first_name "Aaron"
   last_name "Sumner"
   sequence(:email) {|n| "tester#{n}@example.com"}
   password "password"
 end
end
```

スケジュール通りのプロジェクトと、スケジュールから遅れているプロジェクトをテストする場合、以下の2種類の方法で、重複を避け、ファクトリを書ける

1. ファクトリの継承(ユニークな属性だけを変える方法)
2. `trait`を使ってテストデータを構造する方法。属性値の集合をファクトリで定義する

`be_late`マッチャとは、projectにlateまたはlate?という名前の属性やメソッドが存在し、それが真偽値を返すようになっていればtrueを返すようなRSpecには定義されていないマッチャ

```
# 無加工
# factories/projects.rb
FactoryBot.define do
 factory :project do
   sequence(:name) {|n| "test project #{n}"}
   description "sample project for testing pirposes"
   due_on 1.week.from_now
   association :onwer
 end

 factory :project_due_yesterday, class: Project do
   sequence(:name) {|n| "test project#{n}"}
   description "sample project for testing pirposes"
   due_on 1.day.ago
   association :owner
 end

 factory :project_due_today, class: Project do
   sequence(:name) {|n| "test project#{n}"}
   description "sample project for testing pirposes"
   due_on Date.current.in_time_zone
   association :owner
 end

 factory :project_due_tomorrow, class: Project do
   sequence(:name) {|n| "test project#{n}"}
   description "sample project for testing pirposes"
   due_on 1.day.from_now
   association :owner
 end
end
```

```
# 継承
FactoryBot.define do
 factory :project do
   sequence(:name) {|n| "test project #{n}"}
   description "sample project for testing pirposes"
   due_on 1.week.from_now
   association :onwer

   factory :project_due_yesterday do
     due_on 1.day.ago
   end

   factory :project_due_todya do
     due_on Date.current.in_time_zone
   end

   factory :project_due_toworrow do
     due_on 1.day.from_now
   end
 end
end
```

継承は、継承元となる:projectファクトリの内部で入れ子になっている。

class: Projectの記述をしなくてよい



```
# spec/models/project_spec.rb (継承を使ってファクトリしたバージョン)

describe 'late status' do
 it 'is late when the due date is past today' do
   project = FactoryBot.create(:project_due_yesterday)
   expect(project).to be_late
 end

 it 'is on time when the due date is today' do
   project = FactoryBot.create(:project_due_today)
   expect(project).to_not be_late
 end

 it 'is on time when the due date is in the future' do
   project = FactoryBot.create(:project_due_tomorrow)
   expect(project).to_not be_late
 end
end
```

```
# trait
FactoryBot.define do 
 factoy :project do
   sequence(:name) {|n| "test project #{n}"}
   description "sample projeect for testing purposes"
   due_on 1.week.from_now
   association :onwer

   trait :due_yesterday do
     due_on 1.day.ago
   end

   trait :due_today do
     due_on Date.current.in_time_zone
   end

   trait :due_tomorrow do
     due_on 1.day.from_now
   end
 end
end
```

```
# spec/models/project_spec.rb (traitバージョン)
describe 'late status' do
 it 'is late when the due date is past today' do
   project = FactoryBot.create(:project, :due_yesterday)
   expect(project).to be_late
 end

 it 'is on time when the due date is today' do
   project = FactroyBot.create(:project, :due_today)
   expect(project).to_not be_late
 end

 it 'is on time when the due date is in the future' do
   project = FactoryBot.create(:project, :due_tomorrow)
   expect(project).to_not be_late
 end
end
```

<br>

コールバックとは、create build stubする前・後に何かしらのアクションを実行すること。

`create_listメソッド`とは、コールバックを利用して、なにかしらのアクションを指定するメソッド

たとえば、新しいオブジェクトが作成されたら自動的に複数のメモを作成する処理はこうなる

```
FactoryBot.define do 
 factoy :project do
   sequence(:name) {|n| "test project #{n}"}
   description "sample projeect for testing purposes"
   due_on 1.week.from_now
   association :onwer

   trait :with_notes do
     after(:create) {|project| create_list(:note, 5, project: project)}
   end
 end
end
```

```
# spec/models/project_spec.rb

it 'can have many notes' do
 project = FactoryBot.create(:project, :with_notes)
 expect(project.notes.lenght).to eq 5
end
```

<br>

Controlle テスト。いまじゃあんま使わないけど

```
# spec/controllers/home_controller_spec.rb

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
 describe '#index' do
   get :index
   expect(response).to be_success
 end
end
```

`expect(resconse).to be_success`の`response`とは、ブラウザに返すべきアプリの全データを保持しているオブジェクト。

`be_success`とは、レスポンスステータスが成功(200)か、それ以外(たとえば500エラー)であるかをチェック

それか、特定のHTTPレスポンスが返ってきているかのチェックもできる

`expect(response).to have_http_status "200"`とも書けるよ

もし`Devise`を使っているのであれば、rails_helperにその旨を伝えよう

```
# spec/rails_helper.rb

RSpec.configure do |config|
 config.include Devise::Test::ControllerHelpers, type: :controller
end
```

before_action :authenticate_user!を指定していた場合でも、テストでは、認証されたユーザーでログインする必要があるよ
<br>

Postメソッド

```
# プロジェクトが追加できること

it 'adds a project' do
 project_params = FactoryBot.attributes_for(:project)
 sign_in @user
 expect{
   post :create, params: { project: project_params }
 }.to change(@user.projects, :count).by(1)
end

context 'as a guest' do
 it 'returns a 302 response' do
   project_params = FactoryBot.attributes_for(:project)
   post :create, params: {project: project_params}
   expect(response).to have_http_status "302"
 end

 it 'redirects to the sign-in page' do
   project_params = FactoryBot.attributes_for(:project)
   post :create, params: {project: project_params}
   expect(response).to redirect_to "/users/sign_in"
 end
end 
```

<br>

Updateメソッド

```
describe '#update' do
 context 'as an authorized user' do
   before do
     @user = FactoryBot.create(:user)
     @project = FactroyBot.create(:project, owner: @user)
   end

   it 'updates a project' do
     project_params = FactoryBot.attributes_for(:project, name: "new project name")
     sign_in @user
     patch :update, params: {id: @project.id, project: project_params}
     expect(@project.reload.name).to eq "new project name"
   end
 end
end
```

`FactoryBot.attributes_for(:project)`は、プロジェクトファクトリからテスト用の属性値をハッシュとして作成する

ユーザーのログインをシミュレートし、元のプロジェクトのidと一緒に新しいプロジェクトの属性値をparamsとしてPATCHリクエストで送信している

`reloadメソッド`を使うことで、メモリに保存されている値の再利用を防止している

<br>

認可されていないユーザーの場合

```
describe '#update' do
 context 'as an unauthorized user' do
   before do 
     @user = FactoryBot.create(:user)
     other_user = FactoryBot.create(:user)
     @project = FactoryBot.create(:project, owner: other_user, name: "same old name")
   end

   it 'does not update the project' do
     project_params = FactroyBot.attributes_for(:project, name: "new name")
     sign_in @user
     patch :upadte, params: {id: @project.id, project: project_params}
     expect(@project.reload.name).to eq "same old name"
   end

   it 'redirects to the dashboard' do
     project_params = FactoryBot.attributes_for(:project)
     sign_in @user
     patch :update, params: {id: @project.id, project: project_params}
     expect(response).to redirect_to root_path
   end
 end
end
```

<br>

destory

認可されたユーザーであれば、自分のプロジェクトは削除できるが、他のユーザーのプロジェクトは削除できない

```
# project_controller_spec.rb

describe '#destroy' do
 context 'as an authorized user' do
   before do
     @user = FactoryBot.create(:user)
     @project = FactoryBot.create(:project, owner: @user)
   end

   it 'deletes a project' do
     sign_in @user
     expect{
       delete :destroy, params: {id: @project.id }
     }.to change(@user.projects, :count).by(-1)
   end
 end

 context 'as an unauthorized user' do
   before do 
     @user = FactoryBot.create(:user)
     other_user = FactoryBot.create(:user)
     @project = FactoryBot.create(:project, owner: other_user)
   end

   it 'does not delete a project' do
     sign_in @user
     expect{
       delete :destroy, params: {id: @project.id }
     }.to_not change(Project, :count)
   end

   it 'redirects to the dashboard' do
     sign_in @user
     delete :destroy, params: {id: @project.id}
     expect(response).to redirect_to root_path
   end
 end

 context 'as a guest' do
   before do
     @project = FactoryBot.create(:project)
   end

   it 'returns a 302 response' do
     delete :destroy, params: {id: @project.id}
     expect(response).to have_http_status "302"
   end

   it 'redirects to the sign-in page' do
     delete :destroy, params: {id: @project}
     expect(response).to redirect_to "/users/sign_in"
   end

   it 'does not delete a project' do
     expect{
       delete :destory, params: {id: @project.id}
     }.to_not change(Project, :count)
   end
 end
end
```

<br>

無効な値を入れたプロジェクトの作成の場合

まずは、traitで無効な値を作成。createアクションを実行したときに、名前のないプロジェクトの属性値が送信されるが、コントローラーは新しいプロジェクトを保存しない

```
# factories/project.rb

FactoryBot.define do
 factory :project do
   sequence(:name) {|n| "test project #{n}"}
   description "sample project for testing purposes"
   due_on 1.week.from_now
   association :owner

   trait :invalid do
     name nil
   end
 end
end
```

```
# project_spec.rb

describe '#create' do
 context 'as an authorized user' do
   before do 
     @user = FactoryBot.create(:user)
   end

   context 'with vaild attributes' do 
     it 'adds a project' do
       sign_in @user
       project_params = FactoryBot.attributes_for(:project)
       expect{
         post :create, params: {project: project_params}
       }.to change(Project, :count).by(1)
     end
   end

   context 'with invalid attributes' do
     it 'does not add a project' do
       sign_in @user
       project_params = FactoryBot.create(:project, :invalid)
       expect{
         post :create, params: {project: project_params}
       }.to_not change(Project, :count)
     end
   end
 end
end 
```

<br>

HTML以外の出力を扱う(JSON)

`$ bin/rails g rspec:controller tasks`

```
# spec/controllers/tasks_controller_spec.rb

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
 before do
   @user = FactoryBot.create(:user)
   @project = FactoryBot.create(:project, owner: @user)
   @task = @project.tasks.create!(name: "test task")
 end

 describe '#show' do
   it 'responds with json format output' do 
     sign_in @user
     get :show, format: :json, params: {project_id: @project.id, id: @task.id}
     expect(response.content_type).to eq "application/json"
   end
 end

 describe '#create' do
   it 'responds with json formatted output' do
     new_task = { name: "new test task" }
     sign_in @user
     post :create, params: { project_id: @project.id, task: new_task }
     expect(response.content_type).to eq "application/json"
   end

   it 'adds a new task to the project' do
     new_task = { name: "new test task" }
     sign_in @user
     expect{
       post :create, params: { project_id: @project.id, task: new_task }
     }.to change(@project.tasks, :count).by(1)
   end

   it 'requires authentication' do
     new_task = { name: "new test task" }
     expect{
       post :create, params: {project_id: @project.id, task: new_task}
     }.to_not change(@project.tasks, :count)
     expect(response).to_not be_success
   end
 end
end
```

<br>

## feature spec　現在は、systems specを使っている

`system spec`とは、受入テストや統合テストと呼ばれるもの。いわはviewのテスト

`capybara`のインストール。テスト環境にだけ追加することで、開発環境のメモリ消費を少し軽くすることが出来る

```
# Gemfile

group :test do
 gem 'capybara', '~> 2.15.2'
end
```

`rails_helper`にCapybaraのライブラリを追加する

```
# spec/rails_helper

require 'capybara/rspec'

RSpec.configure do |config|
config.before(:each, type: :system) do  
  driven_by :selenium_chrome_headless
end
```

`bin/rails g rspec:feaure projects`

`capybaraのDSL`

`within`

```
# html

<div id="node">
 <a href="http://node.js.org">click here!</a>
</div>
<div id="rails">
 <a href="http://rubyonrails.org">click here!</a>
</div>
```
のようはHTMLがあった場合、rubyonrailsのリンクをリクックしたいときは

```
within #rails do
 click_link "click here!"
end
```
のようにcapybaraのDSLであるwithinを使うとあいまいだと怒られることから回避できる

<br>

JavaScriptのテスト(featureでのテストなので注意！)

タスクの隣にあるチェックボックスをクリックするとそのタスクが完了状態になるというJavaScriptでの機能がある場合

```
# spec/features/tasks_spec.rb

require 'rails_helper'

RSpec.feature "Taskssss", type: :feature do
 scenario 'user toggles a task', js: true do
   user = FactoryBot.create(:user)
   project = FactoryBot.create(:project, owner: user, name: "RSpec tutorial")
   task = project.tasks.create!(name: "finish rspec tutorial")

   visit root_path
   click_link "Sign in"
   fill_in "Email", with: user.email
   fill_in "Password", with: user.password
   clikc_button "Log in"

   click_link "rspec tutorial"
   check "finish rspec tutorial"

   expect(page).to have_css "label#task_#{task.id}.completed"
   expect(task.reload).to be_completed

   uncheck "finish rspec tutorial"

   expect(page).to_not have_css "label#task_#{task.id}.completed"
   expect(task.reload).to_not be_completed
 end
end
```

`js: true`オプションを渡すことで、指定したテストに対してJavaScriptが使えるドライバを使うようにCapybaraに伝えている

表示されるまで時間がかかる場合

```
scenario "run a really slow process" do
 using_wait_time(15) do
   # テストを実行する
 end
end
```

上記にすることで、15秒経ってからテストを開始することができる

<br>

## リクエストスペック API

リクエストスペックでは、capybaraも使用しないため`spec/requests`フォルダ内にスペックを書いていく


`app/controllers/api/projects_controller.rb`で動きを確認するように

まず、サンプルデータを作成する。ここでは、１人のユーザーと２件のプロジェクトを作成。一方のプロジェクトは先ほどのユーザーがオーナーで、もう１つのプロジェクトは別のユーザーがオーナーになってる

次にHTTP GETを使ったリクエストを実行する。コントローラースペックと同様、ルーティング名に続いて`params(パラメータ)`を渡す

このAPIでは、ユーザーのメールアドレスとサインインするためのトークンが必要になる。パラメーターにはこの２つを含めている

が、コントローラースペックとは異なり、今回は好きなルーティング名を何でも使うことができる。なぜならリクエストスペックはコントローラーに結びつくことはないから。よって、テストしたいルーティング名をちゃんと指定しているか確認する必要があるよ

テストは返ってきたデータを分解し、取得結果を検証する。データベースには２件のプロジェクトが格納されているが、このユーザーがオーナーになっているプロジェクトは１件だけ。

そのプロジェクトのIDを取得し、２番目のAPIコールでそれを利用する。このAPIは、１件のプロジェクトに対して、より多くの情報を返すエンドポイントだよ。このAPIは、コールするたびに再認証が必要になる点に注意。なので、メアドとトークは毎回パラメーターに渡す必要がある。

最後に、このAPIコールで返ってきたJSONデータをチェックし、そのプロジェクト名とテストデータのプロジェクト名が一致するか検証する

伊藤さんは、`spec/requrests/projects_api_spec.rb`と単数形にリネームしているみたい

```
#spec/requrests/projects_api_spec.rb

require 'rails_helper'

describe 'Project API', type: :request do
 # 1件のプロジェクトを読みだすこと
 it 'loads a project' do
   user = FactoryBot.create(:user)
   FactoryBot.create(:project, name: "sample project")
   FactoryBot.create(:project, name: "second sample project", owner: user)

   get api_projects_path, params: {user_email: user.email, user_token: user.authentication_token}

   expect(response).to have_http_status(:success)
   json = JSON.parse(response.body)
   expect(json.lenght).to eq 1
   project_id = json[0]["id"]

   get api_project_path(project.id), params: {user_email: user.email, user_token: user.authentication_token}

   expect(response).to have_http_status(:success)
   json = JSON.parse(response.body)
   expect(json["name"]).to eq "second sample project"
 end
end
```

<br>

POSTリクエストのテスト。APIにデータを送信

```
# spec/requests/projects_api_spec.rb

require 'rails_helper'

it 'creates a project' do
 user = FactoryBot.create(:user)
 project_params = FactoryBot.attributes_for(:project)

 expect{
   post api_projects_path, params: {
     user_email: user.email,
     user_token: user.authentication_token,
     project: project_params
   }
 }.to change(user.projects, :count).by(1)

 expect(response).to have_http_status(:success)
end
```

<br>

コントローラースペックはリクエストスペックで書き換えることが容易にできる

たとえば、homeコントローラーをリクエストスペックで書き換えた場合

```
# spec/requsts/home_spec.rb

RSpec.describe 'Home page', type: :requrest do
 it 'responds successfully' do
   get root_path
   expect(response).to be_success
   expect(response).to have_http_status "200"
 end
end
```

のようになる。コントローラーテストと違う点は、`get root_path`ここ。アクションを指定するのではなく、パスを指定していること。あとはコントローラーテストと記述は同じ

API用のコントローラーとは異なり、この仕組みがちゃんと機能するように、Deviseのsign_inヘルパーをリクエストスペックに追加する。

まずは、`spec/support/request_spec_helper.rb`という新しファイルを作成する

```
# spec/support/request_spec_helper.rb

module RequestSpecHelper
 include Warden::Test::Helpers

 def self.include(base)
   base.before(:each) {Warden.test_mode!}
   base.before(:each) {Warden.test_reset!}
 end

 def sign_in(resource)
   login_as(resource, scope: :warden_scope(resource))
 end

 def sign_out(resource)
   logout(warden_scope(resource))
 end

 private
   def warden_scope(resource)
     resource.class.name.underscore.to_sym
   end

end
```

次に、`spec/rails_helper.rb`を開き、上で作成したヘルパーメソッドをリクエストスペックで使えるようにする

```
# spec/rails_helper.rb

RSpec.configure do |config|
 config.include Devise::Test::ControllerHelpers, type: :controller
 config.include RequestSpecHelper, type: :request
end
```

この設定をすることで、リクエストスペックでコントローラースペックが書けるよ

伊藤さんは、コントローラーよりリクエストで書いた方がいいと仰っています

テストスイートを自分のAPIのクライアントだと考えるようにとも仰っている

<br>

DRYにしてみよう。リファクタリング

ユーザーがアプリにログインする際のfeature specに以下の記述があるが、今後、UIの変更が起きた際に、いろんな箇所を変更する必要が出てくるため、ここでサポートモジュールにしちゃおう！

```
visit root_path
click_link "Sign in"
fill_in "Email", with: user.email
fill_in "Password", with: user.password
click_button "Log in"
```

`spec/support`ディレクトリに`login_support.rb`という名前のファイルを追加し、モジュールとして切り出す

```
# spec/support/login_support.rb

module LoginSupport
 def sing_in_as(user)
   visit root_path
   click_link "Sign in"
   fill_in "Email", with: user.email
   fill_in "Password", with: user.password
   click_button "Log in"
 end
end

RSpec.configure do |config|
 config.include LoginSupport
end
```

モジュールの定義のあとにRSpecの設定が続き、作ったモジュールをincludeしている。これは必ずしも必要ではない。テストごとに明示的にサポートモジュールをincludeする方法もある(以下のように)

```
# spec/features/projects_spec.rb

require 'rails_helper'

RSpec.feature 'Projects', type: :feature do
 include LoginSuppoert

 scenario///
end
```

LoginSupportを使ってリファクタ

```
require 'rails_helper'

RSpec.feature 'Project', type: :feature do
 scenario 'user creates a new project' do
   user = FactroyBot.create(:user)
   sign_in_as user

   expect{
     ...
   }
 end
end
```

と書けるよ！

```
#spec/rails_helper.rb

RSpec.configure do |config|
 # Deviseのヘルパーメソッドをテスト内で使用する
 config.include Devise::Test::ControllerHElpers, type: :controller
 config.include RequestSpecHelper, type: :request
 config.include Devise::Test::IntegrationHelper, type: :feature
end
```
この記述(`config.include Devise::Test::IntegrationHelper, type: :feature`)により、今回独自で作った`sign_in_as`メソッドを呼び出す部分は、Deviseの`sing_in`ヘルパーで置き換えることができるようになる

なので、結局

```
RSpec.feature 'Project', type: :feature do
 scenario 'user creates a new project' do
   user = FactoryBot.create(:user)
   sign_in user  # って書けるみたい
 end
end
```

<br>

letで遅延読込をする

`let`は、呼ばれたときに初めてデータを読み込む、遅延読込を実現するメソッド。beforeブロックの外部で呼ばれるため、セットアップに必要なテストの構造を減らすこともできる

```
# spec/models/note_spec.rb

require 'rails_helper'

RSpec.desctibe Note, type: :model do
 let(:user) { FactoryBot.create(:user) }
 let(:project) { FactoryBot.create(:project, owner: user) }

 it 'is valid with a user, project, and message' do
   note = Note.new(
     message: "this is a sample note"
     user: user,
     project: project,
   )
   expect(note).to be_valid
 end

 it 'is invalid without a message' do
   note = Note.new(message: nil)
   note.valid?
   expect(note.errors[:message]).to include("can't be blank")
 end

 describe 'search message fot a term' do
   let(:note1) {
     FactoryBot.create(
       :note,
       project: project,
       user: user,
       message: "this is the first note"
     )
   }

   let(:note2) {
     FactoryBot.create(:note, project: project, user: user, message: "this is the second note")
   }

   let(:note3) { FactoryBot.create(:note, project: project, user: user, message: "first, preheat the oven") }

   context 'when a match is found' do
     it 'returns notes that match the search term' do
       expect(Note.search('first')).to include(note1, note3)
     end
   end

   context "when no match is found" do
     it 'returns an empty collection' do
       expect(Note.search("message")).to be_empty
     end
   end
 end
end
```

<br>

shared_context (contextの共有)

`let`を使うと、複数のテストで必要な共通のテストデータを簡単にセットアップすることができる

`shared_context`を使うと、複数のテストファイルで必要なセットアップをを行うことが出来る

例えばtasks_controller_spec.rbのlet群を`spec/support/contexts/project_setup.rb`に移動させる

```
# spec/support/contexts/project_setup.rb

RSpec.shared_context "project setup" do 
 let(:user) { FactoryBot.create(:user) }
 let(:project) { FactoryBot.create(:project, owner: user) }
 let(:task) { project.tasks.create!(name: "Test task")}
end  
```

これを、`include_context "<shared_context名>"`と記述し、includeする

```
# spec/controllers/tasks_controller_spec.rb

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
 include_context "project setup"
 ...
end
```

<br>

カスタムマッチャ p.137

`spec/support/matchers/content_type.rb`というファイルを作成し、タスクコントローラーのテストでコントローラーのレスポンスが`application/json`の`Content_type`で返すマッチャを自作する

マッチャは必ず名前付きで定義され、その名前をスペック内で呼び出す時に使う。今回は`have_content_type`という名前にする。

マッチャには、`matchメソッド`が必要で、典型的なマッチャには２つの値を利用する

1つ目は、期待される値(expected value マッチャをパスさせるのに必要な結果)

2つ目は、実際の値(actual value テストを実行するステップで渡される値)

以下の記述は、短く省略した`Content_Type(:thml or :json)`で`content_types`ハッシュ内の`Content_Type値`を取り出し、それが実際の`Content_Type`と一致することを期待している

```
# spec/support/matchers/content_type.rb

RSpec::Matchers.define :have_content_type do |expected|
 match do |actual|
   content_types = {
     html: "text/html",
     json: "application/json",
   }

   actual.content_type == content_types[expected.to_sym]
 end
end
```

<br>

aggregate_failures(失敗の集約) p.144

`aggregate_failures`を使うことで、失敗するエクスペクテーションがあったとしても続けてテストすることができる

```
# spec/controllers/projects_controller_spec.rb

it 'responds successfully' do
 # sign_in @user
 get :index
 aggregate_failures do
   expect(response).to be_success
   expect(response).to have_http_status "200"
 end
end
```

とすることで、例えエクスペクテーションが失敗しても先のエクスペクテーションの情報まで取得することができる

`aggregate_failures`は、失敗するエクスペクテーションにだけ有効に働くのであって、テストを実行するために必要な一般的な実行条件には働かない

<br>

テストの可読性を改善する p.148

各ステップを独立したヘルパーメソッドに抽出する

```
# spec/features/tasks_spec.rb

require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
 let(:user) {FactoryBot.create(:user)}
 let(:project) {FactoryBot.create(:project, name: "RSpec tutorial", owner: user)}
 let!(:task) {project.tasks.create!(name: "Finish RSpec tutorial")}

 scenario 'user toggles a task' do
   sign_in user
   go_to_project "RSpec tutorial"

   complete_task "Finish RSpec tutorial"
   expect_complete_task "Finish RSpec tutorial"

   undo_complete_task "Finish RSpec tutorial"
   expect_incomplete_task "Finish RSpec tutorial"
 end

 def go_to_project(name)
   visit root_path
   click_link name
 end

 def complete_task(name)
   check name
 end

 def undo_complete_task(name)
   uncheck name
 end

 def expect_complete_task(name)
   aggregate_failures do
     expect(page).to have_css "label.completed", text: name
     expect(task.reload).to be_completed
   end
 end

 def expect_incomplete_task(name)
   aggregate_failures do
     expect(page).to_not have_css "label.completed", text: name
     expect(task.reload).to_not be_completed
   end
 end
end
```

<br>

速くテストを書き、速いテストを書く p.153

速いとは、スペックの実行時間・意味が分かりやすくて綺麗なスペックを開発者としていかに素早く書くか

`specify`とは、`it`のエイリアス

`is_expected`を使うとこのように書き換えることができる

```
it 'returns a user's full name as a string ' do
 user = FactoryBot.create(:user)
 expect(user.name).to eq "Aaron Sumner"
end
```

が、`is_expected`を使うとこのように書き換えることができる

```
subject(:user) { FactoryBot.build(:user) }
it {is_expected.to satisfy { |user| user.name == "Aaron Sumner"}}
```

`subject`はあとに続くテストで暗黙的に再利用できるため、書くexampleで何度も書く必要がなくなる

`Shoulda Matchers gem`とは、バリデーションテストのマッチャを提供するgem

```
group :test do  
 gem 'shoulda-matchers'
end
```

```
# spec/rails_helper.rb

Shoulda::Matchers.configure do |config|
 config.integrate do |with|
 with.test_framework :rspec
 with.library :rails
 end
end
```

以上の準備により、下記などのマッチャが使え、このように書き換えができる

```
# spec/models/user_spec.rb

it { is_expected.to validate_presence_of :first_name  }
it { is_expected.to validate_presence_of :last_name }
it { is_expected.to validate_presence_of :email }
it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
```

`case_insensitive`とは、大文字小文字の区別をしないこと

ユーザーが異なれば、同じ名前のプロジェクトがあっても問題ないというテスト

`it { is_expected.to validate_uniqueness_of(:name).scope_to(:user_id) }`

<br>

モックとスタブ p.158

`モック(mock)`とは、本物のオブジェクトのふりをするオブジェクトで、テストのために使われる。モックは`テストダブル(test double)`と呼ばれる場合もある(doubleとは、代役や影武者などの意味があるため)。モックはデータベースにアクセスしない点が異なる。よってテストにかかる時間は短くなる

`スタブ(stub)`とは、オブジェクトのメソッドをオーバーライドし、事前に決められた値を返す。つまりスタブは、呼び出されるとテスト用に本物の結果を返すダミーメソッド。スタブをよく使うのは、メソッドのデフォルト機能をオーバーライドするケース。特にデータベースやネットワークを使う処理が対象になる

<br>

メール送信をテストする p.178

'$ bin/rails g rspec:mailer user_mailer'

```
# spec/mailers/user_mailer_spec.rb

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
 describe 'welcome_email' do
   let(:user) {FactoryBot.create(:user)}
   let(:mail) {UserMailer.welcome_email(user)}

   it 'sends a welcome email to the user's email address' do
     expect(mail.to).to eq [user.email]
   end

   it 'sends from the support email address' do
     expect(mail.from).to eq ["support@example.com"]
   end

   it 'sends with the correct subject' do
     expect(mail.subjeect).to eq "Welcome to Projects!"
   end

   it 'greets the user by first name' do
     expect(mail.body).to match(/Hello #{user.first_name},/)
   end

   it 'reminds the user of the registered email address' do 
     expect(mail.body).to match user.email
   end
 end
end
```

mail.toやmail.fromの値が文字列の配列になっており、単体の文字列でない点に注意。配列の等値性をチェックすることで、余計な受信者や送信者が含まれず、確実に検証できる

<br>

フィーチャーを定義する p.190

1. プロジェクトを持ったユーザーが必要で、そのユーザーはログインしていないといけない
2. ユーザーはプロジェクト画面を開き、完了ボタンをクリックする
3. プロジェクトは完了済みとしてマークされる

```
# spec/features/projects_spec.rb

scenario 'user completes a project', focuse: true do
 user = FactoryBot.create(:user)
 project = FactoryBot.create(:project, owner: user)
 sign_in user

 visit project_path(project)
 click_button "Complete"

 expect(project.reload.completed?).to be true
 expect(page).to have_content "Congratulations, the project is complete!"
 expect(page).to have_content "Completed"
 expect(page).to_not have_button "Complete"
end
```

`focus: true`のタグを付けることで、このスペックだけ実行することができる

<br>

System specへの以降 p.217

```
group :development, :test do
 gem 'rspec-rails', '~> 3.8.0'
end
```

セットアップしたselenium-webdriverとヘッドレスchromeを使うように設定

```
spec/support/capybara.rb

RSpec.configure do |config|
 config.before(:each, type: :system) do
   driven_by :rack_test
 end

 config.before(:each, type: :sysem, js: true) do
   driven_by :selenium_chrome_headless
 end
end
```

```
# spec/rails_helper.rb

config.include Devise::Test::ControllerHelper, type: :controller
config.include RequestSpecHelper, type: :request
config.include Devise::Test::IntegrationHelpers, type: :system
```

以上の記述をすることで、spec/systemディレクトリにテストを追加すれば、テストが通過する

`take_screenshot`メソッドを使ってテストのあらゆる場所でシミュレート中のブラウザの画像を作成することができる

画像はデフォルトで、tmp/screenshotsに保存される