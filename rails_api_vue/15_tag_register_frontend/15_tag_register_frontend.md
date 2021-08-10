# 15_tag_register_frontend

ユーザーへのタグ登録をフロントエンドで...

1. ProfileEditModal.vueに登録フォームを追加
2. PageProfile.vueにタグを表示させる部分を追加

## ProfileEditModal

```vue
<template>
  <v-row>
    <v-col cols="12">
      <template>
        <v-container>
          <v-combobox
            v-model="selectedTags"
            :items="tags"
            :search-input.sync="search"
            hide-selected
            hint="最大５つまで登録できます"
            label="Add Some Tags"
            multiple
            persistent-hint
            small-chips
            :clearable="true"
            :deletable-chips="true"
          >
            <template v-slot:no-data>
              <v-list-item>
                <v-list-item-content>
                  <v-list-item-title>
                    タグ"<strong>{{ search }}</strong>"はまだ登録されていません。
                  </v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
          </v-combobox>
        </v-container>
      </template>
    </v-col>
  </v-row>
</template>


<script>
import axios from 'axios'

export default {
  data() {
    return {
      user: null,
      selectedTags: [],
      search: null,
      tags: [],
    }
  },
  created() {
    this.user = { ...this.$store.getters['auth/currentUser']}
    this.selectedTags = this.user.tags.map((tag) =>{
      return tag.name
    })
    this.fetchTags()
  },
  methods: {
    //
    async updateProfile(){
      const userParams = {
        user: {
          name: this.user.name,
          introduction: this.user.introduction,
          tag_names: this.selectedTags
        }
      }
      await this.$store.dispath('auth/updateProfile', userParams)
      //
    },
    async fetchTags() {
      const res = await axios.get(`/api/tags`)
      this.tags = res.data.tags.map((tag) =>{
        return tag.name
      })
    }
  }
}
</script>
```

`comboboxコンポーネント`...ンポーネントは選択肢 items内に存在しない値を入力できるv-autocomplete。作成されたアイテムは文字列として返される。コンボボックスを使用することで、提供されたアイテムリストに存在しない値をユーザーが作成できるようにすることができる。[公式](https://vuetifyjs.com/ja/components/combobox/)

`:items="tags"`...tagsが持っていない値を入力できるようにする。

`multiple`...複数選択可能にする

`search-input`...検索値。`.sync`と併用することで検索値を同期できる

`hint`...ヒントを設定

`persistent-hint`...`hint`で設定したヒントを常に表示することができる

`hide-selected`...選択済みの選択肢を表示しないようにする

`small-chips`...選択範囲の表示をsmallプロパティでchipに変更する

`crearable`...入力クリア(Xボタン)機能の追加

`deletable-chips`...選択したchipを取り消すボタンを表示する

`v-slot:no-data`...itemsが持っていない値が入力された際に`slot`が表示される

他にもたくさんPropsがあるので使用する際にまたみたい

`const userParams`...Railsへ送るためのパラメーターなのでスネークケースで合わせる必要がある

## PageProfile

```vue
<template>
  <v-devider inset></v-devider>

  <v-list-item>
    <v-list-item-title>
      <v-chip
        class="ma-1"
        color="orange"
        text-color="white"
        small
        v-for="tag in tags"
        :key="tag.name"
      >
        <v-icon left class="mr-0">mdi-accidental-sharpe</v-icon>
      </v-chip>
    </v-list-item-title>
  </v-list-item>
</template>
```

`v-chip`...小さな情報を伝えるために使用される。`close`プロパティを使用すると、チップはインタラクティブになり、ユーザとのやり取りが可能になる。[公式](https://vuetifyjs.com/ja/components/chips/)

[![Image from Gyazo](https://i.gyazo.com/0b2a31531db1faf417066bb698750465.png)](https://gyazo.com/0b2a31531db1faf417066bb698750465)
