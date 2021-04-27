# Fakerを使ってダミーデーターを作成する

## 導入

```
# Gemfile

group :development, :test do
 gem 'faker'
end
```

## 使い方

`Faker::[ジャンル].[タイトルなど]`を.rbファイル内に記述する

```
# seeds.rb

100.times do |n|
 name = Faker::Pokemon.name
 email = Faker::Internet.email
 password = "password"
 User.create!(
   name: name,
   email: email,
   password: password,
   password_confirmation: password
 )
end
```

`$ bundle exec rails db:seed`コマンドを実行することで、seeds.rbに記述したデータを反映できる

<br>

```
# factories/book.rb

FactoryBot.define do
 factory :book do
   title { Faker::Book.title }
   author { Faker::Book.author }
   publisher { Faker::Book.publisher }
 end
end
```

<br>

[Fakerで生成できるもの](https://github.com/faker-ruby/faker)
[Fakerを使ってみました！](https://qiita.com/ginokinh/items/3f825326841dad6bd11e)
[テストに使うダミーデータを用意する](https://qiita.com/koki_73/items/60c2441fb873a8db35d5)
