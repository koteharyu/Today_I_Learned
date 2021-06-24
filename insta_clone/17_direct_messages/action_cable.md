# ActionCable

ActionCable...フロントのWebSocketとバックエンドのRails周りをシームレスに統合するフルスタックなフレームワークのこと

## Publisher / Subscriber

メッセージを送信する側(`Publisher`)が、特定のメッセージを受信する側(`Subscriber`)の抽象クラスに情報を送信する。この時Publisherは、個別の受信者(Subscriber)を指定しない

ActionCableは、サーバーと多数のクライアント間の通信にこのアプローチを採用している

## Rails側　サーバーサイドコンポーネント

#### Connection

- サーバーでWebSocketを受け付けるたびに、Connectionオブジェクトがインスタンス化される
- Connection自体は、アプリのロジックを扱わない
- Connectionは`ApplicationCable::Connection`のインスタンスである
- Connectionオブジェクトは、全てのChannel Subscriptionの親とる
- `Consumer`とは、Websokcet Connectionのクライアント
- 各ユーザーが開くブラウザ、ウィンド、デバイスごとの`Consumer`と`Connection`のペアが１つずつ作成される
- 開始時のリクエストはHTTPなので`cookie`も送られる
- そのため、`connection.rb`では`cookies`が使える

参照...`app/channels/application_cable/connection.rb`

`identified_by`...HTTPとは異なり毎回認証情報が送られたりしないため、コネクション確立時に「このコネクションは誰のものか」をサーバー側で管理するための記述。

#### Channel

- サーバー再度のコンポーネントでは、Channelの設定が必要
- MVCのC コントローラーに似ている
- Railsはデフォルトで、Channel間で共有されるロジックをカプセル化する`ApplicationCable::Channel`という親クラスを作成する

#### 親Channelの設定

```ruby
# app/channels/application_cable_channel.rb

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

`app/channels/application_cable_channel.rb`によって、専用のChannelクラスを作成する。今回は`FooChannel`と`FugaChannel`を作成する

```ruby
# app/channels/foo_channel.rb

class FooChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/fuga_channel.rb
class FugaChannel < ApplicationCable::Channel
end
```

Consumer(Websocket Connectionクライアント)は、このようにしてこれらのchannleをSubscribeできるようになる

#### Subscription (Rails側での実装)

```ruby
# app/channels/foo_channel.rb

class FooChannel::ApplicationCable::Channel

  # ConsumerがこのChannelのSubscriberになると
  # このコードが呼び出される
  def subscribed
  end
end
```

- Consumerは、ChannelをSubscribeし、Subscriberとして振る舞う
- 生成されたメッセージは、ActionCable Consumerから送信されるIDに基づいて、これらのChannel Subscriber側にルーティングされる

## クライアントとサーバーとのやりとり

#### Stream

stream...Channelにルーティング機能を与えること。これにより、ChannelはPublishされたコンテンツ(Broadcast)をSubscriberにルーティングできる

```ruby
# app/channels/foo_channel.rb

class FooChannel::ApplicationCable::Channel
  def subscribed
    stream_for "foo_002"
  end
end
```

複数の部屋がある場合、上記のようにパラメーターから該当のIDを取得する

#### Broadcast

- publisherからの送信内容は全てbroadcastを経由する
- Broadcastは、そのPublisherのBroadcastをStreamingしているChannelの、Subscriberに直接ルーティングされる
- 各Channelは、0個以上のBroadcastをStreamingできる
- StreamingしていないConsumerは、後で接続する時に、BroadCastを取得できない

```ruby
# broadcast

data = { text: "Hello World!" }
ActionCable.server.broacast("foo_002", data)
```

とすることで、Subscriberに`{"text": "Hello World!"}`というJSON文字列が送られる

#### Subscription

ChannelをSubscribeしたConsumerは、Subscriberとして振る舞う

`consumer.subscriptions.create`で新たな`Subscription`オブジェクトが作成され、`consumer.subscriptions`に追加される

```js
# foo_channel.js
import consuemr from "./consumer"
consuemr.subscriptions.create("FooChannel", {
  /////
});
```
