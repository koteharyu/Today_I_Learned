## sorceryとは

ログイン機能を手軽に実装できるgem

4年以上更新されていないため、RSpecのsystem specが使えないことに注意

### 導入

`gem 'sorcery'`にて、インストール

`bundle exec rails g sorcery:install`コマンドで諸々必要なファイルが作成される

### 注意

自分だけかもしれないが、自動で作成されたマイグレーションファイルを少しいじる必要があった

デフォルトでは、Userテーブルを作成することになっていたので、rails db:migrateはできるが、その後ユーザー作成時にエラーが発生

そのため、一度rollbackして、usersに変更することで、想定通りの挙動になった

### 使用できるメソッド(公式抜粋)

```
require_login # This is a before action
login(email, password, remember_me = false)
auto_login(user) # Login without credentials
logout
logged_in? # Available in views
current_user # Available in views
redirect_back_or_to # Use when a user tries to access a page while logged out, is asked to login, and we want to return him back to the page he originally wanted
@user.external? # Users who signed up using Facebook, Twitter, etc.
@user.active_for_authentication? # Add this method to define behaviour that will prevent selected users from signing in
@user.valid_password?('secret') # Compares 'secret' with the actual user's password, returns true if they match
User.authenticates_with_sorcery!
```

[reference](https://github.com/Sorcery/sorcery)
[reference](https://qiita.com/d0ne1s/items/f6f8f4cc7ae6eea069fb)