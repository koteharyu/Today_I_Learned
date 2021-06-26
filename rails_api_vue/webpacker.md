# Webpackerとは

## webpackerとは

webpacker...汎用的なwebpackビルドシステムのRailsラッパーであり、標準的なwebpackの設定と合理的なデフォルト設定を提供するもの

## では、Webpackとは何か

Webpack...フロントエンドビルドシステムのこと。

webpckなどのフロントエンドビルドシステムの目的は、開発者にとって使いやすい方法でフロントエンドのコードを書き、そのコードをブラウザで使用しやすい方法でパッケージ化すること。Webpackは「JavaScript」「CSS」「画像やフォント」などの静的アセットを管理できる。Webpackを使うと、「JavaScriptコードの記述」「アプリケーション内の他のコードの参照」「コードの交換(トランスパイル)や統合」をダウンロードしやすいpackにまとめてくれる

## WebpackerとSProcketsとの違い

`minify`...JavaScript, CSSのアセットの行間やスペースを詰めることで最小化すること

`フィンガープリント`...アセットファイルに挿入し、ブラウザ側でキャッシュしてもらうための添字

`NPMレジストリ`...Node.jsとブラウザランタイムの両方で、主にオープンソースのJavaScriptプロジェクトの公開や、ダウンロードに使われるリポジトリのこと

`ブラウザランタイム`...ブラウザ上でプログラムが実行される時。または、実行されるプログラムライブラリやプログラム群のこと

どちらともアセットパーケージングツールであり、JavaScriptをブラウザに適したファイルにコンパイルすることで、production環境でのminifyやフィンガープリント追加ができる。また、development環境でファイルをインクリメンタルに変更できる点も同じである。

では、WebpackerとSProcketsにはどのような違いがあるのか

- Sprockets...Railsで使われる前提で設計されているため、統合方法はWebpackerよりもシンプルで、Ruby gemを用いてSprocketsにコードを追加できる。「移行にコストが費かるレガシーアプリケーション」「gemで統合したい場合」「パッケージ化するコードの量が非常に少ない場合」などに有効
- Webpacker...新しいJavaScriptツールやNPMパッケージとの統合に優れており、より多くのものを統合できる。「NPMパッケージを使いたい場合」「最新のJavaScript機能やツールにアクセスしたい場合」に有効

<br>

変更早見表

|タスク|Sprockets|Webpacker|
|-|-|-|
|JavaScriptをアタッチする|javascript_include_tag|javascript_pack_tag|
|CSSをアタッチする|stylesheet_link_tag|stylesheet_pack_tag|
|画像にリンクする|image_url|image_pack_tag|
|アセットにリンクする|asset_url|asset_pack_tag|
|スクリプトをrequireする|//= require|import または require|

<br>

## webpackerのインストール

webpackerを使うには、Yarnパッケージマネージャ(1.x以上)とNode.js(10.13.0)以上のインストールが必要

`yarn`...JavaScriptのパッケージマネージャーのこと。npmとの互換性もある

`node.js`...サーバーサイドで動くJavaScriptのこと。本来のJavaScriptはクライアントサイドで動く言語

WebpackerはRails6.0以降だとデフォルトでインストールされる。

もしデフォルトで入っていない場合は、`rails new --webpack`と指定することで、Webpackerをプロジェクトにインストールできる。既存のプロジェクトにwebpackerをインストールする際は、`bin/rails webpacker:install`コマンドを実行すれば良い。

webpackerが導入された際に作成されるファイル・フォルダ

|ファイルとフォルダ|場所|説明|
|-|-|-|
|JavaScript|app/javascript|フロントエンド向けJavaScriptソースコードの置き場所|
|webpacker設定ファイル|config/webpacker.yml|webpacker gem を設定する|
|Babel設定ファイル|babel.config.js|Babel(JavaScriptコンパイラ)の設定|
|PostCSS設定ファイル|postcss.config.js|PostCSS(CSSポストプロセッサ)の設定|
|Browserlistファイル|.browserlistrc|Browserlist(対象ブラウザを管理する)設定|

`Babel`...次世代のJavaScriptの標準機能をブラウザのサポートを待たずに使えるようにするNode.js製のツールのこと。新しいJSで書かれたコードをサポートしていないブラウザ向けにコードを書き換えてくれる

`PostCSS`...Node.js製のCSSツールを作成するためのフレームワークのこと。PostCSSのメリットは、一連のCSSのビルドフローを全てPostCSSのエコシステムで解決できること。また、Sass,Less,Stylusとも併用が可能。らしいがまだよくわからん。[復習だ](https://qiita.com/morishitter/items/4a04eb144abf49f41d7d)

<br>

## JavaScript * Webpacker

Webpackerをインストールすると、デフォルトでは`app/javascript/packs`ディレクトリ以下のJSファイルがコンパイルされて独自のpackファイルにまとめられる

`app/javascript/packs/application.js`というファイルがある場合、Webpackerは`application`という名前のpackを作成する。このpackは、`<%= javascript_pack_tag "application"%>`というerbコードが使われているRailsアプリケーションで追加される

基本的に、`app/javascript/packs`ディレクトリ配下には、Webpackerのエントリーファイルだけを置くようにする。エントリーファイル内に他のファイルをimportする感じ

## CSS * Webpacker

Webpackerでは、PostCSSプロセッサを用いてCSSやSCSSのサポートを即座に利用できる。

JS同様、CSSのエントリーファイルだけ`app/javascropt/packs`配下に`application.css`として置いておく

CSSのトップレベルマニフェストが`app/javascript/styles/styles.scss`にある場合、`app/javascropt/packs/application.css`内に`import styels/styles`と記述しインポートする。よって、WebpackerがCSSファイルをダウンロードに含められるようになる。実際にWebページで読み込むには、ビューのコードに`<%= stylesheet_pack_tag "application"%>`を追記する

## 静的アセット * Webpacker

Webpackerは、デフォルトでは静的アセットをインポートしないことに注意。

静的アセットは、`public/packs/media`ディレクトリ配下に出力される、例えば、`app/javascript/images/my-image.jpg`にある画像をインポートすると、`public/packs/media/images/my-image-abc1234.jpg`に出力される。

この画像のimageタグをRailsのビューでレンダリングするには、`image_pack_tag 'media/images/my-image.jpg'`とする

|ActionViewHelper|WebpackerHelper|
|-|-|
|favicon_link_tag|favicon_pack_tag|
|image_tag|image_pack_tag|

<br>

使って見なきゃわからんね。
