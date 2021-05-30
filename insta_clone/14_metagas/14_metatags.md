# 14_metatag

## 要件

- ngrokを使って一時的にインターネット上にサイトを公開する
- Slackに投稿したときにメタタグが反映されているか確認する
- 以下の要件にそってメタタグを付ける

||トップページ|ユーザー一覧ページ|ユーザー詳細|投稿詳細|
|-|-||-||
|title|InstaClone - Railsの実践的アプリケーション|ユーザー一覧ページ|InstaClone|ユーザー詳細ページ|
|description|Ruby on Railsの実践的な課題です。Sidekiqを使った非同期処理やトランザクションを利用した課金処理など実践的な内容が学べます。|← 同じ|← 同じ|投稿のbody|
|keyword|rails, instaclone, rails特訓コース|← 同じ|← 同じ|← 同じ|
|OGP画像|デフォの|デフォの|デフォの|1枚目の画像|

## ngrok

ngrokとは、ローカルPC上で稼働しているサービスを外部公開できるサービスのこと。つまり開発環境だと`localhost:3000`で、開発端末でしか見れないサービスが、herokuにデプロイしたようになる

[この記事](https://qiita.com/Marusoccer/items/7033c1bb9c85bf6789bd)を参考にした。

ngrokの起動方法は、別のターミナルで`rails s`をしたのちに、`ngrok http 3000`で起動させる

[![Image from Gyazo](https://i.gyazo.com/3bb195b1850a152875c733a3173f3f2c.png)](https://gyazo.com/3bb195b1850a152875c733a3173f3f2c)

ngrokはhttpとhttpsを用意してくれるため、お好きなアドレスからリクエストを送れば、開発中のアプリが表示される

## メタタグとは

`<meta>`...Webページの情報を記載するタグのこと。ユーザーではなく検索エンジンやブラウザに向けてWebページの内容を紹介するためのタグ。適切に設定することで、クリック数の増加にも繋がる(SEO対策)

### SEOとは

`Search Engine Optimization`...検索エンジン最適化

検索エンジンからサイトに訪れる人を増やすことで、Webサイトの成果を向上させる施策のこと。特定のキーワードで検索された場合の検索結果で、自分のサイトのページを上位に表示させるようにページのサイト、さらにサイト外の要因を調整することが多い

### SEO対策に役立つとされるメタタグ

`description`...Webページの概要を紹介するメタタグ。ユーザーの興味を引く文章を書けば、クリック率の向上に繋がる。(SEOに直接関係はしない)

`title`...検索エンジンとユーザーに向けて、Webページの内容を30文字程度で伝えるもの。

`keyword`...Webページがどんなキーワードと関連したページなのかを示すタグ。`,`で区切ることで複数のキーワードを設定できる。ただし、Googleはkeywordタグを無視すると言及しているためSEO対策としては意味をなさなくなった。

`文字コード`...どのような文字コードでWebページを表示するかを指定するタグ。文字化けしないように設定すべし

`ビューポートタグ`...スマホやタブレットでもWebページを正常に見れるように文字の大きさやデザインを調整するためのタグ。`<meta name="viewport" content="width=device-width, initial-scale=1">`のように記載する

`OGPタグ`...Open Graph Protocolの略。SNSでシェアされたコンテンツのレイアウトを設定するためのタグ。FaceBookやTwitterなどで、コンテンツが投稿された際に、ページ全体の見た目を設定する

`canonicalタグ(カノニカル)`...URL正規化をするためのタグ。URL正規化をしないと複数の異なるURLで同一のページを閲覧できる状態になってしまう恐れが生じる。PC用とスマホ用のサイトでURLが違う場合、どちらかを元サイトとして指定することで検索エンジンが正しく同一の内容のものだと認識させるようなイメージ

```
# OGPタグの一連

<meta property=""og:title"" content=""ページの タイトル"" />
<meta property=""og:type"" content=""ページの種類"" />
<meta property=""og:url"" content=""ページの URL"" />
<meta property=""og:image"" content=""サムネイル画像の URL"" />
<meta property=""og:site_name"" content=""サイト名"" />
<meta property=""og:description"" content=""ページのディスクリプション"" />
```

`noindex nofollow`...noindexタグは、検索エンジンに登録しないWebページを設定できるタグ。不要なページを除外することでコンテンツ全体の質を向上させる効果がある。nofollowタグは、特定のページへのリンクを遮断するタグ。クローラーに不要なページを評価させたくない場合に設定する`<meta name="robots" content="noindex, nofollow">`

## gem meta_tags

gem meta_tagsを使うことで、以下の項目を簡単に実装することができる

- サイト名の設定
- 各ページごとのタイトルの設定
- OGPの設定
- Twitter OGPの設定
- Facebook OGPの設定

今回は、`title`, `description`, `keyword`の設定を行う

### 導入

`gem 'meta_tags'` bundle install

`$ bundle exec rails g meta_tags:install`コマンドで設定ファイル(config/initializers/meta_tags.rb)を作成する

この設定ファイルでは、それぞれの文字数制限などを設定できる。今回はデフォルトのまま進める

```
# onfig/initializers/meta_tags.rb

 # titleの文字数制限70文字
 # config.title_limit = 70

 # When true, site title will be truncated instead of title. Default is false.
 # config.truncate_site_title_first = false

 # Maximum length of the page description. Default is 300.
 # Set to nil or 0 to remove limits.
 # descriptionの文字数制限
 # config.description_limit = 300

 # Maximum length of the keywords meta tag. Default is 255.
 # config.keywords_limit = 255

 # Default separator for keywords meta tag (used when an Array passed with
 # the list of keywords). Default is ", ".
 # config.keywords_separator = ', '

 # When true, keywords will be converted to lowercase, otherwise they will
 # appear on the page as is. Default is true.
 # config.keywords_lowercase = true

 # When true, the output will not include new line characters between meta tags.
 # Default is false.
 # config.minify_output = false

 # When false, generated meta tags will be self-closing (<meta ... />) instead
 # of open (`<meta ...>`). Default is true.
 # config.open_meta_tags = true

 # List of additional meta tags that should use "property" attribute instead
 # of "name" attribute in <meta> tags.
 # config.property_tags.push(
 #   'x-hearthstone:deck',
 # )
end
```

### 使い方

`display_meta_tags`メソッド...メタタグを表示させるメソッド。`title`, `description`メソッドを使うことで、それぞれをセットできる

```
<head>
 <%= display_meta_tags site: 'My website' %>
</head>
<body>
 <h1><%= title 'My page title' %></h1>
</body>
```

とすることで、以下のHTMLが生成される

```
<head>
 <title>My website | My page title</title>
</head>
<body>
 <h1>My page title</h1>
</body>

```

`set_meta_tags`メソッド...一度に複数のメタタグを設定することができたり、個別のファイルに記述することで上書きもできる

```
= set_meta_tags title: 'Member Login',
                description: 'Member login page.',
                keywords: 'Site, Login, Members'
```

`to_meta_tags`メソッド...ActiveRecordクラスのオブジェクトを引数とすることができる

```
class Document < ApplicationRecord
 def to_meta_tags
   {
     title: title,
     description: summary,
   }
 end
end

@document = Document.first
set_meta_tags @document
```

### 実装

流れとしては、共通項目は`app/views/layouts/application.html.slim`に記載し、個別で設定する項目は該当ファイルに記載していく

設定するメタタグを`app/helpers/application_helper.rb`内に`default_meta_tags`メソッドとして定義することで、`display_meta_tags(default_meta_tags)`として簡潔に記述することができる。なお今回は復習も兼ねて、`config`gemを活用し、定数に格納しておく

```
# helpers/application_helper.rb

module ApplicationHelper
  def default_meta_tags
    {
      site: Settings.meta.site,
      # trueに設定すると「title | site」の並びで出力
      reverse: true,
      title: Settings.meta.title,
      description: Settings.meta.description,
      keywords: Settings.meta.keywords,
      # URLを正規化するcanonicalタグを設定
      canonical: request.original_url,
      # OGPの設定
      og: {
        title: :full_title,
        # ウェブサイト、記事、ブログサイトの種類
        type: Settings.meta.og.type,
        url: request.original_url,
        image: image_url(Settings.meta.og.image_path),
        site_name: :site,
        description: :description,
        # リソース言語を設定
        locale: 'ja_JP'
      },
      twitter: {
        # twitterOGPのSummaryカード
        card: 'summary_large_image'
      }
    }
  end
end
```

|設定項目|役割|
|-|-|
|site|サイト名を設定|
|title|タイトルを設定|
|reverse|trueとすることで「タイトル」「サイト名」の並びで出力する|
|charset|文字コードの設定|
|description|descriptionの設定|
|keywords|キーワードを「,」区切りで複数設定できる|
|canonical|canonicalタグの設定|
|separator|ページ名とサイト名の区切りを設定。デフォルトは「|」|
|icon|favicon, apple用アイコンの設置|
|og:site_name|サイト名の設定|
|og:title|各ページタイトルの設定|
|og:description|descriptionの設定|
|og:type|website, article, blogなどから1つを選択|
|og:url|URLの設定|
|og:image|シェア用の画像を設定|
|og:locale|リソース言語の設定|

```
# config/settings.yml

meta:
  site: InstaClone
  title: InstaClone - Railsの実践的アプリケーション
  description: Ruby on Railsの実践的な課題です。Sidekiqを使った非同期処理やトランザクションを利用した課金処理など実践的な内容が学べます。
  keywords:
    - Rails
    - InstaClone
    - Rails特訓コース
  og:
    type: website
    image_path: /images/default.png
```

上記の設定をすることで、`application.html.slim`に`display_meta_tags`メソッドを記述することができるようになる

```
# application.html.slim

doctype html
html
 head
   meta content=("text/html; charset=UTF-8") http-equiv="Content-Type" /
   meta[name="viewport" content="width=device-width, initial-scale=1.0"]
   = display_meta_tags(default_meta_tags)
   = csrf_meta_tags
   = csp_meta_tag
```

このapplication.html.slimは以下のようなHTMLを生成する

[![Image from Gyazo](https://i.gyazo.com/508abd874cacf2244e2664e64e17daa1.png)](https://gyazo.com/508abd874cacf2244e2664e64e17daa1)

ベースとなるメタタグの設定ができたので、残りの個別のページにメタタグを設定していく。使用するメソッドは`set_meta_tags`

```
# users/index

- set_meta_tags title: "ユーザー一覧ページ"
```

```
# users/new

- set_meta_tags title: "ユーザー登録ページ"
```

```
# users/show

- set_meta_tags title: "ユーザー詳細ページ"
```

```
# user_sessions/new

- set_meta_tags title: "ログインページ"
```

```
# posts/show

- set_meta_tags title: "投稿詳細ページ", description: @post.body,
               og: { image: "#{@post.images.first.url}"}
```

`display_meta_tags`メソッドは`=`

`set_meta_tags`メソッドは`-`

の違いがあることに注意！(両方とも`=`使いたい...)

## twitter card summary_large_image

上記で指定している`twitter: { card: summary_large_image }`について

この指定をすることで、twitterでURLをシェアしたときにページの情報がラージサイズのカードタイプで表示されるようになる。

ほかにも、`summary`という引数も渡すことができ、こちらは通常の大きさのカードで表示させたい場合に指定する

### 実装例

```
# 実装例

<meta name="twitter:card" content="summary_large_image">
```

なお、`twitter:title`, `twitter:description`, `twitter:image`の3項目は、`OGP`の項目と併用することができるため、OGPが設定済みであれば、twitter側を省略できるため、以下のような記述もできる

```
# 実装例

<meta property="og:title" content="InstaClone">
<meta property="og:description" content="Ruby on Railsの実践的な課題です。Sidekiqを使った非同期処理やトランザクションを利用した課金処理など実践的な内容が学べます。">
<meta property="og:image" content="<画像のパス>">
```

[こちらのサイト](https://cards-dev.twitter.com/validator)でプレビューをチェックできる

[公式](https://github.com/kpumuk/meta-tags)

[メタキーワード](https://sem-journal.com/seo/meta-keywords/)

[twitter cardについて](https://www.granfairs.com/blog/staff/setting-twitter-cards)
