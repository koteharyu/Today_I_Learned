# 05_micropost_detail_front

## $route.params.id

router/index.js内にて`{ path: '/microposts/:id', component: PageMicropostDetail, name: 'micropost-detail' }`と指定したため、`router-view`が`microposts/:id`を保持している。そのような動的なセグメントの場合、`$route.params`を使うことで利用できる

[![Image from Gyazo](https://i.gyazo.com/963bb01a1411b084515644efe76c100a.png)](https://gyazo.com/963bb01a1411b084515644efe76c100a)

## モーダルが表示される流れ

モーダルを表示させる`PageMicropostDetail.vue`が`MicropostEditModal.vue`にとっての親コンポーネントとなる。

`openEditMicropost`メソッドが実行された時、`MicropostEditModal.vue`コンポーネントをレンダーさせるため`PageMicropostDetail.vue`内に`<micropost-edit-modal>`コンポーネントをはめ込む

```vue
<micropost-edit-modal v-if="isMine" ref="dialog" :micropost="micropost" @update="updateMicropost"></micropost-edit-modal>

ちなみに、↓の書き方もできる

<micropost-edit-modal v-if="isMine" ref="dialog" :micropost="micropost" @update="updateMicropost" />
```

## MicropostEditModal.vue

`v-model="dialog"`...モーダルのdialogをバインドした上でdialogの初期値をfalseにすることで、デフォルトではモダールを非表示にさせている

## $emit

`$emit`を子コンポーネントで使用し、親コンポーネントのアクション名と引数を指定することで、親コンポーネントでその値を受け取ることができる

```vue
MicropostEditModal.vue

methods: {
  update() {
      this.$emit('update', this.micropostContent)
  }
}
```

```vue
PageMicropostDetail.vue

<micropost-edit-modal v-if="isMine" ref="dialog" :micropost="micropost" @update="updateMicropost"></micropost-edit-modal>

methods: {
  async updateMicropost(micropostContent) {
      await axios.patch(`/api/microposts/${this.micropostId}`, { micropost: { content: micropostContent } })
      this.$refs.dialog.close()
      this.micropost.content = micropostContent
  },
}
```

1. 子コンポーネントから親コンポーネントの`@update`アクションに`micropostContent`を渡す
2. `@update`が呼ばれることで、`updateMicropost`メソッドを実行させる。その際の引数は$emitで渡されたMicropostContentとなる
