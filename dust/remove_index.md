# remove index

insta_cloneにて、direct_messageの機能を実装している中で、タイポしたまま`rails db:migrate`していたことがわかり、その修正を行った記録です。

## 正しいファイル

```ruby
create_table "chatroom_users", force: :cascade do |t|
  t.integer "user_id"
  t.integer "chatroom_id"
  t.datetime "last_read_at"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["chatroom_id"], name: "index_chatroom_users_on_chatroom_id"
  t.index ["user_id", "chatroom_id"], name: "index_chatroom_users_on_user_id_and_chatroom_id", unique: true
  t.index ["user_id"], name: "index_chatroom_users_on_user_id"
end
```

## 謝ったファイル

```ruby
create_table "chatroom_users", force: :cascade do |t|
  t.integer "user_id"
  t.integer "chatroom_id"
  t.datetime "last_read_at"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
  t.index ["chatroom_id"], name: "index_chatroom_users_on_chatroom_id"
  t.index ["user_id", "chatroom_id"], name: "index_chatroom_users_on_user_id_and_chatoom_id", unique: true
  t.index ["user_id"], name: "index_chatroom_users_on_user_id"
end
```

`t.index ["user_id", "chatroom_id"]`に注目して欲しい。正しくは`chatroom_id`と書くべきところを`chatoom_id`とタイポしたままmigrateしてしまっていた。

## 解決策

`$ bundle exec rails g migration RemoveIndexFromChatroomUser`コマンドで任意のマイグレーションファイルを作成する。今回は`RemoveIndexFromChatroomUser`にした。

```ruby
class RemoveIndexFromChatroomUser < ActiveRecord::Migration[5.2]
  def change
    remove_index :chatroom_users, name: "index_chatroom_users_on_user_id_and_chatoom_id"
  end
end
```

[参考](https://stackoverflow.com/questions/22745757/how-to-remove-index-in-rails)

## 失敗

色々な記事を参考にする中で、`:テーブル名, column: :カラム名`書くよう方法もあるとのことだが今回はうまくいかなった。[参考](https://qiita.com/kawakubox/items/188a311c49a172609a31)

以下が失敗したファイル

```ruby
class RemoveIndexFromChatroomUser < ActiveRecord::Migration[5.2]
  def change
    remove_index :chatroom_users, column: [:user_id, nil]
  end
end
```

## add index

もしかしたらremove indexする中でadd indexもできるかもしれないが今回はかなりビビりながら正しくindexを張り直した。

```ruby
class AddUserChatroomIndexToChatroomUser < ActiveRecord::Migration[5.2]
  def change
    add_index :chatroom_users, [:user_id, :chatroom_id], unique: true
  end
end
```
