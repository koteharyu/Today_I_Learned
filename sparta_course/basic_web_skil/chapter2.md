# chapter2 Webとネットワーク技術

<br>

## 01

コンピューターがお互いに接続して情報のやりとりを行うことを`コンピューターネットワーク`を呼ぶ

- `サーバー`とは、ネットワーク上で情報やサービスを提供する役割を持つコンピューターのこと


  Webサーバーなど
- `クライアント`とは、サーバーから提供された情報やサービスを利用する役割を持つコンピューターのこと

  Webブラウザなど

- `インターネットサービスプロバイダー`が提供するサービスを利用し、端末がWebサイトを閲覧できる

  `プロバイダー`、`ISP`は同義

<br>

## 02

- `プロトコル`とは、ネットワークに接続された機器同士を繋ぐための共通通信手段のこと

  HTTP（HyperText Transfer Protocol）はWebコンテンツを送受信するためのプロトコル

- `TCP/IP`とは、インターネットにおけるさまざまなサービスを実現するためのプロトコルの集まりのこと

  HTTPもTCP/IPの一部

|Protocol|用途|
|-|-|
|HTTP|WebブラウザとWebサーバー間でのコンテンツの送受信|
|FTP|コンピューター間でのファイルの送受信|
|SMTP|メール送信用|
|POP|メールサーバーらかの受信用|

<br>

## 03 

<br>

- `TCP/IP`は`4つの階層（レイヤー）`に分かれている
- それぞれのレイヤー同士で処理を行う
- 1から4に向かってデータが流れる

|レイヤー名|役割用途|プロトコル|
|-|-|-|
|`アプリケーション層(4)`|アプリ毎のやりとりを規定|HTTP、SMTP,FTP|
|`トランスポート層(3)`|データの分割や保証を規定|TCP、UDP|
|`インターネット層(2)`|ネットワーク間の通信を規定|IP,ICMP|
|`ネットワークインターフェース層(1)`|コネクタや周波数などのハードウェアに関する規定|イーサーネット、WiFi|

<br>

- `TCP`とは、送信側と受信側でお互いに確認を取りながら通信を行うコネクションなので、品質が保証されている

  Webサイトやメールなどデータ損失が起きたら困るアプリで利用される
- `UDP`とは、送信側と受信側で確認を取らないコネクション。そのため分割されたデータの順序や欠落を保証しないので効率よく通信が可能

  動画ストリーミングなどで利用されている

  <br>

## 04 

<br>

- `IPアドレス`とは、インターネット界の住所のようなもの。グローバルIPとプライベートIPがある。
- `ポート番号`とは、マンションでいう部屋番号のこ。コンピューターが提供するサービスを指定する

  - `HTTPのポートは80番`
  - `HTTPSは443番`
  - `FTPは20番(データ転送用)or21番(制御用)`

<br>

## 05

<br>

- `ドメイン`とは、「example.com」のようなIPアドレスの文字列版のようなもので、グローバルIPと同様に一意でなければならない

<br>

<span style="color: red;">http:</span>//<span style="color: blue;">www.sbcr.jp</span>
<span style="color: green;">:80</span>
/<span style="color: yellow;">index.html</span>

  <spna style="color: red;">スキーム名</spna>

  <span style="color: blue;">ホスト名（ドメイン名）</span>

  <span style="color: green;">ポート番号</span>
  
  <span style="color: yellow;">パス</span>

  <br>

## 06 

<br>

ドメインを利用してコンピューターに接続するには、`ドメインをIPアドレスへと変換`する必要がある


- `DNS`とは、ドメインをIPアドレスへ変換する仕組み。電話帳のようなもの
- `DNSサーバー`とは、DNSを提供するサーバ

DNSを利用したIPアドレスの問い合わせの流れ
1. www.sbcr.jpのIPアドレスを知りたい
2. ルートDNSサーバーに聞く
3. .jpのサーバに投げる
4. .jpのサーバーからsbcr.jpのサーバーに投げる
5. sbcr.jpがIPアドレスを特定
6. DNSキャッシュサーバーを通してクライアントへ

<br>

## 07

<br>

HTTPにおけるクライアントとサーバーのやりとり
1. Webブラウザのアドレス欄にURLを入力orサイト内のリンクをクリック
2. URLやリンク情報を基にWebサーバーに対してデータを要求
3. Webサーバーは要求内容を解析
4. 要求されたデータをWebブラウザへ応答
5. Webブラウザは受け取ったデータを解析し、Webページを表示

HTTPにおけるクライアントとサーバー間のデータの流れ

- HTTPリクエスト
1. HTTP = アプリケーション層
2. HTTP + TCP = トラスポート層
3. HTTP + TCP + IP = インターネット層
4. HTTP + TCP + IP + イーサーネットヘッダー = ネットワークインターネット層

- HTTPレスポンス
1. HTTP + TCP + IP + イーサーネットヘッダー = ネットワークインターネット層
2. HTTP + TCP + IP = インターネット層
3. HTTP + TCP = トラスポート層
4. HTTP = アプリケーション層

<br>

## COLUMN

<br>

- `IPv4`は、約43億個
- `IPv6`は、約340潤個



