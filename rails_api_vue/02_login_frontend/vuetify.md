# Vuetify

`Vuetify`とは、Vue.jsで使用できるマテリアルデザインのUIフレームワークのこと。 レイアウトを構築するグリッドシステムから、ボタンなどの細かいパーツまで幅広くUIを提供している。

## 導入

`$ vue add vuetify`コマンドでvuetifyをインストールする。なお、質問には以下のように回答する

1. y
2. Default

サーバーを再起動させ、再度localhost:8080にアクセスするとvuetifyのウェルカム画面が表示されればOK

[![Image from Gyazo](https://i.gyazo.com/4612711e94f72b90f7937414bf2db4b6.png)](https://gyazo.com/4612711e94f72b90f7937414bf2db4b6)

ただし、既存のコード(App.vue)が書き変わってしまうことに注意。

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
