# マイグレーションファイルを自由自在に操るんだ

間違ったマイグレーションファイルをmigrateしてしまった

```rb
class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end
```

`$ rails db:migrate:redo`

癖で`redo`オプションをつけているのだが、変な挙動になり以下のようなschemaが生成されてしまった

```rb
create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
  t.string "name"
  t.datetime "created_at", precision: 6, null: false
  t.datetime "updated_at", precision: 6, null: false
end
```

1. nameにNot Null制約がかかっていないあ
2. インデックスのカラム名をタイポしたため反映されていない

## 試行錯誤

### 1. テーブル丸ごと削除だ！

今思えば新たに削除ようのマイグレーションファイルを作成するべきだった...

```rb
class CreateTags < ActiveRecord::Migration[6.0]
  def change
    drop_table :tags
  end
end
```

一旦マイグレートし、無かったことに。

だが、致命的なミスに気づく。このままだとファイル名が被ってしまう...現状のファイル名は`xxxx_create_tags.rb`だからだ。このままでは`rails g model tag name`コマンドが実行できないぞ...

### 2. ならば後付けじゃい

そもそもschemaには中途半端なtagsテーブルが生成されていたため、以下の内容に書き換え

```rb
class CreateTags < ActiveRecord::Migration[6.0]
  def change
    change_column_null :tags, :name, false
    add_index :tags, :name
  end
end
```

自分でまとめながらも、ややこしすぎて記憶を疑ってしまうが、何が言いたいかというと

今回の迷走でマイグレーションに対する自信がかなり身についたということ！

ま、最初から間違わずにファイルを生成すればいい話なのだが...
