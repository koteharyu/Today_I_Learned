# chapter8 RailsとJavaScript

Railsアプリではデフォルトで`turbolinks`機能を有効にしているため、`window.onload`の代わりに`'turbolinks:load'`を使う

`'turbolinks:load'`とは、「ページの読込が完了したタイミング」で処理をするという意味。これがない場合、イベントハンドラの定義先となる要素がDOM上に存在せず、正しくイベントハンドラを設定することができなくなる

`イベントハンドラ`とは、ユーザーの入力に応じたイベントのこと。`mouseover(マウスが当たった時)`,`click(クリックされたとき)`,`keydown(キーが押されたとき)`などいろいろな種類がある

<br>

## AjaxでRailsサーバーと通信する

`Ajax`とは、Asynchronous JavaScript And XMLの頭文字。Webブラウザ上で非同期通信を行い、ページの再読み込み無しにページを更新するためのJavaScriptのプログラミング手法のこと

変更があったページの1部だけをサーバーから取得し、再読み込みに比べて格段にスムーズに表示される

<br>

<br>

## Turbolinks

`Turbolinks`とは、すべてのリンククリックに対するページ遷移を自動的にAjaxすることで高速化を図るRailsが提供するJavaScript機能の１つ

a要素のクリックイベントをフックして、遷移先のページをAjaxで取得する(同じオリジン(ドメイン)内に対するリンクに限る)。そして取得したページが要求するJavaScriptやCSSが現在の物と同一であれば現在のものをそのまま利用し、title要素やbody要素のみを置き換えたり、head要素をマージすることで、パフォーマンスを向上させる。リクエストごとにJavaScriptやCSSをブラウザが評価せずに済むため

title要素やbody要素のみを置き換えるだけなのでページ遷移は発生しないが、ブラウザの戻るボタンなどの履歴操作や、その際のキャッシュの復元にも対応している。

それは、HTML5のHistory APIが提供している

Turbolinksの特徴の１つにプレビュー機能がある。これは、１度訪れたことのあるページに再度訪問した際、前回のキャッシュを一旦表示してからリクエストを送信し、取得が完了したら新しいものに置き換えることで、見かけ上の画面遷移が一瞬で行われるためUXの向上に繋がる

ただ、キャッシュされた古い画面が一時的に表示されるに過ぎないことは意識しておくように

Turbolinksが対応しているHTTPリクエストメソッドはGETのみだが、POSTやPATCH、DELETEなどのリクエストでも、redirect_toによるリダイレクトの際には動作を最適化する。それ以外では、Turbolinksを導入していないときと同じ振る舞いをする

Turbolinksは、Railsとは独立したライブラリであることに注意

<br>

`turbolinks: load`イベントとは、初回のページ表示時やTurbolinksによりページの状態が遷移した際に発火するイベント(window.onloadの代わり)。このようなTurbolinks専用のイベントを使わないとJavaScriptを正しく動かすことができない。つまり、Turbolinksに依存したJavaScriptを書くようにする

<br>

`<script>`はhead要素内に記述する

`<script>`はhead要素内にもbod要素内にも記述することができるが、Turbolinksを利用しているときは、head要素内に記述するべき。

body要素内に記述してしまうと、あるページを新たに読み込んだ時だけでなく、リンククリックによってTurbolinksが画面の内容を更新する際にも、body要素の中身が評価され、その中にあるJavaScriptが評価されてしまうから

body要素内に記述するデメリット

- windowやdocumentなどのグローバルオブジェクトにイベントハンドラを追加するようなJavaScriptがbody要素内に記述されている場合、これらのオブジェクトはTurbolinksでページ遷移をしても同じオブジェクトが存在し続けているため、重複して処理される。(このような状況は、turbolinks: loadイベントを購読してその中でwindowなどにイベントハンドラを追加してしまったケースでも発生する)
- `<script>`で外部からJavaScriptファイルを取得していると、ページ遷移のたびにそれを評価してしまう。これでは、なるべく読込を減らすという効果を期待して利用しているはずのTurbolinksの高速化のメリットを打ち消してしまう

<br>

なので、`head`要素内にスクリプトを記述することで、ページ遷移で画面が更新される際の不要な読込や評価を発生させなくすることができる。

これは、head要素をマージするというTurbolinksの特徴があるから。ページ遷移先のhead要素内に新しい`<script>`があった場合だけ、そのタイミングで１回だけ評価する

<br>

Turbolinksを利用する際は、できるだけ、application.jsとapplication.cssを1つにまとめることが重要

ページごとに読み込むJSやCSSファイルが異なると、ページ遷移のたびに再読み込みが発生し、高速化の効果を十分に得られないから

<br>

Turbolinksを無効化する

Turbolinksは高速化というメリットはある反面、Turbolinksに合わせた開発が必要になるため、チームの方針によってはTurbolinksを無効化し開発する場合がある。

<br>

rails new時からTurbolinksを無効にする方法

`$ rails new app_name --skip-turbolinks`

<br>

Turbolinksが有効中のアプリを無効にする方法

1. Gemfileからの削除
2. マニュフェストファイルからのturbolinks読み込意処理の削除
  1. `//= require turbolinks` in `app/assets/javascripts/applicaiton.js`
3. `layouts/application.html.slim`などから、`'data-turbolinks-track':'reload'`属性を削除する

<br>

## モダンなJavaScript管理を行う

<br>

### Yarn

`Yarn`とは、JavaScriptのパッケージマネージャー。`npm`より高速に動作し、チェックサムを使ってライブラリの内容に予期せぬ変更が加わってないことを確認してくれるため、セキュリティが高い

`パッケージ`とは、ライブラリの公開単位で、コードなどのファイルをひとまとめにしたもの

`yarn.lock`とは、Gemfile.lockのようなバージョンロック機構であり、インストール結果に一貫性を持たせることが出来る

Yarnでパッケージを追加するには`$ bin/yarn add [パッケージ名]`、開発環境のみで利用するパッケージをインストールする際は`--dev`オプションを付与する

yarn add コマンドは次の２つの処理を行う

1. 指定されたパッケージを`package.json`に追加する
2. 指定されたパッケージをインストールする

`package.json`とは、買い物リストのようなもの。インストールする予定のパッケージを定義するファイル。

`依存パッケージ`とは、package.jsonに追加されたパッケージのこと。

インストールしたパッケージは`node_module`ディレクトリに配置される

`$ bin/yarn install`コマンドを実行することで、package.jsonに記述された依存パッケージを一括でインストールすることができる。インストールされたパッケージは恐らくyarn.lockに記述されるのであろう

`$ bin/yarn remove [パッケージ名]`コマンドでパッケージを削除することが出来る

<br>

## Webpacker

`webpacker`とは、JavaScriptのビルドツールWebpackのラッパーであり、JavaScriptを管理するためのGem

Rails標準のJavaScriptの管理ツールである、`Sprockets`と解決しようとしている領域は似ている

JavaScriptの管理を`webpacker`と`Sprockets`のどちらで行うかを選ぶ必要がある

以下のニーズがあれば、Webpackerで管理したほうがいいかも

- ES2015以降の仕様で書いたJavaScriptを、現在普及しているブラウザに互換性のある形で配信したい。これにより、対応するブラウザを狭めることなく、最新のES2015以降の記法で書いたり、モジュール機能でJavaScriptのスコープを制御できるようになる
- JavaScriptのビルドプロセスを柔軟にカスタマイズしたい

<br>

`Webpacker`の特徴

1. WebpackのコマンドをRakeタスクでラップして提供
2. BabelによるES2015コードのコンパイル
3. React/Vue.js/Angularなどのサポート
4. Rails用のビューヘルパーの提供

`webpack-dev-server`コマンドで、ファイルの変更を検知して自動ビルドする

<br>

導入方法

`--webpack`オプションを指定することで、新規作成時にwebpacker gemをインストールできる

既存のアプリにWebpackerを導入するには

1. `gem 'webpacker'`を追加
2. Webpackerはパッケージ管理にYarnを採用しているため、Yarnのインストールが必須
3. `$ bin/rails webpacker:install` コマンドで、`app/javascript/packs/application.js`というエントリポイントが作成される

`エントリポイント`とは、コンパイルを開始するファイルのこと。コンパイルの結果、生成されるファイルに対応する存在(Sprocketsでいうマニュフェストファイル)

読み込ますファイルは、`app/javascript`配下の他のディレクトリに置き、エントリーポイントには置かないように！

`javascript_pack_tag 'application'`に変更する(javascript_include_tagの代わりに)in app/views/layouts/application.html.slim

<br>

コンパイルの実行

開発環境において、Webpacker管理下のファイルに更新があれば、Railsサーバーへのリクエストのタイミングで自動的にコンパイルが行われる。が、多少のもたつきがあるかも

その場合は、開発中に`bin/webpack-dev-server`を立ち上げておくとJavaScriptファイルの更新のたびにコンパイルを行い、必要に応じてブラウザ上で開いている画面の更新を行ってくれるので速い

本番環境のためのコンパイルは`webpacker:compile`というRakeタスクで行う

Sprocektsを導入している場合、このタスクはSprocektsのアセットプリコンパイルのタスク`assets:precompile`の前に実行されるので、従来どおり、`assets:precompile`を実行すればよい

各環境で、どのようにコンパイルするかの設定は、`config/webpacker.yml`で行う

<br>

## taskleafにReactを導入

`React`とは、仮想DOMと呼ばれるデータ構造をメモリ上に持ち、ページ変化の差分のみをレンダリングすることで効率的にページを表示・更新することができる特徴を持つ

`$ bin/yarn add react react-dom`コマンドを実行

ブラウザ上で実行するには`ReactDOM`が必要なため

```
# app/javascript/taskleaf/hello.js

import React from 'react';
import ReactDOM from 'react-dom';

document.addEventListener('DOMContentLoaded' () => {
 ReactDOM.reader(
   React.createElement('div', null, 'Hello World!'),
   document.body.appendChild(document.createElement('div')),
 );
});
```

`import`とは、ES2015のimport文であり、他のモジュール(ファイル)から`export`されたオブジェクトを読み込むために使う

```
# app/javascript/packs/application.js

import 'taskleaf/hello';
```

タスク一覧などをブラウザで表示した際に、'Hello World!'と表示されれば成功！