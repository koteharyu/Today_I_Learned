# 02_login_frontend

今回は`yarn`にてそれぞれのライブラリをインストールした。

## ライブラリの使用方法

適当なjsファイル内にて、以下のような記述方法により使用可能とする

```js
import ライブラリ from 'ライブラリ';

Vue.use(ライブラリ);
```

## Vuetify

`Vuetify`...Vue.jsで使用できるマテリアルデザインのUIフレームワークのこと。 レイアウトを構築するグリッドシステムから、ボタンなどの細かいパーツまで幅広くUIを提供している。

`$ yarn add vuetfiy`コマンドにて導入

```js
// applicaiton.js
import Vuetify from 'vuetify';

Vue.use(Vuetify);
```

Vuetifyを使用するためには、`<v-app>`タグで全体を囲う必要がある

```vue
<template>
  <v-app>
    <!--こんな感じ-->
  </v-app>
</template>

<script>
  export default {
    //
  };
</script>
```

使用できるコンポーネントは[公式サイトを見るように](https://vuetifyjs.com/ja/)

感覚的にはbootstrapに似てると感じた。

## VueRouter

`VueRoputer`...Vue.jsにおいてルーティング制御をするためのプラグインのこと。

VueRouterを使ってSPAを構築するとページ内の更新が必要な箇所のみの書き換えが行われるため、ページを遷移するたびに遷移したページ全体を読み込む必要がなくなり。よって、ページ遷移をスムーズに行うことができるためUXの向上にも繋がる。

#### 導入

`$ yarn add vue-router`コマンドにて導入

今回は`app/javascript/router/index.js`ファイルを作成し、この中にルーティングを記述していく

```js
import VueRouter from 'vue-router';

Vue.use(VueRouter);

const router = new Router ({
  routers: [
    { path: "/signup", component: PageUserRegister, name: "user-register" },
    { path: "/login", component: PageUserLogin, name: "user-login" },
    { path: "/", component: PageTimeline, name: "timeline" },
  ]
});

export default router;
```

#### 使用方法

記述方法としては、以下のようになる

```js
routes:[
  { path: 'パス', components: 呼び出すコンポーネント名, name: '<router-link>やrouter.pathで指定する名称' },
]
```

`routes`プロパティを配列で定義し、その中にルーティングに関する設定をすることでアクセスするパスに対応するコンポーネントが呼び出される流れ。

定義したルーティングは.vue内で`<router-link>`タグを使って利用する。また、`name`で指定した値を使用するには`to`プロパティにオブジェクトを渡す必要がある。`to="{ name: '設定したname' }"`

`export default <定義した変数名>`...この記述により他のファイルでも使用可能にできる。今回は`router`という変数

#### router-link

`router-link`...ルーティングのリンクを作成するタグ。ここでマッチしたコンポーネントを読み込ませる。また、このタグを使うことで非同期でのページ切り替えを実現できる

#### router-view

`router-view`...`<router-link>`でマッチしたコンポーネントをレンダーする。レンダーするコンポーネントは、routesプロパティに指定したものをURLを見て決定する。

#### 履歴管理

Vue.jsでは、非同期通信の実現のため、ブラウザの履歴管理をクライアント側で行う必要がある。VueRouterでは、２種類の方法での履歴管理ができる

1. `hashモード`
   1. historyモードよりも動作が早いメリットがある。
   2. URLに`#`を含む
      1. localhost:3000/#/login
2. `historyモード`
   1. サーバーへの通信が発生するため、サーバーの設置が必要になる。
   2. hashモードよりは速さが劣る
   3. URLに`#`を含まない
      1. localhost:3000/login
   4. HTML5 History APIが必要になる

今回の要件は、URLに`#`を含めるため、`hashモードを使用する`

<br>

## Vuex

`Vuex`...Vue.jsアプリで最もよく使われている状態管理ライブラリ。コンポーネント間で状態を共有するための仕組みを提供する。

#### 導入

`$ yarn add vuex`コマンドにて導入

`app/javascript/store/index.js`ファイルを作成し、この中で管理してゆく。

```js
import Vuex from 'vuex';

Vue.use(Vuex);
```

#### Flux

`Flux`...Vuexで使われている状態管理のアーキテクチャのこと。一方通行のデータフローのアーキテクチャ。

[![Image from Gyazo](https://i.gyazo.com/e34353837a1446fa0f5307b4356e3711.png)](https://gyazo.com/e34353837a1446fa0f5307b4356e3711)

- 管理しているデータは`State`が保持しており、コンポーネントはこのStateを参照して(renderして)値を取得する
- Stateで管理しているデータの値を変更する場合は、直接Stateを更新するのではなく、`Action`を呼び出す(`dispatch`する)ことで変更指示を出す。
- `Action`はAPIを呼び出してデータを取得するなどの非同期処理を行う
  - ActionではまだStateの変更はしておらず、指示を出しているだけなので、実際の変更は`Mutation`を呼び出し(commit)行う
- `Mutation`ではActionから値を取り出し、Stateの更新(mutate)を行う
  - Stateの値を更新できるのはこの`Mutation`のみであることに注意

#### Store

`ストア`...状態管理において、データの集約先のこと。どのコンポーネントからもストアを参照できるようにすることで、値の受け渡しをシンプルにする

storeのデータを扱うためには`state`, `getters`, `mutations`, `actions`の４つの処理が必要になる

`state`...状態管理するデータの定義

`getters`...stateの値を取り出す関数の定義

`mutaions`...actionsから送られてきたデータ通りに変更し、stateに保存する関数の定義

`actions`...axiosでAPIリクエストを送信して対象のデータを取得するmutationsを呼び出す関数の定義

#### Vuexのヘルパー

状態を呼び出す

- `mapState`
- `mapGetters`

`computed`内に記述する

状態を変化させる

- `mapMutations`
- `mapActions`

`methods`内に記述する

## axios

`axios`...APIを叩いてデータを取得するためのライブラリ

`$ yarn add axios`コマンドにて導入

axiosを使用するファイル内で`import axios from 'axios';`と記述する

`axios.get()`...HTTP GETリクエストを送る

`axios.post()`...POSTリクエストを送る

`axios.put()`...PUTリクエストを送る

`axios.delete()`...DELETEリクエストを送る
