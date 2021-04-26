## config/application.rbとは

アプリ全体の設定を記述するファイル。タイムゾーンの設定や、デフォルトで使用するロケール、アプリ起動時に読み込むディレクトリなどを指定する

```
module InstaClone
 class Application < Rails::Application
   config.generators.system_tests = nil

   config.generators do |g|
     g.skip_routes true
     g.assets false
     g.helper false
   end
 end
end
```
の、ように記述することで、generateコマンド時に生成されるファイルを制限することができる(ルーティング、JS、CSS、テストが自動生成されない)

### Time.currentとTime.nowの違い

`Time.current`とは、Railsの独自のメソッドで、TimeWithZoneクラスを使用している。`config.time_zone`で設定したタイムゾーンを元に現在時刻を取得する

`Time.now`とは、Rubyのメソッドで、Timeクラスを使用している。環境変数`TZ`の値、無ければシステム(OS)のタイムゾーンを元に現在時刻を取得する

[application.rbの初期設定](https://blog.cloud-acct.com/posts/u-rails-applicationrb-settings/)
