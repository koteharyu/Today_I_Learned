## RSpec

`テスト`とは、一般的に自動テストの意

数年にわたり継続的に開発・運用していくなら利用している`RubyやRails、各種gemのバージョンを最新版に上げていくことが重要`。

バージョンを上げないことによるデメリットは数多くある。

`リファクタリング`とは、アプリの挙動は変えず、内部のコードを綺麗に整理すること

テストは、動作確認だけでなく、期待している動作の詳細を開発チーム内で共有する手段にもなる。例えばユーザーの入力値として何を正しいと想定しているか、エラー時には、どんなことが起こるのかなどを把握しやすくなる。

テストを書くことで、要件を詰める切っ掛けにもなる

テストを書きやすいプロダクトコードを作ることを意識することで、おのずと管理しやすい粒度で構成されたコードを作ることができる。

## RSpec

`RSpec`とは、RubyにおけるBDD(振舞駆動開発)のためのテスティングフレームワーク。動く仕様書(SPec)として自動テストを書くという発想で作られ、要求仕様をドキュメントに記述するような感覚でテストケースを記述することが大切。`テストを書くというよりSpecを書くという気持ちが大切`

RSpecを利用するメリット

1. テストが動く仕様書としても機能するということを分かりやすく示せる
2. RSpecは開発現場で広く利用されている

<br>

## Capybara

`Capybara`とは、Webアプリケーションの`E2E(end to end)`テスト用のフレームワーク。Webアプリのブラウザ操作をシミュレーションできたり、実際のブラウザと組み合わせて、JavaScriptの動作まで含めたテストを行うことができる。人が手作業で確認していたようなブラウザ操作を`CapybaraのDSL`を使い、直感的に記述することができる。また、実際のブラウザやHeadlessブラウザを操作することも可能

`DSL`とは、ドメイン固有言語で、特定の問題に特化したコンピューター言語。Capybaraはテスティングフレームワークを操作する命令を、それぞれのフレームワークに依存しない形で提供する。つまり、テスティングフレームワークである、Cucumber,RSpec,Test::Unitなどを透過的に利用できる

[CapybaraDSL](https://blog.takuros.net/entry/20140322/1395464375)

`headlessブラウザ`とは、GUIのないブラウザ。GUIのある通常のブラウザと比べて動作が高速であることが利点で、自動テストによく利用される

`FactroyBot`とは、テスト用のデータ作成をサポートするgem。DSLを使って似たデータを効率よく提供定義することが出来、ActiveRecordモデルに実装したコールバックなどの資産を直接的に活用してデータの状態やデータの関係性などを制御しやすくなる。「モデルオブジェクトの作り方」を宣言的に記述する

`Fixture`とは、YAML形式でテーブルレコードに対応するデータ内容を定義し、データベースに直接的に反映させる仕組み。シンプルでデータベースの構造に忠実な反面、登録に関する複雑な制御が苦手なため、似て非なるデータを大量に定義する必要が生じやすかったり、データ間の関係性を適切に作りこむのが大変になりやすい面がある

<br>

記述するテストの種類

|分類|テストの種類|RSpecでの呼び方|
|-|-|-|
|全体的なテスト|システムテスト(System Test) E2Eテストに相当し、ブラウザを通してアプリの挙動を外部的に確認できる|System Spec, Feature Spec|
|全体的なテスト|統合テスト(Integration Test) いろいろな機能の連続が想定通りに動くかを確認するテストで、システムテストよりも内部的な確認ができる|Request Spec|
|全体的なテスト|機能テスト(Function Test) コントローラー単位のテスト|Controller Spec *注|
|個々の部品のテスト|モデル|MOdel Spec|
|個々の部品のテスト|ルーティング|Routing Spec|
|個々の部品のテスト|ビュー|View Spec|
|個々の部品のテスト|ヘルパー|Helper Spec|
|個々の部品のテスト|メーラー|Mailer Spec|
|個々の部品のテスト|ジョブ|Job Spec|

注・・・現在では推奨されておらず、代わりに統合テスト相当の`Request Spec`を使うことを推奨されている

一番重要だと考えられるのが、テストの粒度として一番外側に位置しているシステムテスト

<br>

モデルのテストでは、検証やデータの制御、複雑なロジックの挙動などを個別のテストケースとして記述する。小さい粒殿テストが書けるため、システムテストでは行いにくい、さまざまな条件下でのわずかな挙動の違いを確認するのに向いている。また、モデルのテストは、プロダクトコードよりもテストを先に書く`TDD`にも適している

統合テストは、モデルのテストとシステムテストの間を埋めるテスト。UIから確認する程ではなく、モデルや単体テストでは確認しにくいものをテストする。APIのテストに利用されることが多い

ルーティング・メーラー・ジョブは、モデルほど頻度は高くないが、複雑なルーティングや、ほかのテストでは置き換えずらいメーラーやジョブのテストは利用頻度は高い

<br>

## System Spec とは

`Feature Spec`に変わって`System Spec`を使う主なメリットは以下の通り

1. テスト終了時にDBが自動でロールバックされ、database_cleanerやdatabase_rewinderなどのgemが不要になる
2. テスト失敗時にスクリーンショットを撮影し、ターミナルに表示してくれる(Feature Specでは、capybara-screenshoyというgemを利用してスクリーンショットの撮影ができたが、このgemを入れる必要がなくなった)
3. driven_byを使って、specごとにブラウザを簡単に切り替えられるようになる

<br>

## System Specを書くための準備

System Specを書くために、RSpec, Capybara, FactoryBotをインストールし、初期設定

1. gem 'rspec-rails', '~> 3.7' を追加
2. $ bundle
3. `$ bin/rails g rspec:install` コマンドを実行し、Rspecに必要なディレクトリや設定ファイルを作成
4. `$ rm -r ./test` で、Minitest用のディレクトリを削除

`spec/spec_helper.rb`は、RSpecの全体的な設定を書くためのファイル

`spec/rails_helper.rb`は、Rails特有の設定を書くためのファイル

<br>

## Capybaraの初期設定

capybara本体は、rails new時のbundle installによってすでにインストールされているため、`spec/spec_helper.rb`を編集する必要がある

```
# spec/spec_helper.rb

requrie 'capybara/spec'      # 1

RSpec.configure do |config|
 config.before(:each, type: :system) do    # 2
   driven_by :selenium_chrome_headless
 end
```

1. RSpecでCapybaraを扱うために必要な機能を読み込むために追加する
2. System Specを実行するドライバの設定をする。ドライバとは、Capybaraを使ったテスト/Specにおいて、ブラウザ相当の機能を利用するために必要なプログラムのこと。今回System Specでは、処理が高速なことから、常にブラウザに`Headless Chrome`を使う。

<br>

## FactoryBotのインストール

1. gem 'factory_bot_rails', '~> 4.11' を追加
2. $ bundle

<br>

Specの書式

```
describe '仕様を記述する対象(テスト対象)', type: :specの種類 do

 context 'ある状況・状態' do
   before do
     [事前準備]
   end

   it '仕様の内容(期待の概要)' do
     [期待する動作]
   end
 end

end
```

`type指定`は外側の`describe`にだけ行う

<br>

System Specのコード例

```
describe '~機能', type: :system do

 describe '登録 ' do

   context '○○の場合' do
     before do
       # (context内を確認するのに必要な)事前準備
     end

     it '△△する' do
       # 期待する動作
     end
   end

   context '××の場合' do
     before do
       # (context内を確認するのに必要な)事前準備
     end

     it '○○する' do 
       # 期待する動作
     end
   end
 end

 describe '削除' do
   # 略
 end
end
```

`describe, context`とは、テストケースを整理・分類する

`before, it`は、テストコードを実行する

`describe`には、「何について仕様を記述しようとしているのか」(テストの対象)を記述する。System Specでは、一連の操作によって達成したい機能や処理の名前を記述することになる。Model Specでは、モデルクラス名や、メソッド名などを記述していく場所になる。describeのブロック(do~end)の中に、仕様の内容として、テストの本体を記述する。通常、一番外側のdescribeには、そのSpecファイル全体の主題を記述する。内部にdescribeをネストすることもよくあり、階層の深いdescribeには、より細かいテーマを記述する。

`context`は、テストの内容を「状況・状態」のバリエーションごとに分類する。テストでは、さまざまな条件で正しく動くかを試す必要があるが、これを仕様書のように正しく整理することができる。System Specでは、ユーザーの入力内容が正しいか、正しくないか、ユーザーがログインしているか、ユーザーが管理者か一般ユーザーか、などの各種の条件をcontextに記述し、続くブロック内に、そのような条件下で想定する動作を記述する。記述的には、contextはdescribeのエイリアスなので、どちらを使ってもいい

`before`を記述することで、対応するdescribeやcontextの領域内のテストコードを実行する前に、beforeのブロック内に書かれたコードを実行する。つまり、前提条件をbefore内に記述する。itが実行されるたびに、新たに実行される。そのため、あるテストケースのせいで、別のテストケースが影響を受けることがない

`it`は、期待する動作を文章と、ブロック内のコードで記述する。itの中に書いた期待する動作通りに対象が動作すれば、Specが１件成功したことになる。想定通りに動作しなかったら、Specが予期せぬ例外が出ればエラー(Error)、そうではないが想定とも違う場合には失敗(Failure)として結果がカウントされる

`Feature Spec`と`System Spen`では、describの代わりに`feature`,　itの代わりに`scenario`と記述することができる

<br>

## FactoryBotにてテストデータを作成する

Railsでは、用途ごとに利用するデータベースを、そのほかの目的で使うデータベースとは切り離しており、デフォルトで作成される開発環境(development)、テスト環境(test)、本番環境(production)のうち、test環境のデータベースをテスト専用で使うことになる

System SpecでFactoryBotを利用して前提となるテストデータを投入する場合には、次のようなステップで行う

1. FactoryBotでデータを作成するための「テンプレート」を用意する
2. System Specの適切なbeforeなどで、factoryBotのテンプレートを利用してテスト用データベースにテストデータを投入する

<br>

パターン１　クラスを名前から自動類推

```
# spec/factories/users.rb

FactoryBot.define do
 factory :user do
   name { "test user" }
   email { "test@example.com" }
   password { "password" }
 end
end

# spec/factories/tasks.rb

FactoryBot.define do 
 factory :task do
   name { "write a test" }
   description { "RSpec & Capybara & FactoryBot" }
   user # 1
 end
end
```

1 には、userとだけ書かれている。これは「先ほど定義した:userという名前のFactoryを、Taskモデルに定義されたuserという名前の関連を生成するのに利用する」という意味。

<br>

パターン2　`:classオプション`を付けて、別の名前で生成する

```
# spec/factories/users.rb

FactoryBot.define do
 factory :admin_user, class: User do
   name { "test user" }
   email { "test@example.com" }
   password { "password" }
 end
end

# spec/factories/tasks.rb

FactoryBot.define do 
 factory :task do
   name { "write a test" }
   description { "RSpec & Capybara & FactoryBot" }
   association :user, factory: :admin_user
 end
end
```
実際にTaskモデルに紐づいているuserを`association`を使って関連付けている

<br>

「一覧画面に遷移したら作成済みのタスクが表示されている」というSpec

```
# spec/system/tasks_spec.rb

require "rails_helper"

describe 'タスク管理機能', type: :system do
 describe '一覧表示機能' do
   before do 
     user_a = FactoryBot.create(:user, name: "ユーザーA", email: "a@example.com")
     FactoryBot.create(:task, name: "最初のタスク", user: user_a)
   end

   context "ユーザーAがログインしている時" do
     before do
       visit login_path
       fill_in "メールアドレス", with: "a@example.com"
       fill_in "パスワード", with: "password"
       click_button "ログインする"
     end

     it "ユーザーAが作成したタスクが表示される" do
       expect(page).to have_content "最初のタスク"
     end
   end

 end
end
```

```
$ bundle exec rspec spec/system/tasks_spec.rb
```

<br>

`FactoryBot.create`メソッドで`spec/factories/users.rb`で用意した`:user`ファクトリを指定し、Userオブジェクトの作成・登録を行う

`create`の代わりに`build`を使えば、データベースに登録する前で止めて、未保存のオブジェクトを得ることが出来る

`:taskファクトリ`を使って、user関連を指定したデータを作る

user_aのときと違い、作成したタスクオブジェクトをローカル変数に代入しないのは、テストの後方で託すオブジェクトを再利用するつもりがないため。ローカル変数に代入しなくても、この処理を実行すると、データベースにtasksレコードが１行追加される。その際、tasksレコードのuser_idには、user_a.idが格納される

もしも、userオプションを指定しなければ、FactoryBotは、Taskオブジェクトを作る際に、新しいUserオブジェクトを合わせて作成・登録する

`visit URL`で特定のURLでアクセスする操作ができる

メールアドレスは、画面上で「メールアドレス」というラベル(<label>要素)が付いたテキストフィールド(<input>要素)にメールアドレスを入れる操作になる。テキストフィールドに値を入れるには、`fill_inメソッド`を使い、`with: 入力値`の形で記述する

`click_buttonメソッド`は、引数に指定したボタンをクリックさせるメソッド

`have_content`の部分は、`Matcher（マッチャ－）`と呼ばれている

<br>


## 他のユーザーが作成したタスクが表示されないことの確認

1. ユーザーAと、ユーザーAのタスクを作成
2. ユーザーBを作成
3. ユーザーBでログイン
4. ユーザーAのタスクが表示されていないことを確認

```
# spec/system/tasks_spec.rb

require "rails_helper"

describe 'タスク管理機能', type: :system do
 describe '一覧表示機能' do
   before do 
     user_a = FactoryBot.create(:user, name: "ユーザーA", email: "a@example.com")
     FactoryBot.create(:task, name: "最初のタスク", user: user_a)
   end

   context "ユーザーAがログインしている時" do
     before do
       visit login_path
       fill_in "メールアドレス", with: "a@example.com"
       fill_in "パスワード", with: "password"
       click_button "ログインする"
     end

     it "ユーザーAが作成したタスクが表示される" do
       expect(page).to have_content "最初のタスク"
     end
   end

   context 'ユーザーBがログインしているとき' do
     before do
       FactoryBot.create(:user, name: "ユーザーB", email: "b@exampel.com")
       visit login_path
       fill_in "メールアドレス", with: "b@example.com"
       fill_in "パスワード", with: "password"
       clicK_button "ログインする"
     end

     it 'ユーザーAが作成したタスクが表示されない' do
       expect(page).to have_no_content "最初のタスク"
     end
   end

 end
end
```

「現時点の課題」・・・ユーザーAとユーザーBのログイン時に似たようなコードが書かれているので、すっきりさせたい

contextの外側のbeforeは、それぞれのcontext内容が呼び出される前に実行される。

マッチャである`have_no_content`は、`not_to have_content`とも書ける

<br>

## beforeを利用した共通化 / letを利用した共通化

`let`とは、「before処理でテストケーススコープの変数に値を代入する」のに近いイメージで利用できる機能

`let(定数名) {定義の内容}`

`遅延評価`とは、letでの定義が初めて呼び出されたときに評価されること。そのため、１度も呼ばれないletのブロックは実行されることがないので注意

`let!`は、呼ばれるかどうかに関わらず、定義した位置に応じて確実に実行してほしい場合に使用する。呼び出されるケースと呼び出されないケースがあるが、確実にデータは作りたい場合に使う

```
# spec/system/tasks_spec.rb

describe '', type: :system do
 describe '' do
   let(:user_a) {FactroyBot.create(:user, name: "ユーザーA", email: "a@example.com")} # 1
   let(:user_b) {FactoryBot.create(:user, name: "ユーザーB", email: "b@example.com")}

   before do
     FactoryBot.create(:task, name: "最初のタスク", user: user_a) # 2
     visit login_path
     fill_in "メールアドレス", with: login_user.email  # 3
     fill_in "パスワード", with: login_user.password  
     click_button "ログインする"
   end

   context 'ユーザーAがログインしているとき' do
     let(:login_user) {user_a}   # 4

     it '' do
       expect(page).to have_content "最初のタスク"
     end
   end

   context 'ユーザーBがログインしているとき' do
     let(:login_user) {user_b}  # 5

     it '' do
       expect(page).not_to have_content "最初のタスク"
     end
   end
 end
end
```

1とその行では、下準備として、ユーザーA(user_a)とユーザーB(user_b)を`let`でわかりやすく定義。2の部分では、ユーザーAのタスクを作ることで、1で定義したuser_aを利用している。これがuser_aの初利用となるため、この時点でユーザーＡが実際にデータベースに登録される

3から続く行が、共通化したいログイン処理。ログインに利用するメールアドレスや生のパスワードの情報を、内側のcontext内で定義されているlogin_userから取得することで、誰がログインするのかに関わらず同じログイン処理コードを使えるようにしている。ユーザーAでログインするケースでは、すでにuser_aオブジェクトが生成されているので、それがlogin_userとして利用される。ユーザーBでログインするケースでは、初めてuser_bというletが使われ、まずデータベースにユーザーBのデータが登録され、user_bにユーザーBのオブジェクトが入り、それがlogin_userとして利用される。

ユーザーAでログインするケースの時には、user_bは利用されないので、データベースに登録されることはない

4、5では、3で使うlogin_userをletで定義している

<br>

## タスクの詳細確認までのコード

```
require 'rails_helper'

describe 'タスク管理機能', type: :system do
  describe '一覧表示機能' do
    let(:user_a) { FactoryBot.create(:user, name: "ユーザーA", email: "a@example.com") }
    let(:user_b) { FactoryBot.create(:user, name: "ユーザーB", email: "b@xxample.com") }
    let!(:task_a) { FactoryBot.create(:task, name: "最初のタスク", user: user_a) }

    before do
      visit login_path
      fill_in "メールアドレス", with: login_user.email
      fill_in "パスワード", with: login_user.password
      click_button "ログインする"
    end

    context "ユーザーAでログインしている時" do
      let(:login_user) {user_a}

      it 'ユーザーAが作成したタスクが表示されること' do   # 1
        expect(page).to have_content "最初のタスク"
      end
    end

    context "ユーザーBでログインしている時" do
      let(:login_user) {user_b}

      it "ユーザーAが作成したタスクが表示されないこと" do
        expect(page).not_to have_content "最初のタスク"
      end
    end

    describe '詳細表示機能' do
      context 'ユーザーAでログインしている時' do
        let(:login_user) {user_a}

        before do
          visit task_path(task_a)
        end

        it 'ユーザーAが作成したタスク詳細が表示される' do  # 2
          expect(page).to have_content "最初のタスク"
        end
      end
    end

  end
end
```

<br>

## shared_examples

上記のコードでは、　１と2が重複しているため、よりDRYなコードにしていく

`shared_examples`という仕組みがある。`example`とは、itなどの期待する挙動を示す部分のこと。このexampleをいくつかまとめて名前をつけ、テストケース間でシェアできる仕組み

```
shared_examples_for "ユーザーAが作成したタスクが表示される" do
  it { expect(page).to have_content "最初のタスク" }
end
```

```
it_behaves_like 'ユーザーAが作成したタスクが表示される'
```

<br>

`shared_context`とは、`before`,`let`,`let!`などの前処理に名前をつけて参照する機能。このメソッド内に共通処理を定義しておき、`include_context`メソッドでその共通処理を呼び出す。名前の付け方に気をつけよ！