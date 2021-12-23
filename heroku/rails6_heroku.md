# error: failed to push some refs to

## platformによるエラー

```
git push heroku develop:master
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
remote: Compressing source files... done.
remote: Building source:
remote:
remote: -----> Building on the Heroku-20 stack
remote: -----> Determining which buildpack to use for this app
remote:  !     Warning: Multiple default buildpacks reported the ability to handle this app. The first buildpack in the list below will be used.
remote:                         Detected buildpacks: Ruby,Node.js
remote:                         See https://devcenter.heroku.com/articles/buildpacks#buildpack-detect-order
remote: -----> Ruby app detected
remote: -----> Installing bundler 2.2.21
remote: -----> Removing BUNDLED WITH version in the Gemfile.lock
remote: -----> Compiling Ruby/Rails
remote: -----> Using Ruby version: ruby-3.0.0
remote: -----> Installing dependencies using bundler 2.2.21
remote:        Running: BUNDLE_WITHOUT='development:test' BUNDLE_PATH=vendor/bundle BUNDLE_BIN=vendor/bundle/bin BUNDLE_DEPLOYMENT=1 bundle install -j4
remote:        Your bundle only supports platforms ["arm64-darwin-20"] but your local platform
remote:        is x86_64-linux. Add the current platform to the lockfile with `bundle lock
remote:        --add-platform x86_64-linux` and try again.
remote:        Bundler Output: Your bundle only supports platforms ["arm64-darwin-20"] but your local platform
remote:        is x86_64-linux. Add the current platform to the lockfile with `bundle lock
remote:        --add-platform x86_64-linux` and try again.
remote:
remote:  !
remote:  !     Failed to install gems via Bundler.
remote:  !
remote:  !     Push rejected, failed to compile Ruby app.
remote:
remote:  !     Push failed
remote: Verifying deploy...
remote:
remote: !       Push rejected to basic-by.
remote:
To https://git.heroku.com/basic-by.git
 ! [remote rejected] develop -> master (pre-receive hook declined)
error: failed to push some refs to 'https://git.heroku.com/basic-by.git'
```

`$ bundle lock --add-platform x86_64-linux`

このエラーは解決

## spring-commands-rspec

```
remote:  !
remote:  !     Could not detect rake tasks
remote:  !     ensure you can run `$ bundle exec rake -P` against your app
remote:  !     and using the production group of your Gemfile.
remote:  !     /tmp/build_02f98366/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/dependency.rb:307:in `to_specs': Could not find 'spring' (= 3.0.0) among 184 total gem(s) (Gem::MissingSpecError)
remote:  !     Checked in 'GEM_PATH=/tmp/build_02f98366/vendor/bundle/ruby/3.0.0' , execute `gem env` for more information
remote:  !     from /tmp/build_02f98366/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/dependency.rb:319:in `to_spec'
remote:  !     from /tmp/build_02f98366/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/core_ext/kernel_gem.rb:62:in `gem'
remote:  !     from /tmp/build_02f98366/bin/spring:14:in `<top (required)>'
remote:  !     from /tmp/build_02f98366/bin/rake:2:in `load'
remote:  !     from /tmp/build_02f98366/bin/rake:2:in `<main>'
remote:  !

remote:  !     Push rejected, failed to compile Ruby app.
remote:
remote:  !     Push failed
remote: Verifying deploy...
remote:
remote: !       Push rejected to peaceful-escarpment-36805.
remote:
To https://git.heroku.com/peaceful-escarpment-36805.git
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'https://git.heroku.com/peaceful-escarpment-36805.git'
```

`spring-commands-rspec`のgemを削除し`$ bundle exec spring binstub rspe`コマンドを実行する前の状態に戻すことで解決

## Precompiling assets failed.

```
remote:        rake aborted!
remote:        Sprockets::ArgumentError: link_tree argument must be a directory
remote:        /tmp/build_ed88c512/app/assets/config/manifest.js:1
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0.2/lib/sprockets/directive_processor.rb:389:in `expand_relative_dirname'
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0.2/lib/sprockets/directive_processor.rb:341:in `process_link_tree_directive'
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0.2/lib/sprockets/directive_processor.rb:189:in `block in process_directives'
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0.2/lib/sprockets/directive_processor.rb:187:in `each'
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0.2/lib/sprockets/directive_processor.rb:187:in `process_directives'
remote:        /tmp/build_ed88c512/vendor/bundle/ruby/3.0.0/gems/sprockets-4.0
...
remote:  !
remote:  !     Precompiling assets failed.
remote:  !
remote:  !     Push rejected, failed to compile Ruby app.
remote:
remote:  !     Push failed
remote: Verifying deploy...
remote:
```

`$ be rails assets:precompile`を実行しても特に異常なし

次に、`initializers/assets.rb`をいじってみる

かわらず。戻す

次に`app/assets/config/manifest.js`をいじってみる

```js
デフォルト
//= link_tree ../images
//= link_directory ../stylesheets .css

いじり後
//= link_tree ../images
//= link_directory ../stylesheet
```

かわらず

確かにエラーログには`Sprockets::ArgumentError: link_tree argument must be a directory`と言われてるからいじった方は関係ないのか

なら次にエラーログ通り`link_tree`をいじってみる

修正後

```js
//= link_directory ../stylesheet .scss
```

ようやく`$ git push heroku master`が成功！


## と思いきや

We're sorry, but something went wrong.
If you are the application owner check the logs for more information.エラーがあり、`heroku logs -t`でログを見てみると...

```
Could not detect rake tasks
 !     ensure you can run `$ bundle exec rake -P` against your app
 !     and using the production group of your Gemfile.
 !     /tmp/build_b5129ccd/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/dependency.rb:307:in `to_specs': Could not find 'spring' (= 3.0.0) among 184 total gem(s) (Gem::MissingSpecError)
 !     Checked in 'GEM_PATH=/tmp/build_b5129ccd/vendor/bundle/ruby/3.0.0' , execute `gem env` for more information
 !     from /tmp/build_b5129ccd/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/dependency.rb:319:in `to_spec'
 !     from /tmp/build_b5129ccd/vendor/ruby-3.0.0/lib/ruby/3.0.0/rubygems/core_ext/kernel_gem.rb:62:in `gem'
 !     from /tmp/build_b5129ccd/bin/spring:14:in `<top (required)>'
 !     from /tmp/build_b5129ccd/bin/rake:2:in `load'
 !     from /tmp/build_b5129ccd/bin/rake:2:in `<main>'
```

とな。

一度先ほど作成した`group production`Gemfileから消してみることに。

`git push heroku master`には成功したが、we're sorry...

heroku logを見てみる

さっきは気づかなかったけど、もしかして``to_specs': Could not find 'spring' (= 3.0.0) among 184 total gem(s) (Gem::MissingSpecError)`この記述の方が大事なのでは？？

ということで、gemfileから`sprign`も消してみることに

[参考](https://github.com/rails/rails/issues/40911)

1. Rails6.0の時は動いていたけど、Rails6.1になったタイミングでbin/rspecのようなbin/*系の動作ができなくなった
2. springが原因でGem::MissingSpecErrorによるエラー
3. Railsの変更により前はbin/rails、bin/rakeに含まれていたguard句が削除されている
4. 発生したLoadErrorをrescueするguard句をbin/springに追加した結果、正常に動作


でもまだ`we are sorry`次は何？？？？

ログはこんな感じ

```
2021-11-17T07:14:27.283708+00:00 heroku[router]: at=info method=GET path="/" host=peaceful-escarpment-36805.herokuapp.com request_id=5f175ace-0970-485e-9a4b-46bf8efb98ce fwd="114.156.152.229" dyno=web.1 connect=0ms service=24ms status=500 bytes=1827 protocol=http
2021-11-17T07:14:27.261396+00:00 app[web.1]: I, [2021-11-17T07:14:27.261326 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce] Started GET "/" for 114.156.152.229 at 2021-11-17 07:14:27 +0000
2021-11-17T07:14:27.262212+00:00 app[web.1]: I, [2021-11-17T07:14:27.262156 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce] Processing by PostsController#index as HTML
2021-11-17T07:14:27.277652+00:00 app[web.1]: I, [2021-11-17T07:14:27.277578 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce]   Rendered posts/index.html.slim within layouts/application (Duration: 7.2ms | Allocations: 363)
2021-11-17T07:14:27.281420+00:00 app[web.1]: I, [2021-11-17T07:14:27.281360 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce]   Rendered layout layouts/application.html.slim (Duration: 11.0ms | Allocations: 2450)
2021-11-17T07:14:27.281675+00:00 app[web.1]: I, [2021-11-17T07:14:27.281637 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce] Completed 500 Internal Server Error in 19ms (ActiveRecord: 5.8ms | Allocations: 2992)
2021-11-17T07:14:27.283358+00:00 app[web.1]: F, [2021-11-17T07:14:27.283315 #4] FATAL -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce]
2021-11-17T07:14:27.283359+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce] ActionView::Template::Error (The asset "application.css" is not present in the asset pipeline.
2021-11-17T07:14:27.283360+00:00 app[web.1]: ):
2021-11-17T07:14:27.283360+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      6:     meta[name="viewport" content="width=device-width,initial-scale=1"]
2021-11-17T07:14:27.283361+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      7:     = csrf_meta_tags
2021-11-17T07:14:27.283361+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      8:     = csp_meta_tag
2021-11-17T07:14:27.283362+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      9:     = stylesheet_link_tag 'application', media: 'all'
2021-11-17T07:14:27.283362+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     10:     = javascript_pack_tag 'application'
2021-11-17T07:14:27.283363+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     11:   body
2021-11-17T07:14:27.283363+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     12:     - if logged_in?
2021-11-17T07:14:27.283364+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]
2021-11-17T07:14:27.283364+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce] app/views/layouts/application.html.slim:9
2021-11-17T07:14:27.557012+00:00 heroku[router]: at=info method=GET path="/favicon.ico" host=peaceful-escarpment-36805.herokuapp.com request_id=bd6f0e3b-bee2-462e-b6a2-c6a016bf60fa fwd="114.156.152.229" dyno=web.1 connect=0ms service=1ms status=304 bytes=48 protocol=http
```

`ActionView::Template::Error (The asset "application.css" is not present in the asset pipeline.`これ怪しそう

`config/environments/production`

```rb
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

↓

config.public_file_server.enabled = true
```

本来は環境変数に設定した方がいいが簡略してみた。

結果...ダメー（布川）

次は

```rb
#config.assets.compile = false
config.assets.compile = true
```

これを試してみるも未だwe are sorry...

```
現在のheroku logs

 heroku logs -t
2021-11-17T07:14:27.281420+00:00 app[web.1]: I, [2021-11-17T07:14:27.281360 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce]   Rendered layout layouts/application.html.slim (Duration: 11.0ms | Allocations: 2450)
2021-11-17T07:14:27.281675+00:00 app[web.1]: I, [2021-11-17T07:14:27.281637 #4]  INFO -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce] Completed 500 Internal Server Error in 19ms (ActiveRecord: 5.8ms | Allocations: 2992)
2021-11-17T07:14:27.283358+00:00 app[web.1]: F, [2021-11-17T07:14:27.283315 #4] FATAL -- : [5f175ace-0970-485e-9a4b-46bf8efb98ce]
2021-11-17T07:14:27.283359+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce] ActionView::Template::Error (The asset "application.css" is not present in the asset pipeline.
2021-11-17T07:14:27.283360+00:00 app[web.1]: ):
2021-11-17T07:14:27.283360+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      6:     meta[name="viewport" content="width=device-width,initial-scale=1"]
2021-11-17T07:14:27.283361+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      7:     = csrf_meta_tags
2021-11-17T07:14:27.283361+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      8:     = csp_meta_tag
2021-11-17T07:14:27.283362+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]      9:     = stylesheet_link_tag 'application', media: 'all'
2021-11-17T07:14:27.283362+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     10:     = javascript_pack_tag 'application'
2021-11-17T07:14:27.283363+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     11:   body
2021-11-17T07:14:27.283363+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]     12:     - if logged_in?
2021-11-17T07:14:27.283364+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce]
2021-11-17T07:14:27.283364+00:00 app[web.1]: [5f175ace-0970-485e-9a4b-46bf8efb98ce] app/views/layouts/application.html.slim:9
2021-11-17T07:14:27.283708+00:00 heroku[router]: at=info method=GET path="/" host=peaceful-escarpment-36805.herokuapp.com request_id=5f175ace-0970-485e-9a4b-46bf8efb98ce fwd="114.156.152.229" dyno=web.1 connect=0ms service=24ms status=500 bytes=1827 protocol=http
2021-11-17T07:14:27.557012+00:00 heroku[router]: at=info method=GET path="/favicon.ico" host=peaceful-escarpment-36805.herokuapp.com request_id=bd6f0e3b-bee2-462e-b6a2-c6a016bf60fa fwd="114.156.152.229" dyno=web.1 connect=0ms service=1ms status=304 bytes=48 protocol=http
2021-11-17T07:26:56.000000+00:00 app[api]: Build started by user hryau6@gmail.com
2021-11-17T07:27:51.758481+00:00 app[api]: Deploy 0e1ac9fd by user hryau6@gmail.com
2021-11-17T07:27:51.758481+00:00 app[api]: Release v9 created by user hryau6@gmail.com
2021-11-17T07:27:52.476781+00:00 heroku[web.1]: Restarting
2021-11-17T07:27:52.489707+00:00 heroku[web.1]: State changed from up to starting
2021-11-17T07:27:53.116493+00:00 heroku[web.1]: Stopping all processes with SIGTERM
2021-11-17T07:27:53.154426+00:00 app[web.1]: - Gracefully stopping, waiting for requests to finish
2021-11-17T07:27:53.155085+00:00 app[web.1]: Exiting
2021-11-17T07:27:53.295893+00:00 heroku[web.1]: Process exited with status 143
2021-11-17T07:27:59.000000+00:00 app[api]: Build succeeded
2021-11-17T07:28:04.782230+00:00 heroku[web.1]: Starting process with command `bin/rails server -p ${PORT:-5000} -e production`
2021-11-17T07:28:09.678665+00:00 app[web.1]: => Booting Puma
2021-11-17T07:28:09.678677+00:00 app[web.1]: => Rails 6.1.4.1 application starting in production
2021-11-17T07:28:09.678677+00:00 app[web.1]: => Run `bin/rails server --help` for more startup options
2021-11-17T07:28:11.462686+00:00 app[web.1]: Puma starting in single mode...
2021-11-17T07:28:11.462750+00:00 app[web.1]: * Puma version: 5.5.2 (ruby 3.0.0-p0) ("Zawgyi")
2021-11-17T07:28:11.462767+00:00 app[web.1]: *  Min threads: 5
2021-11-17T07:28:11.462801+00:00 app[web.1]: *  Max threads: 5
2021-11-17T07:28:11.462819+00:00 app[web.1]: *  Environment: production
2021-11-17T07:28:11.462838+00:00 app[web.1]: *          PID: 4
2021-11-17T07:28:11.463221+00:00 app[web.1]: * Listening on http://0.0.0.0:45191
2021-11-17T07:28:11.487572+00:00 app[web.1]: Use Ctrl-C to stop
2021-11-17T07:28:12.071857+00:00 heroku[web.1]: State changed from starting to up
2021-11-17T07:29:15.077341+00:00 app[web.1]: I, [2021-11-17T07:29:15.077253 #4]  INFO -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d] Started GET "/" for 114.156.152.229 at 2021-11-17 07:29:15 +0000
2021-11-17T07:29:15.087582+00:00 app[web.1]: I, [2021-11-17T07:29:15.087492 #4]  INFO -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d] Processing by PostsController#index as HTML
2021-11-17T07:29:15.327109+00:00 app[web.1]: I, [2021-11-17T07:29:15.326984 #4]  INFO -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d]   Rendered posts/index.html.slim within layouts/application (Duration: 23.4ms | Allocations: 14179)
2021-11-17T07:29:15.338904+00:00 app[web.1]: I, [2021-11-17T07:29:15.338840 #4]  INFO -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d]   Rendered layout layouts/application.html.slim (Duration: 35.3ms | Allocations: 21544)
2021-11-17T07:29:15.339426+00:00 app[web.1]: I, [2021-11-17T07:29:15.339375 #4]  INFO -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d] Completed 500 Internal Server Error in 252ms (ActiveRecord: 117.4ms | Allocations: 28954)
2021-11-17T07:29:15.340717+00:00 app[web.1]: F, [2021-11-17T07:29:15.340671 #4] FATAL -- : [4cb7227f-642a-4326-aeb0-63633ce8bb8d]
2021-11-17T07:29:15.340718+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d] ActionView::Template::Error (The asset "application.css" is not present in the asset pipeline.
2021-11-17T07:29:15.340719+00:00 app[web.1]: ):
2021-11-17T07:29:15.340720+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]      6:     meta[name="viewport" content="width=device-width,initial-scale=1"]
2021-11-17T07:29:15.340720+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]      7:     = csrf_meta_tags
2021-11-17T07:29:15.340720+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]      8:     = csp_meta_tag
2021-11-17T07:29:15.340721+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]      9:     = stylesheet_link_tag 'application', media: 'all'
2021-11-17T07:29:15.340721+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]     10:     = javascript_pack_tag 'application'
2021-11-17T07:29:15.340722+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]     11:   body
2021-11-17T07:29:15.340722+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]     12:     - if logged_in?
2021-11-17T07:29:15.340723+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d]
2021-11-17T07:29:15.340723+00:00 app[web.1]: [4cb7227f-642a-4326-aeb0-63633ce8bb8d] app/views/layouts/application.html.slim:9
2021-11-17T07:29:15.341982+00:00 heroku[router]: at=info method=GET path="/" host=peaceful-escarpment-36805.herokuapp.com request_id=4cb7227f-642a-4326-aeb0-63633ce8bb8d fwd="114.156.152.229" dyno=web.1 connect=0ms service=291ms status=500 bytes=1827 protocol=https
2021-11-17T07:29:15.729551+00:00 heroku[router]: at=info method=GET path="/favicon.ico" host=peaceful-escarpment-36805.herokuapp.com request_id=076bb093-9acf-4545-bf56-54fa5e1bcccd fwd="114.156.152.229" dyno=web.1 connect=0ms service=3ms status=200 bytes=143 protocol=https
2021-11-17T08:03:24.490617+00:00 heroku[web.1]: Idling
2021-11-17T08:03:24.542629+00:00 heroku[web.1]: State changed from up to down
2021-11-17T08:03:25.609786+00:00 heroku[web.1]: Stopping all processes with SIGTERM
2021-11-17T08:03:25.707823+00:00 app[web.1]: - Gracefully stopping, waiting for requests to finish
2021-11-17T08:03:25.717816+00:00 app[web.1]: Exiting
2021-11-17T08:03:25.896987+00:00 heroku[web.1]: Process exited with status 143
2021-11-18T02:26:44.000000+00:00 app[api]: Build started by user hryau6@gmail.com
2021-11-18T02:27:39.727650+00:00 app[api]: Release v10 created by user hryau6@gmail.com
2021-11-18T02:27:39.727650+00:00 app[api]: Deploy beeb2f04 by user hryau6@gmail.com
2021-11-18T02:27:41.191277+00:00 heroku[web.1]: State changed from down to starting
2021-11-18T02:27:45.000000+00:00 app[api]: Build succeeded
2021-11-18T02:27:47.150953+00:00 heroku[web.1]: Starting process with command `bin/rails server -p ${PORT:-5000} -e production`
2021-11-18T02:27:50.378060+00:00 app[web.1]: => Booting Puma
2021-11-18T02:27:50.378073+00:00 app[web.1]: => Rails 6.1.4.1 application starting in production
2021-11-18T02:27:50.378073+00:00 app[web.1]: => Run `bin/rails server --help` for more startup options
2021-11-18T02:27:51.724015+00:00 app[web.1]: Puma starting in single mode...
2021-11-18T02:27:51.724072+00:00 app[web.1]: * Puma version: 5.5.2 (ruby 3.0.0-p0) ("Zawgyi")
2021-11-18T02:27:51.724088+00:00 app[web.1]: *  Min threads: 5
2021-11-18T02:27:51.724102+00:00 app[web.1]: *  Max threads: 5
2021-11-18T02:27:51.724118+00:00 app[web.1]: *  Environment: production
2021-11-18T02:27:51.724136+00:00 app[web.1]: *          PID: 4
2021-11-18T02:27:51.724413+00:00 app[web.1]: * Listening on http://0.0.0.0:17968
2021-11-18T02:27:51.732586+00:00 app[web.1]: Use Ctrl-C to stop
2021-11-18T02:27:52.285666+00:00 heroku[web.1]: State changed from starting to up
2021-11-18T02:28:24.933796+00:00 app[web.1]: I, [2021-11-18T02:28:24.933692 #4]  INFO -- : [ad705ab4-f659-42f6-bf74-fda039f89a20] Started GET "/" for 103.5.140.180 at 2021-11-18 02:28:24 +0000
2021-11-18T02:28:24.940322+00:00 app[web.1]: I, [2021-11-18T02:28:24.940234 #4]  INFO -- : [ad705ab4-f659-42f6-bf74-fda039f89a20] Processing by PostsController#index as HTML
2021-11-18T02:28:25.140584+00:00 app[web.1]: I, [2021-11-18T02:28:25.140485 #4]  INFO -- : [ad705ab4-f659-42f6-bf74-fda039f89a20]   Rendered posts/index.html.slim within layouts/application (Duration: 31.3ms | Allocations: 14179)
2021-11-18T02:28:26.299923+00:00 heroku[router]: at=info method=GET path="/" host=peaceful-escarpment-36805.herokuapp.com request_id=ad705ab4-f659-42f6-bf74-fda039f89a20 fwd="103.5.140.180" dyno=web.1 connect=0ms service=1379ms status=500 bytes=1827 protocol=https
2021-11-18T02:28:26.300765+00:00 app[web.1]: I, [2021-11-18T02:28:26.300692 #4]  INFO -- : [ad705ab4-f659-42f6-bf74-fda039f89a20]   Rendered layout layouts/application.html.slim (Duration: 1191.7ms | Allocations: 80262)
2021-11-18T02:28:26.300987+00:00 app[web.1]: I, [2021-11-18T02:28:26.300956 #4]  INFO -- : [ad705ab4-f659-42f6-bf74-fda039f89a20] Completed 500 Internal Server Error in 1361ms (ActiveRecord: 125.7ms | Allocations: 87671)
2021-11-18T02:28:26.301648+00:00 app[web.1]: F, [2021-11-18T02:28:26.301615 #4] FATAL -- : [ad705ab4-f659-42f6-bf74-fda039f89a20]
2021-11-18T02:28:26.301648+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20] ActionView::Template::Error (application.css):
2021-11-18T02:28:26.301649+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]      6:     meta[name="viewport" content="width=device-width,initial-scale=1"]
2021-11-18T02:28:26.301650+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]      7:     = csrf_meta_tags
2021-11-18T02:28:26.301650+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]      8:     = csp_meta_tag
2021-11-18T02:28:26.301650+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]      9:     = stylesheet_link_tag 'application', media: 'all'
2021-11-18T02:28:26.301651+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]     10:     = javascript_pack_tag 'application'
2021-11-18T02:28:26.301651+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]     11:   body
2021-11-18T02:28:26.301652+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]     12:     - if logged_in?
2021-11-18T02:28:26.301652+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20]
2021-11-18T02:28:26.301653+00:00 app[web.1]: [ad705ab4-f659-42f6-bf74-fda039f89a20] app/views/layouts/application.html.slim:9
2021-11-18T02:28:26.672073+00:00 heroku[router]: at=info method=GET path="/favicon.ico" host=peaceful-escarpment-36805.herokuapp.com request_id=d5d4af83-337c-4b96-b74e-51900d1df17b fwd="103.5.140.180" dyno=web.1 connect=0ms service=2ms status=200 bytes=143 protocol=https
```

`ActionView::Template::Error`は解決しなかったので、以下を試す

プリコンパイルを実施

```
$ rails tmp:cache:clear
$ rails assets:precompile
```

```
$ rails assets:precompile
...
WARNING in asset size limit: The following asset(s) exceed the recommended size limit (244 KiB).
This can impact web performance.
Assets:
  js/application-1f3ad2dd0d99a75f59c6.js (367 KiB)
  js/application-1f3ad2dd0d99a75f59c6.js.map.gz (376 KiB)
  js/application-1f3ad2dd0d99a75f59c6.js.map.br (316 KiB)

WARNING in entrypoint size limit: The following entrypoint(s) combined asset size exceeds the recommended limit (244 KiB). This can impact web performance.
Entrypoints:
  application (367 KiB)
      js/application-1f3ad2dd0d99a75f59c6.js


WARNING in webpack performance recommendations:
You can limit the size of your bundles by using import() or require.ensure to lazy load some parts of your application.
For more info visit https://webpack.js.org/guides/code-splitting/
```

変化なし

```
= stylesheeet_pack_tag 'application'
```

でやってみる

[行けると思ったんだけなあ](https://qiita.com/tatsurou313/items/645cbf0a3af4c673b5df#webpacker-%E3%81%8C%E3%83%90%E3%83%B3%E3%83%89%E3%83%AB%E3%81%97%E3%81%9F-javascript-css-%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92-rails-%E3%81%8B%E3%82%89%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%82%80%E6%96%B9%E6%B3%95)

<br>

users.avatarのデフォルトURLを変更し、`public/images`配下に配置。なおgitignoreからはずす

stylesheet_link_tagに戻す

manifest.jsをcssに戻す

できた！！
