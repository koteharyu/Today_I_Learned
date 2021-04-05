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

