# Vuex

`Vuex`...Vue.jsアプリで最もよく使われている状態管理ライブラリ。コンポーネント間で状態を共有するための仕組みを提供する

## 導入

`$ npm install vuex --save`コマンドでインストールする。

`--save`オプションは、package.jsonのdependenciesに登録させるオプションのこと。npm5.0以降だとデフォルトでこのオプションが付くようになったとのこと。git にコミットする際、パッケージをインストールしているフォルダ node_modules は .gitignore によって除外さる。違う開発環境を git からクローンして構築する場合、package.json を元に復元するため、同じパッケージ環境を簡単に構築することができるようになる。

`javascript/store`配下に`index.js`ファイルを作成

```js
import Vue from 'vue';
import Vuex from 'vuex';

export default new Vuex.Store ({
  modules: {
    // 作成したmodule名を記述,
  },
});
```

## Flux

`Flux`...Vuexで使われている状態管理のアーキテクチャのこと。一方通行のデータフローのアーキテクチャ。

[![Image from Gyazo](https://i.gyazo.com/e34353837a1446fa0f5307b4356e3711.png)](https://gyazo.com/e34353837a1446fa0f5307b4356e3711)

- 管理しているデータは`State`が保持しており、コンポーネントはこのStateを参照して(renderして)値を取得する
- Stateで管理しているデータの値を変更する場合は、直接Stateを更新するのではなく、`Action`を呼び出す(`dispatch`する)ことで変更指示を出す。
- `Action`はAPIを呼び出してデータを取得するなどの非同期処理を行う
  - ActionではまだStateの変更はしておらず、指示を出しているだけなので、実際の変更は`Mutation`を呼び出し(commit)行う
- `Mutation`ではActionから値を取り出し、Stateの更新(mutate)を行う
  - Stateの値を更新できるのはこの`Mutation`のみであることに注意

## Store

`ストア`...状態管理において、データの集約先のこと。どのコンポーネントからもストアを参照できるようにすることで、値の受け渡しをシンプルにする

storeのデータを扱うためには`state`, `getters`, `mutations`, `actions`の４つの処理が必要になる

`state`...状態管理するデータの定義

`getters`...stateの値を取り出す関数の定義

`mutaions`...actionsから送られてきたデータ通りに変更し、stateに保存する関数の定義

`actions`...axiosでAPIリクエストを送信して対象のデータを取得するmutationsを呼び出す関数の定義

## Vuexのヘルパー

### 1.状態を呼び出す

- `mapState`
- `mapGetters`

`computed`内に記述する

#### 2.状態を変化させる

- `mapMutations`
- `mapActions`

`methods`内に記述する

## axios

`axios`...APIを叩いてデータを取得するためのライブラリ

`$ npm install axios --save`コマンドでインストール

axiosを使用するファイル内で`import axios from 'axios';`と記述する

`axios.get()`...HTTP GETリクエストを送る

`axios.post()`...POSTリクエストを送る

`axios.put()`...PUTリクエストを送る

`axios.delete()`...DELETEリクエストを送る


