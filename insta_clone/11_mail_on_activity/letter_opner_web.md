# letter_opner_web gemについて

letter_opner_webとは、railsの開発環境で送信したメールをブラウザで簡単に確認するためのgem

## Gemfile

developmentグループ内にgemを記述

```
# Gemfile

group :development do
 gem 'letter_opner_web'
end
```

## Routing

`/letter_opner`というパスで確認できるようにするために、`LetterOpnerWeb::Engine`をマウントする

```
# routesrb

//一番最後の行に

mount LetterOpnerWeb::Engine, at: '/letter_opner' if Rails.env.development?
```

## Config

config/environments/development.rb内にletter_opnerについての設定を追記する

```
# config/environments/development.rb

Rasils.application.configure do

 config.action_mailer.default_url_options = { host: 'localhost:3000' }
 config.action_mailer.delivery_method = :letter_opner_web

end
```

## 確認

'http://localhost:3000/letter_opner'へGO!

[公式](https://github.com/fgrehm/letter_opener_web)

[letter_opener_webを使用して送信メールを確認する](https://remonote.jp/rails-letter-opener-web-mail)

[Ruby on Rails の 開発環境で 簡単にメール送信機能の確認ができる letter_opener_web の使い方](https://qiita.com/Atelier-Mirai/items/3e272f23eda6b002e9ed)
