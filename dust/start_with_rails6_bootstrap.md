# rails6 + bootstrapでのセットアップ(自分用)

プロジェクトを新規作成する際に、毎回行うことを一つにまとめておこうということでこの記事を書くことに決めました。

## rails new

データベースはpostgresqlを使用する

```
$ be rails new . -d postgresql --skip-turbolinks
```

## gitignore

`bundle install --path vendor/bundle`が習慣になっているため、`vendor`ディレクトリをgitignoreする

```
/vendor
/.vscode
```

## solargraph and rubocop

gemfileへの追加

```
group :development, :test do
  gem 'rubocop', require: false
  gem 'solargraph', require: false
end
```

`solargraph`を適用する

```
$ mkdir .vscode

$ vim .vscode/settings.json
```

```json
// settings.json
{
    "solargraph.useBundler": true,
    "solargraph.bundlerPath": "/Users/haryu/.rbenv/versions/3.0.0/bin/bundler",
    "ruby.useBundler": true,
    "ruby.lint": {
        "rubocop": true
    }
}
```

## debug tools

よりより開発ライフを行うために以下のgemを使いする

```rb
group :development, :test do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'
  gem 'pry-rails'
end
```

## slim

```rb
gem 'slim-rails'
gem 'html2slim'
```

```
$ bundle exec erb2slim app/views/layouts/ --delete
```

## generator files

`config/application.rb`ファイルを修正し、自動生成されるファイルを制限する

```rb
class Application < Rails::Application

   config.generators do |g|
     g.skip_routes true
     g.assets false
     g.helper false
   end
 end
```

## time zone

`config/application.rb`ファイルを修正し、タイムゾーンを設定する

```rb
config.time_zone = 'Tokyo'
config.active_record.default_timezone = :local
```

## bootstrap

bootstrapを適用するために必要なライブラリをインストール

```
$ yarn add jquery bootstrap @popperjs/core
```

bootstrap5の場合`@popperjs/core`が必要

### config/webpack/environment.js

次に、`config/webpack/environment.js`を以下のように編集する

```rb
const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery',
        Popper: ['popper.js', 'default']
    })
)

module.exports = environment
```

### css

`app/assets/stylesheets/application.scss`へとリネームをし、以下のように修正

```rb
 *= require bootstrap/dist/css/bootstrap.min.css
 *= require_tree .
 *= require_self
```

### application.js

`app/javascript/packs/application.js`へ以下の記述を追記

```js
import 'bootstrap/dist/js/bootstrap.min.js'
```

## font awesome

### ライブラリの追加

```
$ yarn add @fortawesome/fontawesome-free
```

### application.js

`app/javascript/packs/application.js`へ以下の記述を追記

```js
import '@fortawesome/fontawesome-free/js/all'
```

### application.sccs

以下を追記

```
$fa-font-path: '@fortawesome/fontawesome-free/webfonts';
@import '@fortawesome/fontawesome-free/scss/fontawesome';
@import '@fortawesome/fontawesome-free/scss/solid';
@import '@fortawesome/fontawesome-free/scss/regular';
@import '@fortawesome/fontawesome-free/scss/brands';
@import '@fortawesome/fontawesome-free/scss/v4-shims';
```

### how to

```rb
i.fas.fa-arrow-alt-circle-right
```

## flash messages

`application_controller`に以下を追記

```rb
add_flash_types :success, :info, :warning, :danger
```

次に、`shared/_flash_messages`ファイルを作成し、レンダリングする

```rb
- flash.each do |message_type, message|
  div class=("alert alert-#{message_type}") = message
```

`layouts/application.html.slim`

```rb
body
  = render 'shared/flash_messages'
  = yield
```

## error_messages

flash_messages同様error_messageパーシャルも作成する

`shared/_error_messages`

```
- if object.errors.any?
  #error_messages.alert-danger
    ul.mb-0
      - object.errors.full_messages.each do |msg|
        li= msg
```
