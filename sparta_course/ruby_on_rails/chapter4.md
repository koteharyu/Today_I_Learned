## chapter4

## マイグレーション

マイグレーションにおいては、１つのマイグレーション（ファイル）が１つのバージョンとして扱われる。１つのマイグレーションファイルを適用することで、データベーススキーマのバージョンを１つあげることができ、適用ずみのマイグレーションを１つ取り消すことでバージョンを１つ下げることができる

マイグレーションファイルを作成しただけじゃ、データベースは変更されない。マイグレーションを適用する必要がある。逆に、マイグレーションファイルを削除するだけでは、データベースは変更されない。マイグレーションを取り消すコマンドを実行する必要がある。

マイグレーションファイルはデータベースごとに適用する必要がある

```
# 本番環境なら
$ bin/rails db:migrate RAILS_ENV=production
```
```
# テスト用データベースなら
$ bin/rails db:migrate RAILS_ENV=test
```

<br>

Railsアプリのデータベースは、どこまでマイグレーションが当たっているかを自己管理している。データベース内に作成される`schema_migrations`というテーブルを通じて行われ、どのマイグレーション（バージョン）が適用済みかをデータとして保存している。

<br>

`changeメソッド`内に、「テーブルを削除する」というコードが書かれていれば、マイグレーションの適用を取り消す処理を行ってくれるため、書く際に意識するレベルを下げてくれる

<br>

マイグレーションファイルの名前は一意である必要があるため、より具体的な名前をつけるように

`AddDeadlineToTasks`みたいに

<br>

## schema.rb

現在のデータベースの構造を表すファイル。マイグレーションを適用したり外したりすると自動的に更新される。手動で変更しないように！！

<br>

## マイグレーションに関する主なコマンド集

|コマンド|意味|
|-|-|
|bin/rails db:migrate|最新のマイグレーションを適用する|
|bin/rails db: migrate VERSION=20210403|特定のバージョンまでマイグレーションが適用された状態にする。VERSIONにはマイグレーションファイル名の先頭数字部分を指定する|
|bin/rails db:rollback|バージョンを１つ戻す|
|bin/rails db:rollback STEP=2|バージョンを指定したステップ数だけ戻す|
|bin/rails db:migrate:redo|バージョンを１つ戻してから１つ上げる（バージョン自体は変化してないが、バージョンを戻す処理が想定通り動作することを確認できる）|

<br>

## データ方型
|データ型|説明|
|-|-|
|:boolean|真偽値|
|:integer|符号付き整数|
|:float|浮動小数点|
|:string|文字列（短い）|
|:text|文字列（長い）|
|:data|日付|
|:datetime|日時|

<br>

## NOT NULL制約

データベースのカラムの値として`NULL`を格納する必要がない場合には、`NOT NULL制約`をつけることで、物理的にNULLを保存できないようにできる。

```
$ bin/rails g migration ChangeTasksNameNotNull
# ChangeTasksNameNotNullという名前のマイグレーションファイルを作成
```

```
class ChangeTasksNameNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :tasks, :name, false
  end
end
```

`change_column_null`を使うと、既存のテーブルの既存のカラムの`NOT NULL制約`を付けたり外したりできる

引数には、テーブル名、カラム名、NULLを許容するかどうかをそれぞれ指定する

テーブル作成時に、NOTNULL制約をかけることもできる↓

```
class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.text :description,
...
```

引数として、`null: false`を指定

<br>

## 文字列カラムの長さを指定する

`limitオプション`で、データベースのカラム定義で文字列の長さを指定することができる

```
lass CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :name, limit: 30, null: false
      t.text :description,
...
```

<br>

テーブル作成後に別途`limit`をつけるようなマイグレーションを追加する場合は、次のようなマイグレーションを作成・適用する

```
class ChangeTasksNameLimite30 < ActiveRecord::Migration[5.2]
  def up
    change_column :tasks, :name, :string, limit: 30
  end

  def down
    change_column :tasks, :name, :string
  end
end
```

`up`メソッドにバージョンを上げる処理

`down`メソッドにバージョンを下げる処理を記述する

なぜなら、`change_column`では、バージョンを戻す処理を、バージョンを上げる際のコードから自動生成できないから。changeメソッドに`up`の内容だけを書いた場合、このマイグレーションを取り消す際に、not automatically reversible(自動的に戻せない)という例外が発生する

<br>

## ユニークインデックス

あるテーブルのあるカラムのデータが（もしくは、複数のカラムのデータの組み合わせが）、全レコード内で一意である場合には、データベースにユニークインデックスを作成することで、一意性が壊されるのを防ぐことができる


テーブル作成時
```
class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    ...
    t.timestamps
    t.index :name, unique: true
  end
end
```

<br>

後からユニークインデックスを追加する際には

```
class AddNameIndexToTasks < ActiveRecord::Migration[5.2]
  def change
    add_index :tasks, :name, unique: true
  end
end
```

<br>

ユニークインデックスを作成すれば、重複した値がデータベースに存在することを確実に防ぐことができる

なお、データベースでは、`NULL同士は常に異なる値`だとみなされることに注意。そのため、ユニークインデックスを作成しているカラムの値がNULLのレコードは複数存在することができる

<br>

- `saveメソッド`は、データベースの登録・更新のためのメソッド。データベースの登録・更新を行う前に自動的に検証を行い、検証エラーがあれば`false`を返す。検証エラーの詳細には、`error`を通じてアクセスできる。

- `valid?メソッド`とは、検証を行うためのメソッド。妥当であるという意味。

- `save!メソッド`は、検証エラー時に`false`を返すのではなく、例外を発生させるメソッド。`save!`を使った場合は、例外が出なければデータベースへの登録・更新が間違いなく行われたと考えることができる。基本的に登録・更新が成功するはずと信じている場面（検証エラーのハンドリングを行わない場面）では、saveよりもsave!を使った方が、予期せぬ失敗を防ぐことができる。

- `validate: false`オプションをメソッドに渡すことで、検証を意図的にスキップすることができる。

```
task.save(validate: false)
```

<br>

## 検証の書き方

|検証内容|ヘルパーの使い方|
|-|-|
|必須のデータがちゃんと入っているか|vaidates :foo, presence: true|
|数値を期待しているところに数値以外がきてないか？小数点の有無・正負などが期待通りの数値か？|validates :foo, numericality: true|
|(数値)の範囲が期待通りか|validates :foo, inclusion: { in: 0..9 }|
|文字列の長さが想定通りか|validates :foo, length: { maximum: 30 }|
|文字列のフォーマットや構成文字種が想定通りか|validates :foo, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }|
|データが一意になっているか|validates :foo, uniqueness: true|
|パスワードやメールアドレスが、その確認用の入力と一致しているか|validates :foo, confirmation: true|


<br>

- `errors.full_messages`を使うことで、完成された検証エラーメッセージの形で情報を確認できる

```
task.errors.full_messages
#=> ["名称を入力してください"]
```

- `persisted?メソッド`を使うことで、そのオブジェクトがデータベースに保存済みかどうか確認できる

```
task.persisted?
#=> false
```

<br>

```
def create
 @task = Task.new(task_params) # 3
 if @task.save # 1
   redirect_to @task, notice: "登録完了#{@task.name}"
 else
   render :new # 2
 end
end
```

1. Modelでの検証を追加することで、ユーザーの入力次第では、検証エラーによって登録が失敗するようになったため、Controllerでのsave!メソッドをsaveメソッドに変更する。こうすることで、戻り値によって制御を変えるようにする

2. `render :new`とすることで、`save`での検証結果がfalseだったときに登録用のフォーム画面を再び表示して、ユーザーに再入力させる

3. 検証エラーにより`redner :new`で再入力させる際に、前回操作したままの値をフォーム内に引き継いで表示できる。また、Taskオブジェクトの抱える検証エラーの内容をユーザーに対して表示できる

<br>

## _form.html.slim内でのエラーメッセージ表示

```
- if task.errors.present?
 ul#error_explanation
   - task.errors.full_messages.each do |message|
     li= message
```

- `errors.present?メソッド`は、検証エラーの有無を調べるメソッド。エラーがあるときに、エラーメッセージを表示するようにする

<br>

```
validates :name, presence: true
validates :name, length: { maximum: 30 }
```

は、以下のように1行で書ける

```
validates :name, presence: true, length: { maximum: 30 }
```

<br>

## オリジナルの検証コードを書く

自分で検証コード方法は２種類ある

1. 検証を行うメソッドを追加して、そのメソッドを検証用のメソッドとして指定する
  1. 検証用のメソッドをモデルクラスに登録する
  2. 検証用のメソッドを実装する
2. 自前のvalidatorを作って利用する

```
# Taskモデルのname属性に`,`を登録させない
class Task < ApplicationRecord
 validates :name, presence: true, length: { maximum: 30 }
 validate :validate_name_not_including_comma

 private

   def validate_name_not_including_comma
     errors.add(:name, "にカンマを含めることはできません") if name&.include?(`,`)
   end
end
```

検証のメソッドの基本的な仕事は、「検証エラーを発見したら、errorsにエラー内容を格納する」こと

`errors.add`でnameに関する検証エラーの詳細を格納する

`&.`を利用して、nameがnilの場合に例外は発生させず、nilを返すようにしている。

<br>

|メソッド（#はインスタンスメソッド、.はクラスメソッド）|メソッドの説明|検証を行うか|
|-|-|-|
|#save|オブジェクトの現状通りに登録・更新を行う|○|
|#save!|オブジェクトの現状通りに登録・更新を行う|○|
|#update|変更内容を引数で指定し更新。save,save!を更新用途に便利にしたもの|○|
|#update!|変更内容を引数で指定し更新。save,save!を更新用途に便利にしたもの|○|
|#update_attributes|変更内容を引数で指定し更新。save,save!を更新用途に便利にしたもの|○|
|#update_attributes!|変更内容を引数で指定し更新。save,save!を更新用途に便利にしたもの|○|
|#update_attribute|1つの属性の変更を行う。検証は行わないが、その他の点はsaveと同様|×|
|#update_column|変更内容を引数で指定して更新を行うが、モデルに実装された検証やコールバックなどを実行せず、直接的にSQLを実行する|○|
|#update_columns|変更内容を引数で指定して更新を行うが、モデルに実装された検証やコールバックなどを実行せず、直接的にSQLを実行する|○|
|.create|オブジェクトを生成してsave/save!を実行する|○|
|.create!|オブジェクトを生成してsave/save!を実行する|○|
|.update_all|更新SQLを実行する。検証やコールバックは実行されない|○|

<br>

## コールバック　モデルの状態を自動的に制御する

- `コールバック`とは、Railsのモデルの典型的なライフサイクルである、「登録」「更新」「削除」などの重要なイベントの前後に任意の処理を挟むこと

`ActiveRecordモデルのコールバック`は、検証・登録・更新・削除といった主なイベントに対して「before(前)」「after(後)」「around(イベントを挟む)」の３つのタイミングで書くことができる。

モデルのコールバックの一例

「不正なデータが入ってきたら自動的に正しいデータに変更する」というアプローチ

タスクの名前が入力されていないときに「名前なし」という名前を自動的につけるという処理はコールバック。(データの正規化)

- `before_validation`とは、検証の前つまり、検証エラーになる前のコールバック

```
class Task < ApplicationRecord
 before_validation :set_nameless_name
 ...
 private
   def set_nameless_name
     self.name = "名前なし" if name.blank?
   end
end
```
<br>

代表的なコールバック

|コールバックの種類|代表的な使い道|
|-|-|
|before_validation|検証前の値の正規化|
|after_validation|検証結果（エラーメッセージ）の加工|
|before_save|saveのために裏側で行いたいデータ準備を行う(ある属性の値に従ってある関連を作成するなど)。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す。|
|before_create|検証結果（エラーメッセージ）の加工|
|before_save|saveのために裏側で行いたいデータ準備を行う(ある属性の値に従ってある関連を作成するなど)。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す。|
|before_upadte|検証結果（エラーメッセージ）の加工|
|before_save|saveのために裏側で行いたいデータ準備を行う(ある属性の値に従ってある関連を作成するなど)。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す。|
|after_save|そのモデルの状態に応じて他のモデルの状態を変えるなど、連動した挙動を実現する。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す|
|after_create|そのモデルの状態に応じて他のモデルの状態を変えるなど、連動した挙動を実現する。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す|
|after_update|そのモデルの状態に応じて他のモデルの状態を変えるなど、連動した挙動を実現する。検証エラーを出してもユーザーにはどうすることもできない状態異常を防ぐために例外を出す|
|before_destroy|削除してＯＫかをチェックし、ダメなら例外を出すなどして防ぐ|
|after_destory|そのモデルの削除に応じて他のモデルの状態を変えるといった連動した挙動を実現する|

<br>

## トランザクション

トランザクションとは、一連の複数の処理によるデータベースの整合性を保つための機能。銀行の送金処理が一例。送金処理は、入金と出金がセットで成功して処理が完了する。この時にトランザクションを利用することで、入金が成功したのに出金が失敗したときは、入金を取り消す（ロールバック）ことができる。

Railsでは、コールバック全体を１つのトランザクションで囲ってsaveを実行する。そのため、コールバックの１つで例外が発生すると、ロールバックが発生し、以降のコールバックは実行されない。これによってコールバック全体で整合性が保たれる。

なお、トランザクションの実行をトリガに呼び出されるコールバック`after_commit`,`after_rollback`も存在する

<br>

## セッション

Webアプリケーションでは、サーバー側にセッションという仕組みを用意して、１つのブラウザから連続して送られている一連のリクエストの間で「状態」を共有できる

- `sessionメソッド`を呼び出すことで、セッションにアクセスできる。sessionはハッシュのように扱うことができる

```
# 任意のキーを指定し、値を格納
session[:user_id] = @user.id

# 値を取り出す
@user_id = session[:user_id]
```

<br>

## Cookie

sessionがAPサーバー側で独自に実現される仕組みであるのに対して、Cookieは、ブラウザとWebサーバーの間でやりとりされる、より汎用的な仕組み。複数のリクエストの間で共有したい「状態」をブラウザ側に保存する仕組み

Railsでは、`cookiesメソッド`でブラウザから受け取り、送り返すことになるCookie情報にアクセスし、データを取得したり設定できるが、基本的にセッションを使えば済むため、直接Cookieを操作することはあまりない

Railsのセッションの仕組みの１部が、Cookieによって実現されていることを把握することが大切で、CookieによってやりとりされるセッションIDをキーにして保管される

Railsでは、セッションデータの保管場所を複数の選択肢から選ぶことが出来るが、デフォルトでは、この保管場所もCookieとなっている

そのため、ブラウザ側で対応するCookieデータを消せば、セッションはリセットされる

<br>

- `password_digest`とは、`has_secure_password`という機能を使った時の命名ルール。
- `digest`とは、元の値に戻すことができない一方的な変換（ハッシュ化）を行った文字列のこと。パスワードのdigestは、同じパスワードから生成すると常に同じになるため、パスワードの一致判定には利用できるが、それ自体には、生のパスワードを入手する役には立たない。

```
$ bin/rails g model user name:string email:string password_digest: string

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
      t.index :email, unique: true
    end
end
```

name,email,passwoerd_digestにNOTNULL制約をかけ、同じメールアドレスを持つユーザーが存在できないように制限

<br>

## digestを使うために

1. gem 'bcrypt'のインストール
2. modelに`has_secure_password`を記載

`has_secure_password`を記載することで、`password`と`password_confirmation`属性が追加される。

- `password`属性には、ユーザーが入力した生のパスワードを一時的に保存する
- `password_confirmation`属性は、passwordと一致することを確認するため

<br>

画面からの入力で、Userクラスのpasswordとpassword_confirmationが一致した場合、`password_digest`が生成され、データベースの`password_digest`に保存される

<br>

## admin

```
$ bin/rails g migration add_admin_to_users

class AddAdminToUsers < ActiveRecord::Migration[5.2]
  def change 
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
```

「管理系」の機能として「ユーザ管理」を行うため、`Admin::UsersController`という名前をつける。この名前は、`Admin`というモジュールの名前空間の中に`UsersController`というクラスを定義する意味。Railsでは、モジュール階層を、コードを保存するためのディレクトリ階層に対応させるため、`app/controllers/admin/users_controller.rb`というファイルが対応することになる。将来、管理系の機能を追加したい時に、`Admin::`のついたコントローラーを追加すれば、コードが`adminディレクトリ`の下にまとまりわかりやすくなる

```
$ bin/rails g controller Admin::Users new edit show index
```

```
routes.rb

namespace :admin do
  resources :users
end
```

ルートを上記のように設定することで、`admin_users_path`や`admin_user_path`など、`admin_`がついた名前のヘルパーメソッドをが使えるようになる

<br>

## 名前空間を使った場合の指定方法

`[<:名前空間名>, <変数名>]`

`[:admin, @user]`

<br>

- `リソース`とは、コントローラーが扱う概念的なデータのこと
- リソースとしての`セッション`とは、「あるユーザーとしてのアプリケーションとしてのやりとり」というような意味合い

<br>

## scope: :session

form_withでは、`socep`オプションに指定した値が`input`フィールドのname属性のプレフィックス（接頭語）になる。

値を取り出すには、`session[:user_name] = session_params[:name]`とするだけ。つまり`session`が頭についただけ

<br>

```
class SessionsController < ApplicationController

  def new
  end

  def create 
    user = User.find_by(email: session_params[:email]) # 1

    if user&.authenticate(session_params[:password])   # 2
      session[:user_id] = user.id                      # 3 
      redirect_to root_path, notice: "logged in"
    else
      render :new
    end
  end

  private
    def session_params
      params.require(:session).permit(:email, password)
    end
```

1. creataアクションで、送られてきたメールアドレスでユーザー検索を行う
2. ユーザーが見つかった場合、送られてきたパスワードによる認証を`authenticateメソッド`を使って行う

`authenticateメソッド`とは、Userクラスに`has_secure_password`と記述したときに助動的に追加されて、認証のためのメソッド。引数で受け取ったパスワードをハッシュか化し、その結果がUserオブジェクト内に保存されいる`digest`と一致するかを調べる。一致していたら認証成功で、Userオブジェクト自身を返す。一致していなければ、認証失敗で、falseを返す

メールアドレスに対応するユーザーが見つからなかった時、userはnilになるため、`&.`を使い、例外が発生しないようにしている

1. 誰もログインしていなければ。session[:user_id]はnil
2. 誰かがログインしていれば、session[:user_id]にログイン中のユーザーIDが入っている

<br>

ログイン後は、セッションが生きている限り、下記のコードでユーザーを簡単に取得することができる

```
User.find_by(id: session[:user_id])
```

`User.find(session[:user_id]`でも、ユーザーを取得できるが、findメソッドは、nilを渡した時エラーが発生する。そのため、セッションが消えている時にはエラーが発生してしまうため`find_by`を使う。


current_userメソッドのように、頻繁に使うメソッドは、ビューやコントローラーから簡単に呼べる必要があるため、`helper_method`として定義しておく。また、アクションでないユーティリティメソッドは、privateメソッドにするのが定石

<br>

## ログアウト機能

ログインするには、`Session[:user_id]`を`nil`にすればよいので,

```
session.delete(:user_id)
```

<br>

user_idだけでなく、ユーザーに紐づくその他の情報をセッションに入れるようにしている場合には、ログアウト時にセッション内のデータ全てを削除する方が良いため、次のようにする

```
reset_session
```

<br>

`before_action`メソッドを使えば、指定したアクションの前に処理が挟まり、アクション処理の前にリダイレクトなどが行える。

`フィルタ機能`はモデルのコールバックと似た概念

```
# application_controller.rb

before_action :login_required

private

 def login_required
   redirect_to login_path unless current_user
 end
```

この処理により、current_userが存在していなければ(ログインしていなければ)、ログイン画面にリダイレクトすることができるが、ログイン画面を表示させるためのアクションに対しても`login_requriedフィルタ`が実行されてしまうため、無限にリダイレクトが実行されてしまう問題がある。。

これを避けるために、SessionsControllerでは、ログインしなくても利用できるようにする必要がある。

`skip_before_action`とは、before_actionをスキップするためのメソッド

```
class SessionsController < ApplicationController
 skip_before_action :login_required
end
```

この記述を追加することで、無限リダイレクトを回避することができる

<br>

## ログインしているユーザーのデータだけを扱えるようにするには

1. UserとTaskを紐づける。tasksテーブルにuser_idというカラムを追加する。タスクを所有しているユーザーのidが格納されるようにする
2. UsetとTaskの紐づけを簡単に扱えるよう、Railsの「関連」を定義する
3. ログインしているユーザーに紐づいたTaskデータを登録できるようにする
4. 一覧、詳細、変更など既存のレコードを扱う機能では、ログインしているユーザーに紐づくデータだけを扱うようにする

<br>

TaskとUserを紐づける。１つのUserに対して複数のTaskが存在する`1対多`の関係になるため、「多」に当たるTask側に、Userを示す外部キー`user_id`を持たせる

```
$ bin/rails g migraation AddUserIdToTasks
```

```
class AddUserIdToTasks < ActiveRecord::Migration[5.2]
 def up
   execute 'DELETE FROM tasks;'  # 1
   add_reference :tasks, :user, null: false, index: true
 end

 def down
   remove_reference :tasks, user, index: true
 end
end
```

1の`execute`で実行される`DELETE FROM tasks;`というSQLによって、今まで作られたタスクが全て削除される。既存のタスクがある状態で、タスクとユーザーを紐づける`user_id`を追加すると、既存のタスクに紐づくユーザーを決めれず、`NOT NULL制約`に引っ掛かってしまう。そのため、既存のタスクを全て削除してから、カラム追加を行う必要がある

<br>

## 本番環境のマイグレーション

マイグレーションは本番環境でも実行吸うため、もし本番環境での運用が始まっているRailsアプリの場合、本番環境でマイグレーションを実行したときにすべてのデータが消えてしまう。本番環境での運用が始まっているRailsアプリに`NOT NULL制約`のカラムを追加したいときは、まずは制約なしでカラムを追加し、追加したカラムに値を入れるデータメンテナンスを行った後で、カラムに`NOT NULL制約`を付けるのが良い

`Associatio（関連）`とは、データベース上の紐づけを前提にして、モデルクラス同士の紐づけを定義することができる

```
class User < ApplicationRecord
 has_many :tasks
end

class Task < ApplicationRecord
 belongs_to :user
end
```

`user.tasks`メソッドが使えるようになり、Userクラスに紐づいたTaskオブジェクトの一覧を取得できる

`task.user`メソッドが使えるようになり、Taskクラスに紐づいたUserオブジェクトを得られるようになる

`has_many`は、そのクラス（User）のidを外部キーとして抱えるような他のクラス（Task）があり、そのレコードが複数登録可能であることを表している。子分的な存在が複数いるイメージ

`belongs_to`は、そのクラス（Task）が、ある別のクラス（User）に従属しており、従属先のクラスのidを外部キーとして抱えていることを表している。親分を指定するイメージ

`has_one`は、「1対1」の関係を定義するメソッド

`has_and_belongs_to_many`は、「多対多」を定義するためのメソッド。単純で簡潔だが、実現できる機能に限りがある

`has_many と :through`も「多対多」を定義するためのメソッド。複雑だが、柔軟。


```
@task = current_user.tasks.new(task_params)

# or

@task = current_user.tasks.build(task_params)
```

`new`は、current_userオブジェクトが内部的に抱えるtaskリストを変更する。currnt_userは画面のあちこちで利用する可能性がある特別なオブジェクトであり、保存に失敗したtaskオブジェクトを抱える状況はなるべく避けたい場合に使用する

`build`は、変更する。多くの場合は、`build`が適切かもしれない

<br>

## ログインしているユーザーのタスクを取得

```
@tasks = current_user.tasks

# or 

@tasks = Task.where(user_id: current_user.id)
```

<br>

## ログインしているユーザーのタスクの詳細

`Task.find(params[:id])`のままだと、ユーザーが適当に`/tasks/32`と打ち込んだら見れてしまうため、

```
current_user.tasks.find(:params[:id])
```
とすることで、ログインしているユーザーのタスクに限定できる

<br>

## adminのみがユーザー一覧画面にはいれるように

```
- if current_user.admin?
 li.nav-item= link_to "ユーザー一覧", admin_users_path, class: "nav-link"
```
```
class Admin::UsersController < ApplicationController
 before_action :require_admin

 private
   def require_admin
     redirect_to root_path unless current_user.admin?
   end
end
```

上記により、current_user.admin?がtrueでなければ、root_pathに飛ばせるようになる

しかし、トップ画面にリダイレクトするということは、`/admin/users`のパスに何かしらのアクションが存在することを、adminでないユーザーに知らしめてしまうことになる。管理者機能の存在自体を隠すのであれば、アクションが存在しないときと同じようにHTTPステータスコード`404`を返すコードを書くのも手。

<br>

このままでは、管理者権限のあるユーザーいないので、コンソールから作成する

```
User.create!(name: "admin", email: "admin@example.com", password: "password", password_confirmation: "password", admin: true)
```

または、

Railsが用意しているSeedという仕組み利用する。

<br>

## データの絞り込み

```
User.where(admin: true).first
1       　　2             3
```


1.	起点
2.	絞り込み条件
3.	実行部分

<br>

## 絞り込み条件　クエリ

|メソッド|効果|
|-|-|
|where|SQLのWHERE節を作る。重ねがけをするとAND条件として重なっていく|
|order|SQLのORDER BY節を作る。検索結果の並び順を指定する|
|joins|SQLのJOIN節を作る。他のテーブルとのJOINを指定する。類似の昨日として関連オブジェクトの取得操作を含むincludes, preloadなどのメソッドもあるので、これらを合わせて検討する|
|select|SQLのSELECT節を作る。指定しなければ対象テーブルのレコード全てのカラムをインスタンスオブジェクトの属性として取得するが、指定した場合は、指定したカラムだけを属性として取得する。取得する情報を節約したい場合や、他のテーブル由来の情報をそのインスタンスの属性として扱いたい時に利用する|
|group|SQLのGROUP BY節を作る|
|limit|SQLのLIMIT節を作る。取得個数を制限する|
|distinct|SQLのSELECT節にDISTINCTを追加する。重複したレコードを１つにまとめる。rubyでいうuniqメソッド見たいな|
|all|何もしない検索条件。全件である事を示したり、whereなどの結果と同じ形のオブジェクトを得たい時に利用する|
|none|何もヒットしない検索条件。データベースに実際には検索に行かないが、何もヒットさせないということを明確にしつつ、whereなどの結果と同じ形のオブジェクトをえたい時に利用する|

<br>

クエリ用のメソッドは、それを呼んだ時点では、まだ検索などの処理は実行されない。実行部分に当たるメソッドを呼ぶ事で初めて実行される。

`.to_sqlメソッド`は、生成予定のSQLを見ることができるメソッド

<br>

## 実行部分

| メソッド名|効果|
|-|-|
|find|idを指定してレコードを取得する。見つからない場合は例外を発生させる。|
|find_by|条件を指定し、見つかったレコードを１件取得する。見つからなかった場合は、nilを返す。|
|なし(each,mapなど)|その検索結果でレコード全て（できるだけ遅いタイミングで）取得する。配列に対して使う操作を初めて行った時に、裏で検索が走り、検索結果が得られ、以降はその結果に対して、指定された操作が行われる。検索結果は配列のような感覚で利用される|
|first|検索条件にあう最初のレコードに対するオブジェクトを取得する|
|last|検索条件にあう最後のレコードに対するオブジェクトを取得する|
|exists?|検索条件に合うレコードの有無を取得する。引数に検索条件を指定することもできる|
|count|SQLのCOUNT関数を使って検索条件にあるレコード数を取得する|
|average|SQLのAVG関数を使って平均を取得する|
|maximum|SQLのMAX関数を使って最大値を取得する|
|minimum|SQLのMIN関数を使って最小値を取得する|
|update_all|検索条件にあるレコードを全て、インスタンス化せずに更新する。(検証・更新系のコールバックがよばれない)|
|delete_all|検索条件にあうレコード全て、インスタンス化せずに削除する(削除系のコールバックがよばれない)|
|destroy_all|検索条件にあうレコードをインスタンス化した上で、destroyメソッドを通じて削除する(削除系のコールバックがよばれる)|

<br>

`desc`は、降順。つまり日時で言うと新しいものから古いものへ

`ack`は、昇順。つまり古いものから新しいものへ。`order(created_at)と引数なしで渡すと`、ascがよばれる

<br>

## scope

`scope`を使うと、繰り返し利用される絞り込み条件をスッキリ読みやすくできる

```
class Task < ActiveRecord
	scope: :recent, -> { order(created_at: :desc) }  
```

上記で追加した`recent`という名前のスコープは、クエリー用のメソッドの一種として使うことができる

|コード例|意味|
|-|-|
|tasks = Task.recent|全件を新しい順に取得する|
|task = Task.recent.first|最も新しいタスクのオブジェクトを取得する|
|task = Task.recent.last|最も古いタスクのオブジェクトを取得する|
|tasks = current_user.tasks.recent|ログインしているユーザーのタスクを新しい順に取得する|
|tasks = Task.where(user_id: [1,2,5]).recent|IDが1,2,5のユーザーの作ったタスクを新しい順に取得する|

<br>

## フィルタを使い重複を避ける

現在、show, edit, update, destroyでは、`@task = current_user.tasks.find(params[:id])`という同じコードが書かれているため、フィルターを使い１つにまとめる。

```
before_action :set_task, only: [:show, :edit, :update, :destroy]

Private
	def set_task
		@task = current_user.tasks.find(params[:id])
	end
```

<br>

## 詳しい説明に含まれるURLをリンクとして表示する

`gem ‘rails_autolink’`

```
# views/tasks/show.html.slim
tr
	th= Task.human_attribute_name(:description)
	td= auto_link(simple_format(h(@task.description), {}, sanitize: false, wrapper_tag: “”div)
```

`rinku`というGemがあり、rails_autolinkよりも２０倍早いと歌っているそうな









































