# Vue.js

`Vue.js`...Webアプリケーションにおけるユーザーインターフェイスを構築するための、オープンソースのJavaScriptフレームワークである。他のJavaScriptライブラリを使用するプロジェクトへの導入において、容易になるように設計されている。

## コンポーネント

vueでは複数のコンポーネントを作成し、それらを組み合わせて１つのページを構築する

１つのコンポーネントは、`template`, `script`, `style`のブロックを定義することができる

`template`...コンポーネントの見た目を定義するブロック

`script`...コンポーネントの処理を定義するブロック。JavaScriptで記述し、`export default`の中にvueの処理を記述する

`style`...コンポーネントのCSSを定義するブロック

## 親コンポーネント

`scr/App.vue`...一般的にこのコンポーネントが全てのコンポーネントの親となる

scriptブロック内で、importするコンポーネントを記述し、`components`キーの値にそのimportするコンポーネントを指定する

仮に、`Foge.vue`, `Fuga.vue`を作成して、親コンポーネントに適用させる場合は、以下のような記述となる

```vue
親コンポーネント

<script>
import Foge from './components/Foge'
import Foge from './components/Fuga'

export default {
  name: 'App',
  components: {
    Foge,
    Fuga,
  }
}
</script>
```
