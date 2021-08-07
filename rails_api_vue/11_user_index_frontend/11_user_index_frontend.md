# 11_user_index_frontend

1. app.vueにユーザー一覧への導線を追加
2. PageUsers.vuewを作成し、ユーザーを描画させる
3. vue-routerへの追記

## app.vue

```vue
<template>
<!---->
<v-list-item to="/users" link>
  <v-list-item-action>
    <v-icon>mdi-account-group</v-icon>
  </v-list-item-action>
  <v-list-item-content>
    <v-list-item-title>ユーザー</v-list-item-title>
  </v-list-item-content>
</v-list-item-action>
<!---->
</template>
```

## PageUsers.vue

```vue
<template>
  <v-container>
    <v-row dense>
      <v-col
        v-for="user in users"
        :key="user.id"
        :cols="6"
        :md="3"
      >
        <v-card>
          <v-img
            :src="`http://placeimg.com/300/300/people?dummy=${user.id}`"
            class="white--text align-end"
            gradient="to bottom, rgba(0,0,0,.1), rgba(0,0,0,.5)"
          >
            <v-card-title v-text="user.name"></v-card-title>
          </v-img>

          <v-card-text class="text--white">
            <div>#Ruby</div>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn icon>
              <v-icon>mdi-heart</v-icon>
            </v-btn>
            <v-btn icon>
              <v-icon>mdi-bookmark</v-icon>
            </v-btn>
            <v-btn icon>
              <v-icon>mdi-share-variant</v-icon>
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import axios from 'axios';
export default {
  data() {
    return {
      users: [],
    }
  },
  created() {
    this.fetchUsers()
  },
  methods: {
    async fetchUsers() {
      const res = await axios.get(`/api/users`)
      this.users = res.data.users
    }
  }
}
</script>
```

`fetchUsers`メソッドを定義し、このコンポーネントが描画される際にユーザー一覧を取得し、`users`に格納しておく。このようにすることで、ユーザーの数だけ`v-for`される

`gradient`...画像のグラデーションを指定できる。

## VueRouter

`to="/users"`に合わせてrouterに追記する

```js
import PageUsers from '../pages/PageUsers'

const router = new VueRouter({
  routes: [
    { path: '/users', components: PageUsers, name: 'users' }
  ]
})
```
