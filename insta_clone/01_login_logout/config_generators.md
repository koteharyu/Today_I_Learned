# generateコマンド時に生成されるファイルを制限する

## generateコマンドで生成されるファイル一覧

|コマンド|コントローラー|ビュー|モデル|マイグレーション|アセット|ルート|テスト|ヘルパー|
|-|-|-|-|-|-|-|-|-|
|scaffold|○|○|○|○|○|○|○|○|
|scaffold_controller|○|○|×|×|×|×|○|○|
|controller|○|○|×|×|○|○|○|○|
|model|×|×|○|○|×|×|○|×|
|migration|×|×|×|○|×|×|○|×|

## config.generatorsの設定

```
# config/application.rb

module MyProject
 class Application < Rails::Application
   config.i18n.default_locale = :ja
   config.time_zone = 'Asia/Tokyo'

     config.generators do |g|
       g.assets false          # CSS/JSファイルを生成しない
       g.skip_routes false     # trueなら routes.rbを変更する
       g.test_framework false  # テストファイルを作成しない
     end
 end
end
```

###

[参考](https://remonote.jp/rails-config-generators)