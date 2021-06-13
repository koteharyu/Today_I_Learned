# 15_model_spec

## 要件

- ユーザーモデルとポストモデルのスペックは最低限書くこと。その他のモデルは任意
- バリデーション・スコープ・インスタンスメソッドのスペックを書くこと

## RSpec・FactoryBot・spring-command-rspecの導入

RSpecはテストであるため、gemはテスト環境に追加すれば良いのだが、`RSpec generator`が使えると何かと便利になるため、`group :development, :test`配下に追加するのがベター

テストデータを作成するためのFactoryBotも同様に、`group :develoment, :test`配下に追加する

`bin/rspec`コマンドが使えるようになると、テストの実行速度を上げることができるため、`gem 'spring-commands-rspec'`も`group :development, :test`配下に追加する

```Gemfile
# Gemfile

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
end
```

いつも通り`bundle`

次に、`bundle exec rails g rspec:install`コマンドを実行し、必要なファイルを生成させる

`config/application.rb`にて`$ rails g`コマンドで自動生成するファイルについての設定を行う。今回は、Model spec と System specのみを使用する場合は以下のように設定すれば良い

```ruby
# config/application.rb

config.generators do |g|
  g.test_framework :rspec,
    view_spec: false,
    helper_spec: false,
    controller_spec: false,
    routing_spec: false,
    request_spec: false,
end
```

`.rspec`内に`--format documentation`を記述することで、実行結果を見やすくすることができる

この記述をしなければ、通過したテストは`...`と省略される

## bin/rspecの作成

先ほど追加した`gem 'spring-commands-rspec'`をbundle installしたのち、`bundle exec spring binstub rspec`コマンドを実行することで、binディレクトリに`rspec`ファイルが生成される。

よって、`bin/rspec`コマンドでテストを実行することができる様になる(高速)。100件以上のテストをする場合は、`bundle exec rspec`コマンドで実行したほうが速いとの噂もあるそう

## FactoryBotの準備

`spec/rails_helper.rb`内に以下を記述することで、FactoryBotシンタックスを省略することができる様になる

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```

こうすることで、以下の様に省略して記述できる

```ruby
# before

FactoryBot.build(:user)
FactoryBot.create(:user)
FactoryBot.build_stubbed(:user)
FactoryBot.attributes_for(:user)

# after

build(:user)
create(:user)
build_stubbed(:user)
attributes_for(:user)
```

- build...作成したインスタンスを保存しない場合
- create...作成したインスタンスを保存する場合
- build_stubbed...アソシエーション元のBDを保存する必要がなく、テストの速さを優先したい場合
- attributes_for...ハッシュで各属性の値を取得したい場合
- sequence...連番を振りたい場合

```ruby
# sequenceの例

FactroyBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
  end
end
```

とすることで、1回目に作成されたuser.email は test1@example.com となっている

## Capybaraの設定

`Capybara`を導入することで、Webアプリのブラウザ操作をsミュレートすることができる

Rails5.1からデフォルトで同梱されいるとのことだが、今回は`--skip-test`オプションを指定してrails newしているので`group :test`配下に追加する()

`webdrivers`とは、ChromeDriverを簡単に導入してくれるためのgem

```ruby
# Gemfile

group :developmen, :test do
  gem 'capybara'
  gem 'webdrivers'
end
```

次に、`/spec/rails_helper.rb`内に`requrie 'capybara/rspec'`の一行を追記することでRSpecでCapybaraを扱えるようになる

```ruby
# spec/rails_helper.rb

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rspec'  # この一行を追加
end
```

[Capybara](https://github.com/teamcapybara/capybara)

## test用DB

テストはテスト環境で行うため、`bundle exec rails db:create RAILS_ENV=test`コマンでテスト環境のDBを作成し、`bundle exec rails db:migrate RAILS_ENV=tes`コマンドでテスト用DBをマイグレートする

## simplecovの導入

simplecovとは、RSpecで書いたテストのカバレッジを計測してくるツール。

```Gemfile
gem 'simplecov'
```

```
# spec_helper.rb

require 'simplecov'

SimpleCov.start 'rails'
```

上記の設定を済ませ、RSpecのテストを実行することで、ルートディレクトリに`coverage`というフォルダが作成される。この中にファイルでカバレッジ率を確認できる

[simplecovでRspecのテストを書くが楽しくなった話](https://qiita.com/komatsubara/items/02962feb28a9eb7e9123)

イメージ

[![Image from Gyazo](https://i.gyazo.com/cf11751f5d582a203ac8b5089c3d0e66.png)](https://gyazo.com/cf11751f5d582a203ac8b5089c3d0e66)

<br>

## model spec & factoryの作成

`$ bundle exec rails g rspec:model user`コマンドを実行することで、`/spec/models/user_spec.rb`, `/spec/factories/users.rb`が作成される。便利

加えて上記のコマンドから生成されたspecファイルには`require 'rails_helper'`がデフォルトで記述されているので、書き忘れ防止にもなる！

## model spec

specファイル内で使用する`.valid?`メソッドについてよく理解できていなかったが、この[記事](https://qiita.com/AK4747471/items/1b7b4af1e6d102625562)を見て理解できた!

例えば、name属性がnilであればバリデーションに引っかかるUserモデルがある場合のスペック

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'nameがnilであれば無効である' do
    user = build(:user, name: nil)
    user.valid?
    expect(user.errors[:name]).to include("を入力してください")
  end
end
```

`.valid?`メソッドを使うことで、エラー検証を行うことができる。また、`valid?`メソッドは、次の行の`errors`メソッドを使うために必要なメソッド。今回は、valid?メソッドがfalseを返し、そのエラー内容を`user.errors`が持っている。`include`で`user.errors[:name]`が持っているエラーメッセージを含んでいることを検証している
