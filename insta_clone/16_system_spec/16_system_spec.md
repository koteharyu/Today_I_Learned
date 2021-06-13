# System Spec

## capybaraの設定

gemをテスト環境配下に配置し、インストール

`webdrivers`...ChromeDriverをかんたんに導入してくれるgem。chromedriver-helper、selenium-webdriverは`Webdrivers`で代替できる

```gemfile
group :test do
 gem 'capybara'
 gem 'webdrivers'
end
```

```ruby
# spec/spec_helper

require 'capybara/rspec'
```

```terminal
$ mkdir spce/support
$ touch spec/support/driver_setting.rb
```

```ruby
# spec/support/driver_setting.rb

RSpec.configure do |config|
 config.before(:each, type: :system) do
   # spec実行時、ブラウザが自動で立ち上がり挙動を確認できる
   # driven_by(:selenium_chrome)

   # spec実行時、ブラウザoff
   driven_by(:selenium_chrome_headless)
 end
end
```

driven_by(:selenium_chrome)か、driven_by(:selenium_chrome_headless)どちらかを選択(一般的にはheadlessの方がノンストレス)

次に以下の設定をすることで`spec/support`配下を読み込むようにする

```ruby
# spec/rails_helper.rb

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }
```

## system specの生成

`$ bundle exec rspec system:user`コマンドで`system/user_spec.rb`ファイルを作成する

## ログイン処理をmodule化する

user_specにおいてログイン処理は頻発するため、moduleに切り分けておくと便利

今回は、spec/support/login_module.rbファイルを作成し、この中にログイン処理を記述していく

```ruby
# spec/support/login_module.rb

module LoginSupport
 def login(user)
   visit login_path
   fill_in 'メールアドレス', with: user.email
   fill_in 'パスワード', with: 'password'
   click_on 'ログイン'
 end
end
```

次に、切り分けたmoduleを読み込ませる

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
 config.include LoginSupport
end
```

作成したmoduleの使い方

```ruby
# user_spec

require 'rails_helper'
describe User, type: :system do
 let(:login_user) { create(:user) }
 ////
  describe 'after login' do
    before do
      login(login_user) #ここでmoduleで定義したloginメソッドを呼び出して、ログイン処理を実行している
    end
    it 'is success logout' do
      click_on "ログアウト"
      expect(current_path).to eq logout_path
      expect(page).to have_content "ログアウトしました"
    end
  end
end
```

## click処理

click_button...ボタンをクリック

click_link...リンクをクリック

click_on...ボタンとリンク、画像のalt属性をクリック

## スコープ within

`within`を使うことで、検索/操作の影響範囲を制限することができる

```ruby
within(:css, '.target_selector') do
 # 指定したセレクタ内に対してのみ検索/操作が行われる
end
```

within('selector')...指定したセレクタに該当する要素以下をスコープする

within(node)...指定したノード(Element)以下をスコープする

within_fieldset('locator')...指定したフィールド以下をスコープする

within_table('locator')...指定したテーブル以下をスコープする


## テスト失敗時のスクリーンショット

テストが失敗した場合は、tmp/screenshotsディレクトリにスクリーンショットが記録されるため、どこで失敗したのか実際のブラウザを見て確認できる

## data confirma

投稿を削除する際の`data: { confirm: "本当に削除しますか?" }`を操作するには以下の記述をすればいい

```ruby
# 自分の投稿を削除する

describe '削除機能' do
  let(user) { create(:user) }
  let(user_post) { create(:post, user: user) }
  it '自分の投稿を削除できること' do
    login(user)
    within "#post-#{post.id}" do # withinを使って操作範囲を指定
      page.accpect_confirm { find('.delete-button').click }
    end
    expect(page).to have_content '投稿を削除しました'
  end
end
```

Capybaraが用意してくれている方法で記述することもできるとのこと

```ruby
page.accept_confirm do
  click_on :delete_button
end
```

[Selenium/RSpecでconfirmダイアログのテストをする](https://qiita.com/at-946/items/403d85d45cb02615c323)
