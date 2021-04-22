## chapter9 複数人でRailsを開発する

初期データ・テスト用データの共有

```
# db/seeds.rb

User.create!(
 name: "admin",
 email: "admin@example.com",
 admin: true,
 passwrd: "password",
 password_confirmation: "password"
)
```

`$ bin/rails db:seed`コマンドを実行することで、admin権限を持つユーザーを作成できる。

が、すでに、"admin@example.com"のメアドで登録しているユーザーがいれば、エラーが出るので注意

`find_or_create_by!`メソッドとは、引数に渡した属性で検索を行い、レコードが見つからなければそのレコードを返し、見つからなければ新たなレコードを作成する

```
# db/seeds.rb

User.find_or_create_by!(email: "admin@example.com") do |user|
 user.name = "admin",
 user.admin = true,
 passwrd: "password",
 password_confirmation: "password"
end
```

と、することで、"admin@example.com"の値をもつユーザーがいる場合にエラーが出る現象を回避できる

<br>

「ordersテーブルのfree_shipカラムのデフォルト値をtrue」にするマイグレーションファイルを書く際は、

```
class ChangeFreeShipDefaultToTrue < ActiveRecord::Migration[5.2]
 def change 
   change_column_default :orders, :free_ship, from: false, to: true
 end
end
```

`:from, :to`オプションで、どの値からどの値へ変更するかを知らせるようにしないと、ロールバックした際にデータベース変更処理を自動生成できずエラーが出てしまう

<br>

`$ bin/rails db:migrate:redo` `redo`を付けることで、バージョンアップ、ロールバック、バージョンアップまでを一気にしてくれるので、ロールバックできるマイグレーションが書けていることの証拠になるためredoを付けることを習慣化させよう！

<br>

`find_each`メソッドは、1000件単位でレコードを取得する。1001件目のレコードを取得するとしても、1000件分のレコードを格納したメモリを解放したうえで、1001件目のレコードを扱ってくれる

```
Order.find_each do |order|
 order.update(free_ship: true)
end
```

一度に多くのレコードを操作する際は、`find_each`を使ってメモリに負担をかけすぎないようにする

<br>

`reset_column_information`メソッドを使うことで、スキーマキャッシュを更新できる

`スキーマキャッシュ`の特徴

- モデルインスタンス作成時、ActiveRecordはスキーマをキャッシュする
- テーブル単位でキャッシュし、同一コネクションでキャッシュを利用する
- テーブルへの変更は自動ではスキーマキャッシュに反映されない。カラムの追加だけでなく、変更・削除も同様

`ignored_columns`メソッドとは、設定したカラムがActiveRecordから認識させなくするためのメソッド。カラムを削除することを予定している場合に、そのカラムを指定したりする