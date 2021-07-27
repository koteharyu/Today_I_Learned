# 04_micropost_frontend

## dayjs

`dayjs`...JSの日付操作を簡単にするライブラリのこと。

今回は、`$ yarn add dayjs`コマンドで導入

`app/javascript/plugins/dayjs/index.js`ファイルを作成し、下記のようにする

```js
import Vue from 'vue';
import dayjs from 'dayjs';
import "dayjs/locale/js";

dayjs.locale("ja");

Vue.prototype.$dayjs;
```

`dayjs/locale/js`...日本語のローケールを別途インストール

`dayjs.locale("ja")`...使用するローケルを日本語に指定することができる

`Vue.prototype.$dayjs;`...グローバルスコープを汚すことなく、プロトタイプに追加することで全てのVueインスタンスで使用可能になる。`$`は、Vueにおいて全てのインスタンスが利用できるプロパティに対して接頭辞としてつけることが通例。`$`をつけることで他との衝突を防ぐことができる。Railsでいう`@`のようなものだろう。

`import Vue from 'vue';`...`$dayjs`をVueのプロトタイプに設定するためにインポートしている

## スプレッド構文

```js
async createMicropost(micropostContent) {
  const micropostParams = {
    micropost: {
      content: micropostContent,
    },
  };
  const res = await axios.post(`/api/microposts`, micropostParams);
  this.microposts = [...[res.data.micropost], ...this.microposts];
},
```

`...array`とすることでスプレッド構文になり、配列を展開してくれる。

配列の展開のイメージとしては、`[配列]`両端の`[``]`を取り除くような感じ

つまり、下記のように展開される

```js
fruits = ["apple", "orange", "grape"]

...fruits
#=> "apple", "orange", "grape"
```

今回の実装に話を戻すと、createMicropostが実行されると`this.microposts`には新規で作成したマイクロポストと既成のマイクロポストsが新たな配列として代入されることになる。

## @click=""

だいそんさんの解答例では、`@click=""`と書かれていたが、VScodeのプラグイン`eslint`に怒られたためあえてここ記述は省略することする

[![Image from Gyazo](https://i.gyazo.com/3a7fc2288c58c7fa800eaaac41e0de1b.png)](https://gyazo.com/3a7fc2288c58c7fa800eaaac41e0de1b)

## TimelineList.vueとMicropostItem.vueの関係性

MicropostItem.vueにとっての親コンポーネントはTimelineList.vueに当たるため、TimelineList.vue内にMicropostItem.vueをインポートしている。

```vue
<template>
  <v-card>
    <v-list three-line>
      <micropost-item
        :micropost="micropost"
        v-for="micropost in microposts"
        :key="micropost.id"
      ></micropost-item>
    </v-list>
  </v-card>
</template>

<script>
import MicropostItem from "@/components/MicropostItem";
export default {
  props: {
    microposts: {
      type: Array,
      default: [],
    },
  },
  components: {
    MicropostItem,
  },
};
</script>
```

親コンポーネントTimelineList.vue内で`v-for="micropost in microposts" :key="micropost.id"`した１つ１つのmicropostを子コンポーネントに渡している。

```vue
MicropostItem.vue
<script>
export default {
    props: {
        micropost: {
            type: Object,
            required: true
        }
    }
}
</script>
```
