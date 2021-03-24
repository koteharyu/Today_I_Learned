# practice

<br>

## HTTPとは

<br>

- HTTPとはクライアントとサーバーをつなぐプロトコルのこと。
- URLのスキームで使用するプロトコルを指定する
- HTTPリクエストとHTTPレスポンスを繰り返えし、Webページを完成させる
- HTTPリクエストは、リクエスト行・メッセージヘッダー・メッセージボディの３つから構成される
  - リクエスト行には、Webサーバーに処理して欲しい情報を記載する
  - メッセージヘッダーには、Webブラウザの種類やバージョン、対応するデータ形式などクライアントの情報を記載する
  - メッセージボディには、Webページ内のフォームなどに入力されたテキストなどをWebサーバーに送りたい情報を記載する
- HTTPレスポンスは、レスポンス行・メッセージヘッダー・メッセージボディの３つから構成される
  - レスポンス行には、Webサーバーで行ったHTTPリクエストに対する処理結果を記載する
  - メッセージヘッダーには、Webサーバーの情報や種類、送信するデータのタイプ、データの圧縮方法などの情報を記載する
  - メッセージボディには、HTML画像などのコンテンツを記載する

<br>

## HTTPメソッドとは

<br>

- HTTPメソッドとは、クライアントがサーバーに対してHTTPリクエストを送る際に、サーバーに行って欲しい処理を伝える手段のこと
- 主にGETメソッドとPOSTメソッドが使用される
  - GETメソッドとは、文字通りコンテンツを取得したい時に使用するメソッド。
    - URLの末尾に「？」をつけて、「パラメーター名=値」の形式で送信する
  - POSTメソッドとは、データを送信する際に使用するメソッド。フォームに入力したパスワードなどのデータを転送したり、リソースを作成したりする際に使用する。
    - データはHTTPリクエストのメッセージボディに記載する

<br>

## ステータスコードとは

<br>

- ステータスコードとは、HTTPレスポンスに含まれるリクエストに対する処理結果のこと
  - 100番台は、リクエストが継続中であること
  - 200番台は、リクエストが正常に処理されたこと
  - 300番台は、リクエストの完了には追加の処理が必要であること
  - 400番台は、リクエストが間違っていること
  - 500番台は、サーバーでエラーが発生したこと

<br>

## HTTPリクエストとレスポンスの内容

## Generalについて

[![Image from Gyazo](https://i.gyazo.com/4cc04f9bccf42e86ab8096b6b7ba6b66.png)](https://gyazo.com/4cc04f9bccf42e86ab8096b6b7ba6b66)

<br>

- Request URL・・・TechEssentilasのコースのリクエストを送っていることがわかる
- Request Method・・・今回はHTTPSのGETメソッドを使用している
- Status Code・・・200が返ってきているので、処理に成功している

<br>

## レスポンスヘッダーについて

[![Image from Gyazo](https://i.gyazo.com/52624ab53e5368835084498d3083b31f.png)](https://gyazo.com/52624ab53e5368835084498d3083b31f)

<br>

TTPレスポンスの一部なので、以下の情報が含まれている

- キャッシュの情報(Cash Control)
  - 今回は、`max-age=0`なので既にキャッシュの期限が切れていると言うこと？
- ブラウザにcookieとして保存して欲しい情報(set-cookie)

<br>

## リクエストヘッダーについて

[![Image from Gyazo](https://i.gyazo.com/71f9422509f7f9f4b8e03a6ea32b9f05.png)](https://gyazo.com/71f9422509f7f9f4b8e03a6ea32b9f05)

<br>

- Webサーバーに送るためのcookieが含まれている

<br>

## レスポンスについて

[![Image from Gyazo](https://i.gyazo.com/1626812838a7681559576c0284fc1a7b.png)](https://gyazo.com/1626812838a7681559576c0284fc1a7b)

<br>

HTML形式でレスポンスが返ってきていることがわかる。つまりサーバー上でRubyなどのサーバーサイド・スクリプトがHTMLへ変換されている。

<br>

まだまだ検証ツールの見方などが身についてないので、都度確認して慣れたいと思った。

<br>

## フォームの送信内容について

プロフィール欄を更新した際の処理

<br>

[![Image from Gyazo](https://i.gyazo.com/1a59a319bfcd430c9e34aa86a4d7579a.png)](https://gyazo.com/1a59a319bfcd430c9e34aa86a4d7579a)

<br>

[![Image from Gyazo](https://i.gyazo.com/50bca6a88e9c9a79fdb0cc138aba71d0.png)](https://gyazo.com/50bca6a88e9c9a79fdb0cc138aba71d0)

<br>

[![Image from Gyazo](https://i.gyazo.com/fca24fbc03c6269dc02bd38475166b8b.png)](https://gyazo.com/fca24fbc03c6269dc02bd38475166b8b)

<br>

- POSTメソッドが使用されている
- status codeが302なのでリダイレクトをリクエスト側に要求している
- Content-Lengthは、本文の長さを表す
- Content-Typeは、サーバーに送信するリソースの種類を表します
- POSTメソッドで送信したデータは`Form Data`で確認できる

