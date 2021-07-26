# VueRouter

`VueRouter`...Vue.jsにおいてルーティング制御をするためのプラグインのこと。

VueRouterを使ってSPAを構築するとページ内の更新が必要な箇所のみの書き換えが行われるため、ページを遷移するたびに遷移したページ全体を読み込む必要がなくなり。よって、ページ遷移をスムーズに行うことができるためUXの向上にも繋がる。

## 導入

`$ npm install vue-router`コマンドでインストールする

VueRouterやVuexなどのモジュールシステムを利用する際には、`Vue.use()`と記述する必要がある

```js
import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter) //　←こんな風に
```

## how to use

今回の実装では、`javascripts/router`配下に`router.js`ファイルを作成し、この中にルーティング処理を記述していく。

```js
routes: [
  { path: '/signup', components: PageUserRegister, name: 'user-register' },
  { path: '/login', components: PageUserLogin, name: 'user-login' },
  { path: '/', components: PageTimeine, name: 'timeline' },
]
```

記述方法としては、以下のようになる

```js
routes:[
  { path: 'パス', components: 呼び出すコンポーネント名, name: '<router-link>やrouter.pathで指定する名称' },
]
```

`routes`プロパティを配列で定義し、その中にルーティングに関する設定をすることでアクセスするパスに対応するコンポーネントが呼び出される流れ。

定義したルーティングは.vue内で`<router-link>`タグを使って利用する。また、`name`で指定した値を使用するには`to`プロパティにオブジェクトを渡す必要がある。`to="{ name: '設定したname' }"`

```vue
<router-link to="{ name: 'user-register' }">SIGN UP</router-link>
<router-link to="{ name: 'user-login' }">LOGIN</router-link>
<router-link to="{ name: 'timeline' }">TIME LINE</router-link>
```

## router-link

`router-link`...ルーティングのリンクを作成するタグ。ここでマッチしたコンポーネントを読み込ませる。また、このタグを使うことで非同期でのページ切り替えを実現できる

## router-view

`router-view`...`<router-link>`でマッチしたコンポーネントをレンダーする。レンダーするコンポーネントは、routesプロパティに指定したものをURLを見て決定する。

## 履歴管理

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
