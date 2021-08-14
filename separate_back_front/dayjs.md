# dayjs

front, backにディレクトリを分けた際にdayjsをfront側で使う方法について

1. format
2. locale/ja

以上を使用したい

## install

今回はnpmで管理

`$ npm install dayjs --save`

## 設定

`src/plugins/dayjs.js`を作成し、次のように追記

```js
import 'dayjs/locale/ja';
import dayjs from 'dayjs';
import Vue from ''vue;

dayjs.locale('ja');

Vue.prototype.$dayjs = dayjs;
```

`prototype.$dayjs`...$dayjsとプロトタイプを設定することで、いろんなところでdayjsを`$dayjs`と呼び出すことができる

## 読み込み

設定したファイルを`/src/main.js`に読み込ませる

```js
import dayjs from './plugins/dayjs';

new Vue({
  dayjs,
  render: (h) => h(App),
}).$mount('#app');
```

## 使用方法

```vue
<v-list-item-action>
  <v-list-item-action-text v-text="$dayjs(micropost.created_at).format('YYYY-MM-DD HH:mm:ss')"></v-list-item-action-text>
</v-list-item-action>
```

## 追記

## Waringi

```
 warning  in ./src/main.js

"export 'default' (imported as 'dayjs') was not found in './plugins/dayjs'
```

とwarningが出ていたため、dayjs.jsを以下のように修正。これが最適解かわからないが、wariningは消えたし、挙動は変わらなかったためいいのか？

```js
import 'dayjs/locale/ja';
import dayjs from 'dayjs';
import Vue from 'vue';

dayjs.locale('ja');

Vue.prototype.$dayjs = dayjs;

export default dayjs;
```
