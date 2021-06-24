# WebSocket

`WebSocket`とは...Webにおいて双方向通信を低コストで行うための仕組みのこと。チャットアプリを実現させるための機能、プロトコル。リロードなしでリアルタイム更新が実現できる。

### WebSocketの手順

1. HTTP(厳密にはそれをWebSocketにupgradeしたもの)でクライアントとサーバー間で情報をやりといしてコネクションを確立
   1. クライアントからサーバーにリクエストを送ってコネクションを確立するところから始まる。このリクエストやレスポンスがHTTPに乗っ取った形式がWebSocket
2. 確立されたコネクション上で、低コストな双方向通信

## コネクションの確立

まずは、クライアントから以下の様なリクエストが送られる

```
GET /resource HTTP/1.1
Host: example.com
Upgrade: websocket
Connection: upgrade
Sec-WebSocket-Version: 13
Sec-WebSocket-Key: E4WSEcseoWr4csPLS2QJHA==
```

見てわかるように、WebSocketはHTTPとして正しいリクエストを送っている

`Upgrade: websocket`, `Connection: upgrade`...HTTPからWebSocketへのプロトコルのアップグレードを表現している

`Sec-WebSocket-Versions: 13`...接続のプロトコルバージョンを指示するためにクライアントからサーバーへ送信される。サーバーは送られてきたバージョンに対応できなければコネクションを切断する。現在のWebSocketの最新バージョンは13なので、13を指定しなければならない。

`Sec-WebSocket-Key`...特定のクライアントとのコネクションの確立を立証するために使われるヘッダ。サーバーは`Sec-WebSocket-Key`ヘッダに指定された値を元に新しく値を生成して`Sec-Websoket-Accept`ヘッダにその値を指定してレスポンスを返すので、クライアント側は、自分が送った`Sec-WebSocket-Key`の値が使われているか確認できる仕組みになっている。

次に、サーバーからのレスポンスを見ていく

```
HTTP/1.1 101 OK
Upgrade: websocket
Connection: upgrade
Sec-WebSocket-Accept: 7eQChgCtQMnVILefJAO6dK5JwPc=
```

これも完全に正しいHTTPの形式となっている

`upgrad`, `connection`, `sec-websocket-accept`はリクエストで説明した通り。

このレスポンスをクライアントが受け取った時点でWebSocketのコネクションが確立され、双方向通信が可能になる

`WebSocket opening ハンドシェイク`...コネクション確立のための一連の流れのこと。

## 双方向通信の実現

ハンドシェイクが終わると、TCP上で双方向通信が可能になる。ハンドシェイク時はHTTPを使い、ハンドシェイク後はその確立されたTCPコネクション上で、双方向にデータのやりとりを行うことになる。

つまり、WebSocketは、クライアントとサーバーとの間でTCPコネクションを張りっぱなしにして行う通信である。
