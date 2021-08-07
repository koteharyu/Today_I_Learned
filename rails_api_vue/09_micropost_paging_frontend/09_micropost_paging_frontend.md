# 09_micropost_paging_frontend

## v-pagination

ページネーションを構築するコンポーネント

```vue
<template>
  <template v-if="pagingMeta">
    <div class="text-center">
      <v-pagination
        color="indigo"
        v-model="pagingMeta.current_page"
        :length="pagingMeta.total_pages"
        @input="paging"
      ></v-pagination>
    </div>
  </template>
</template>

<script>
  //
  import axios from 'axios'
  export default {
    data() {
      pagingMeta: null,
      currentPage: 1,
    },
    //
    created() {
      this.fetchMicroposts();
    },
    methods: {
      async fetchMicroposts() {
        const res = await axios.get(`/api/microposts`, { params: { page: this.currentPage }});
        this.microposts = res.data.microposts;
        this.pagingMeta = res.data.meta;
      },
      //
      paging(page) {
        this.currentPage = page
        this.fetchMicroposts();
        this.$vuefity.goTo(0);
      }
    }
  }
</script>
```

`v-pagination`...ページネーションを簡単に構築してくれるコンポーネント

`fetchMicroposts`...初期値が1である`currentPage`をパラメーターとして実行する。`pagingMeta`にmetaデータを格納しておく。

`v-model="pagingMeta.currentPage"`, `color="indigo"`...現在のページを藍色で表示させる

`:length="pagingMeta.total_pages"`...投稿数によってページングは変化するため動的である`:`をつける。この`length`に基づいてページ数を表示させる。また、prev, nextボタンを使用したナビゲーションも同時に表示してくれる

`@input="paging"`...それぞれのページングボタンに`paging`というメソッドを定義し、クリックされたページに対応する投稿を表示させる。ちなみに`@click="paging"`でも同様の挙動であったため、こちらの方がわかりやすかったため勝手に変更

`paging(page)`メソッド...クリックされたページ番号を引数とし、currentPageを変更させ、再度fetchMicropostsを実行し、描画する投稿を更新する

## スクロール

`$vuetify.goTo(0)`メソッド...$vuetifyオブジェクトにある`goTo`メソッドを使うことでスクロールをトリガーできる。引数に`0`を渡すことで、ページのトップにスクロールさせることができる
