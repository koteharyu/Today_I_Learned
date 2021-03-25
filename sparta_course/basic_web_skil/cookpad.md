## Server

- Webサーバーはページを返す
  - 静的なページ : 自分で返す
  - 動的なページ : Appサーバーに作ってもらって、それを返す

- Appサーバーはページを動的に生成する
  - 検索サーバーに欲しいデータの場所を教えてもらったり、DBサーバーにデータを送ってもらったりしてページを組み立てる
  - このときAppサーバーは検索サーバー・DBサーバーに対するクライアントになっている(役割！)

- どこを見てもリクエストとレスポンスがペアになっている

<br>

- 有名な検索サーバー
  - Elasticsearch
  - Solr(ソーラー、ソラー)

<br>

## サーバーの場所

- データセンター
  - サーバーをおいて動かしておくための専用施設

<br>

## SRE(インフラエンジニア)

- Site Reliability Engineering
- Reliability : 信頼性

<br>

## 識別・認証・認可

- 識別 Identification
  - 誰なのか明らかにする
  - 例・・・ログインID(メアドなど)を確認

- 認証 Authentication
  - 本当にその人なのか確認する
  - 例・・・パスワードを確認する

- 認可 Authorization
  - その人がアクセスして良いのか判断する
  - 例・・・許可証のようなものを発行しておいて、アクセスがあったときに検証する

<br>

## 認証・認可の注意点

- パスワードや許可証などはサーバーが「誰からのリクエストなのか」「何にアクセスして良いのか」を判断するために使っている重要な情報
- もし何らかの理由によって漏れてしまうと、その人に成りすましてリクエストを送ることが可能になる
- 漏れないようにする必要がある

<br>

## ブラウザとアプリの違い

- ブラウザとアプリではレスポンスとして受け取るものが異なっている
  - ブラウザ・・・HTML、CSS、JS、画像など
  - アプリ・・・JSON、画像など

<br>

## IP

- Internet Protocol
- インターネットを使ってデータを送受信するために使われるプロトコル
- パケットという単位にデータを分割して送信する
  - １本のケーブルを複数のクライアントでの共有を可能にしたいから
  - データの送信中に一部のデータが壊れた際に対象のデータだけ再送すれば済む（効率的）
- HTTPプロトコルにしたがって生成されたデータをIPというプロトコルにしたがってパケットに分割した上で送信する

<br>

## 暗号化と復号

- 暗号
  - そのままでは内容がわからないようにしたデータ
- 平文(ひらぶん) 
  - 見れば内容がわかるデータ
- 暗号と平文の変換 
  - 暗号化・・・平文から暗号への変換
  - 復号・・・暗号から平文への変換
- 暗号化したデータを送信して、受信してから復号すれば、もし覗き見されても大丈夫
- クライアントとサーバーで鍵を共有しておく必要がある
  - この鍵を共通鍵と呼ぶ

<br>

## 公開鍵暗号

- 暗号化するための鍵と復号するための鍵が別々の暗号
  - 非対称暗号と呼ばれる種類の
- 「秘密鍵」と「公開鍵」の２つがセットになっている
  - `秘密鍵`・・・秘密にしなければならない(今まで通り)
  - `公開鍵`・・・誰に見られても大丈夫
  - ２つ合わせて`キーペア`と呼ばれる
- どちらかの鍵で暗号化したものは、もう片方の鍵でしか復号できない‼

<br>

## デジタル署名

- データの送り主を認証するための仕組み
- 予め公開鍵暗号のキーペアを作成して、公開鍵を世界中に公開しておく
- 送信者は送信データを秘密鍵で暗号化してから送る
- 受信者は受信データを公開鍵で復号する
- 公開鍵暗号の性質により、正常に復号できれば、その公開鍵に対応する秘密鍵で暗号化されたことが判明する
- 秘密鍵は秘密にされているので、データの送り主は公開鍵に対応する秘密鍵を持っている人だと判明する

<br>

## 公開鍵証明書

- デジタル署名はデータの送り主が公開鍵に対応する秘密鍵を持っていることを保証するもの
- キーペアごと差し替えられて、偽物の公開鍵と秘密鍵を使って通信させられる可能性が残っている
- キーペアの差し替えを防ぐために、ある公開鍵が誰のものであるかを認証局が管理している
- 公開鍵と一緒に公開鍵証明書を受け取り、公開鍵証明書が正しいかどうか検証する
- 公開鍵証明書は認証局によって署名されている

<br>

## TLS

- 安全な通信を実現するためのプロトコル
  - 鍵交換アルゴリズムやデジタル署名などを利用している
- 昔はSSLと呼ばれていた
- TLSが提供する機能
  - 通信内容の暗号化・・・通信内容を覗き見されないように
  - 通信相手の認証・・・偽物のサイトに繋いでいないか
  - 改ざんの検出・・・通信途中で内容が書き換えられていないか

<br>

## MFA/2FA ~HTTPSをより安全に使うために~

- Multi-Factor Authentication
- 多要素認証(要素数が2の場合、2FAとも呼ばれる)
- パスワードのような「利用者が知っていること」以外の要素を組み合わせて認証する
- 「利用者が持っているもの」を組み合わせる場合が多い
  - 利用者が持っているデバイス(スマホなど)
  - パスワードのような情報はインターネット経由で盗むことができるが、利用者が持っているデバイスを盗むのは困難なため

<br>

## MFA/2FAのための道具

- 対象のデバイスを持っているかの確認のため、そのデバイスだけが知っている情報を入力させる
  - `セキュリティトークン`や`ワンタイムパスワード`
  - 短時間で変更される6桁の数字がよく使われる
- スマホにインストールして使うアプリと専用デバイスの2種類がある

<br>

## MFA/2FAの注意点

デバイス自体をなくしたり、引継ぎを忘れたりしたらログインできないため、`リカバリーコード`を保存しておくように！
