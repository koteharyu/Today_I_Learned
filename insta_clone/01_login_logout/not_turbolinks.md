`$ rails new app_name --skip-turbolinks`

<br>

Turbolinksが有効中のアプリを無効にする方法

1. Gemfileからの削除
2. マニュフェストファイルからのturbolinks読み込意処理の削除
  1. `//= require turbolinks` in `app/assets/javascripts/applicaiton.js`
3. `layouts/application.html.slim`などから、`'data-turbolinks-track':'reload'`属性を削除する

<br>

## Turbolinksとは

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