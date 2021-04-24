# sorcery with mysql

gem 'sorcery'

bundle install

bundle exec rails g sorcery:install

作成されたmigration

```
# migration

class SorceryCore < ActiveRecord::Migration[5.2]
  def change
    create_table :User do |t|
      t.string :email,            null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps                null: false
    end

    add_index :User, :email, unique: true
  end
end
```

bundle exec rails db:migrate

コンソール内で、ユーザーが作成できるか試したところ`ActiveRecord::StatementInvalid: Mysql2::Error:`が出現

usersテーブルが作成されてないよと仰っておる。

migrationは上手くいっている。のになぜ？

## 原因

```
# migration

class SorceryCore < ActiveRecord::Migration[5.2]
  def change
    create_table :`User` do |t|
      t.string :email,            null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps                null: false
    end

    add_index :`User`, :email, unique: true
  end
end
```

原因は`User`だった

これを`users`に修正し、再度マイグレーションを行うと想定通りの動きになった！

デフォルトで`users`にしといてよ、sorceryさん

