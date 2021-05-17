# ActionMailerについて

基本的なActionMailerについてまとめてみました。

ActionMailerを使うことで、アプリケーションのメイラークラスやビューでメールを送信することができる。メイラーのアクションはコントローラーの動きと酷似していることを意識すると理解がしやすい。

## 導入手順

### メイラーの生成

`$ be rails g mailer <任意メイラー名>`コマンドを実行することで、以下のメイラーやviewが生成される

```
# mailers/application_mailer

class ApplicationMailer < ActionMailer::Base
 default from: "from@example.com"
 layout "mailer"
end
```

```
# mailers/<任意メイラー名>

class <任意メイラー名> < ApplicationMailer
end
```

`layout`オプション...復習になるが、`layout 'mailer'`と指定することで、`app/views/layouts/mailer`ファイルがレンダーされる。

`application_mailr`...全メイラー共通の設定を記述する場所

`<任意メイラー>_mailer`...メイラー個別の設定を記述する

### メイラーの編集

生成された`mailers/<任意>.rb`を編集することで、メイラーを使っての送信したいメッセージの作成ができる

今回は`UserMailer``welcome_mail`という名前のメソッドを追加し、ユーザーが登録したメールアドレスにメールを送信するメイラーは以下のようになる

```
# <任意メイラー>_mailer.rb

class <任意メイラー> < ApplicationMailer
 default from: '<任意メールアドレス>'

 def welcome_mail
   @user = params[:user]
   mail(to: @user.email, subject: 'よくおこひくだしゃいまひたぁー')
 end
end
```

`default Hash`...メイラーから送信するあらゆるメールで使われるデフォルト値のハッシュを指定できる。指定できるプロパティは以下の通り(他にもあるがよく使われるプロパティを抜粋)

|プロパティ|役割|
|-|-|
|to|送信先の指定|
|cc|一斉送信先の指定|
|bcc|非表示送信先の指定|
|from|メールの送信元名|
|subject|メールタイトル|
|date|メールの送信日時|
|reply_to|返信用アドレスの指定|

`mail`メソッド...実際のメール。上記では、`to`, `subject`を渡してメールを作成している(まだ送信はしていないことに注意)

コントローラー同様、メイラーのメソッド内で定義されたインスタンス変数はビューで使える

### メイラービューの作成

メイラーのファイル名は、定義したメソッド名に合わせる必要があることに注意。よって今回の場合だと、`app/views/user_mailer/welcome_mail.html.slim or erb`ファイルを作成する。

なお、場合によってはHTML形式のメールを受け取りたくない人もいるため、同じ内容のテキストファイルも用意しておいた方が無難である。`app/views/user_mailer/welcome_mail.text.slim or erb`

2種類のファイルがある場合、どちらの形式でメールが送られるの？と疑問に思うかもしれないがその心配は必要がない。現在のAction Mailerでは`mail`メソッドを呼び出すと２種類のテンプレート(テキストおよびHTML)があるかどうかを探し、`multipart/alternative`形式のメールを自動生成してくれる。

`multipart/alternative`とは...「AパターンとBパターンを合体させ、一度に送る」形式のこと。[メールの形式について](http://fuji3.main.jp/common/tips/mail_m_p.html#:~:text=multipart%2Falternative%20%E5%BD%A2%E5%BC%8F%E3%81%A8%E3%81%84%E3%81%86%E3%81%AE,%E8%AA%AD%E3%82%81%E3%82%8B%EF%BC%A1%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3%E3%82%92%E8%A1%A8%E7%A4%BA%E3%80%82)

## メールを送信する

メールを送るための準備をここまでの工程で行ってきた。いよいよ準備万端なメールを送る処理の実装を行う

今回は、新規登録をおこなったユーザーのメアドに対してwelcomeメールを送るものなので、ユーザーの新規登録処理の中でメールを送る処理を行えばいい

```
class UsersController < ApplicationController
 def create
   @user = User.new(params[:user])

   responde_to |format|
     if @user.save
       #保存成功後にUserMailerを使ってwelcomeメールを送信
       UserMail.with(user: @user).welcome_mail.delivery_later
       format.html { redirect_to @user, notice: "新規登録に成功しました。メールを確認ください" }
       format.json { render json: @user, status: :create, location: @user }
     else
       format.html { render action: 'new' }
       format.json { render json: @user.errors, status: :unprocessable_entity }
     end
   end
 end
end
```

`unprocessable_entity`とは、バリデーションエラー(サーバー側のエラー)の場合の422ステータスコードを返すシンボルのこと

[その他はこちらの参照](https://morizyun.github.io/ruby/rails-controller-status-code.html)

`with`メソッド...このメソッドに渡されるキーの値は、メイラーアクションでは単なる`params`と同意になる。つまり、流れとしては、`UserMail.with(user: @user)`の変数`user`が、`welcome_mail`内の`params[:user]`に渡される

withに慣れる

`with(user: @user, account: @user.account)`とすれば、メイラーアクション内で`params[:user]`, `params[:account]`とすることができる

### Active Job

Active Jobはデフォルトで`:async`で実行する。したがって、この時点でメールをdelivery_laterで送信できる。Active Jobのデフォルトのアダプタの実行では、インプロセンスのスプレッドシートが用いられる。これは外部のインフラを一切必要としないため、、development/test環境に適している。しかし、ペンディング中のジョブが再起動時に削除されるため、productionには不向きである。永続的なバックエンが必要な場合は、永続的なバックエンドを用いるActive Jobアダプタ(SidekiqやResqueなど)を使う必要がある

ふーーーーーむ。

`async`...非同期関数を定義する関数宣言のこと。恐らくAjaxの類ではなかろうか...

## config/environments/[Rails.env].rb

メール送信に使うであろう設定について少しまとめてみる

`cofig.action_mailer.raise_delivery_erros`...メールの送信に失敗した時にエラーを出すかどうか(trueにすれば出る)

`cofig.action_mailer.delivery_method = :smtp`...メール送信時に使用するプロトコルの指定。デフォルトでは`smtp`が使われるため、必要に応じて変更すればいいだろう

<br>

## 小ネタ

### メールアドレスを名前で表示する

受信者のメールアドレスをメールにそのまま表示するのではなく、受信者の名前で表示する際には、メールアドレスを`"フルネーム"<メールアドレス>`の形式で指定する

```
def welcome_mail
 @user = params[:user]
 email_with_name = %("#{@user.name}")<#{@user.email}>
 mail(to: email_with_name, subject: "ようこそ！")
end
```

[ちょくちょくも見返そう。特にgmailで送信する方法とかは今後絶対使うときがくる](https://railsguides.jp/action_mailer_basics.html)

[Action Mailer でメール送信機能をつくる](https://qiita.com/annaaida/items/81d8a3f1b7ae3b52dc2b)
