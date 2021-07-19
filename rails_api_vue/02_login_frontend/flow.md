## Vuetify

`$ npm install vuetify --save`

`$ be rails webpacker:install`

`$ yarn add --dev webpack-dev-server`

`bin/webpack`

`$ be rails g controller home index`

```rb
class HomeController < ApplicationControlle
  def index
  end
end
```

```rb
root 'home#index'
```

views/home/index.erbの編集

```
<%= javascript_pack_tag 'hello_vue' %>
```

この状態で`$ be rails s`をして、アクセスし、`Hello Vue`を確認できれば導入の成功

次に`javascript/app.vue`を編集する

```vue
<template>
  <v-app id="inspire">
    <v-navigation-drawer
      v-model="drawer"
      app
    >
      <v-list dense>
        <v-list-item link >
          <v-list-item-action>
            <v-icon>mdi-home</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title>Home</v-list-item-title>
          </v-list-item-content>
        </v-list-item>

        <v-list-item link>
          <v-list-item-action>
            <v-icon>mdi-email</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title>Contact</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar app color="indigo" dark>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <v-toolbar-title>Application</v-toolbar-title>
    </v-app-bar>

    <v-main>
      <v-container class="fill-height" fluid>
        <v-row align="center" justify="center">
          <v-col class="text-center">
            <v-tooltip left>
              <template v-slot:activator="{ on }">
                <v-btn v-on="on" icon :href="source" large target="_blank">
                  <v-icon>mdi-code-tags</v-icon>
                </v-btn>
              </template>
              <span>Source</span>
            </v-tooltip>
          </v-col>
        </v-row>
      </v-container>
    </v-main>

    <v-footer color="indigo" app>
      <span class="white-text">&copy; 2021</span>
    </v-footer>

  </v-app>
</template>

<script>
export default {
  props: {
    source: String,
  },
  data: () => ({
    drawer: null,
  }),
}
</script>
```

`javascript/packs/application.js`の編集

```js
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
ActiveStorage.start()

import Vue from 'vue';
import App from '../app.vue';
import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';

Vue.use(Vuetify)
const vuetify = new Vuetify();

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    vuetify,
    render: h => h(App)
  }).$mount()
  document.body.appendChild(app.$el)

  console.log(app)
})
```

`render: h => h(App)`...`../app.vue`をレンダーするということ

<br>

`layouts/application.html.erb`に以下を追記し、見た目を整える

```erb
<link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css" rel="stylesheet">
```

<br>

## @を使ってコンポーネント等を検索できるよう設定

`config/webpack/alias.js`

```js
const path = require('path')
module.exports = {
  resolve: {
    // aliasという名前で
    alias: {
      // @を　   '..'は「このファイルのある場所(webpack)」の上の階層を示す
      '@': path.resolve(__dirname, '..', '..', 'app/javascript')
      // (config > webpack)の上　つまりプロジェクトにとってのホームディレクトリ
      // から見た時の 'app/javascript'
      // を示すように設定
    }
  }
}
```

`..`...「このファイルのある場所(webpack)」の上の階層を示す。ここでの処理は、(config > webpack)の上　つまりプロジェクトにとってのホームディレクトリから見た時の `app/javascript`を示すように設定している。つまり、`@/pages/PageUserRegister`...`app/javascript/packs/pages/PageUserRegister`のことを示していることになる

`config/webpack/environment.js`

```js
const aliasConfig = require('./alias')

environment.config.merge(aliasConfig)
```

作成したalias.jsを`aliasConfig`という名前で使用することを定義し、environment.configに追加している

<br>

## ユーザー登録とログイン機能

`$ npm install vue-router --save`コマンドで、VueRouterをインストールする

`javascript/packs/application.js`にVueRouterをインポートし、使用可能にする

```js
import router from '@/router';

document.addEventListnere('DOMContentLoaded', () => {
  const app = new Vue({
    vuetify,
    router,
    //
  })
})
```

<br>

必要なページを作成する

- PageUserRegister
- PageUserLogin
- PageTimeline

PageUserRegister

```vue
<template>
  <div>
    <v-container>
      <v-row justify="center" align="center">
        <v-col cols="12" sm="8" md="4">
          <v-card class="elevation-12">
            <v-card-text >
              <v-form ref="form" v-model="valid" lazy-validation>
                <v-text-field
                  v-model="name"
                  :counter="10"
                  :rules="nameRules"
                  label="Name"
                  required
                  prepend-icon="mdi-account"
                ></v-text-field>

                <v-text-field
                  v-model="email"
                  :rules="emailRules"
                  label="E-mail"
                  required
                  prepend-icon="mdi-email"
                ></v-text-field>

                <v-text-field
                  v-model="password"
                  :relues="passwordConfirmationRules"
                  label="Password"
                  required
                  prepend-icon="mdi-lock"
                  type="password"
                ></v-text-field>

                <v-text-field
                  v-model="passwordConfirmation"
                  label="PasswordConfirmation"
                  required
                  prepend-icon="mdi-lcok"
                  type="password"
                ></v-text-field>
              </v-form>
            </v-card-text>

            <v-card-actions>
              <v-btn color="primary" @click="signup">新規登録</v-btn>
              <v-spacer></v-spacer>
              <router-link to="/login" class="text-decoration-none">ログインページへ</router-link>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data: () => ({
    valid: true,
    name: '',
    email: '',
    password: '',
    passwordConfirmation: '',
  }),

  computed: {
    nameRules() {
      return [
        v => !!v || 'Name is required',
        v => (v && v.length <= 10) || 'Name　must be less than 10 characters',
      ]
    },
    emailRules() {
      return [
        v => !!v || 'E-mail is required',
        v => /.+@.+@\..+/.text(v) || 'E-mail must be valid',
      ]
    },
    passwordConfirmationRules() {
      return [
        this.password === this.passwordConfirmation || 'Password must match'
      ]
    },

    methods: {
      async signup() {
        if (this.$ref.form.validate()) {
          try {
            await axios.post(`/api/users`, {
              user: {
                name: this.name,
                email: this.email,
                password: this.password,
                password_confirmation: this.passwordConfirmation,
              }
            })
            this.$router.push('/login')
          } catch(err) {
            alert(err.response.data.error.message);
          }
        }
      }
    }
  }
}
</script>
```

`lazy-validation`...バリデーションエラーがない限り常にtrueとなる

`:rules`...この属性は、配列を受け付けるため、それぞれ配列で返す必要がある。

`v`...それぞれのRulesに対する値を`v`で受け取る

`:`...動的な場合につけるやつ

`:counter`...現在の入力故字数をカウントする属性。設定した文字数を超えた段階で、エラーメッセージが表示される

`this.$refs.form.validate()`...`ref="form"`の指定をしたコンポーネントに対して、全ての入力を検証し、それら全てが有効であるかどうかを確認するVuetifyが提供しているメソッド。

`this.$router.push('/login')`...異なる URL へ遷移するときに `router.push` を使う。このメソッドは history スタックに新しいエントリを追加する。それによってユーザーがブラウザの戻るボタンをクリックした時に前の URL に戻れるようになる。また、このメソッドは `<router-link>` をクリックした時に内部的に呼ばれている。つまり `<router-link :to="...">` をクリックすることは router.push(...) を呼ぶことと等価である。

<br>

PageUserLogin

```vue
<template>
  <v-container class="fill-height" fluid>
    <v-row justify="center" align="center">
      <v-col cols="12" sm="8" md="6">
        <v-card class="elevation-12">
          <v-card-text>
            <v-form ref="form" lazy-validation>
              <v-text-filed
                v-model="email"
                :rules="emailRules"
                label="E-mail"
                required
                prepend-icon="mdi-email"
              ></v-text-filed>

              <v-text-field
                v-mdoel="password"
                :rules="passwordRules"
                label="Password"
                required
                prepend-icon="mdi-lock"
                type="password"
              ></v-text-field>
            </v-form>
          </v-card-text>

          <v-card-actions>
            <router-link to="/signup" class="text-decoration-none caption">ユーザー登録ページへ</router-link>
            <v-spacer></v-spacer>
            <v-btn dark color="indigo" @click="login">ログイン</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    email: '',
    password: '',
  }),

  computed: {
    emailRules() {
      return [
        v => !!v || 'E-mail is required',
        v => /.+@.+@\..+/.text(v) || 'E-mail must be valid',
      ];
    },
    passwordRules() {
      return [
        v => !!v || 'Password is required',
      ];
    },
    methods: {
      async login() {
        if (this.$refs.form.validate()) {
          try {
            await axios.post(`/api/session`, {
              session: {
                email: this.email,
                password: this.password,
              }
            })
            this.$router.push('/')
          } catch(error) {
            alert(error.response.data.error.message)
          }
        }
      }
    }
  }
}
</script>
```

<br>

PageTimeline

```vue
<template>
  <div>
    タイムライン
  </div>
</template>
```

<br>

`javascript/router/index.js`を作成し、VueRouterの設定を行う

```js
import Vue from 'vue';
import VueRouter from 'vue-router'
Vue.use(VueRouter);
import PageUserRegister from '@/pages/PageUserRegister';
import PageUserLogin from '@/pages/PageUserLogin';
import PageTimeline from '@/pages/PageTimeline';

const router = new VueRouter({
  routes: [
    { path: '/signup', components: PageUserRegister, name: 'user-register' },
    { path: '/login', components: PageUserLogin, name: 'user-login' },
    { path: '/', components: PageTimeline, name: 'timeline' },
  ]
});

export default router;
```

<br>

## 認証情報をVuexに移す

`javascript/store/modules/auth/index.js`ファイルを作成し、ここに認証情報を保持するVuexの処理を追記する

```js
import axios from 'axios';

const state = {
  currentUser: null,
}

const getters = {
  currentUser: state => state.currentUser,
};

const mutations = {
  SET_CURRENT_USER: (state, user) => {
    state.current_user = user;
    localStorage.setItem('currentUSer', JSON.stringify(user));
    axios.defaults.headers.common['Authorization'] = `Bearer ${user.token}`;
  },
};

const actions = {
  async login ({ commit }, sessionParms) {
    const res = await axios.post(`/api/session`, sessionParams);
    commit('SET_CURRENT_USER', res.data.user);
  },

  logout({ commit }) {
    commit('SET_CURRENT_USER', null);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions,
};
```

`localStorage.setItem(key,value);`...currentUserというキーに、文字列であるuserをJSONに変換した上でセットし、ローカルストレージに保存させる。ちなみに`getItem(key)`...ローカルストレージ内の指定したキーの値を取得するメソッド。`removeItem(key)`...指定したキーとスカラー値を削除するメソッド

`JSON.stringify()`...引数で渡したオブジェクトをJSON形式に変換するメソッド。今回はSET_CURRENT_USERにセットするuserをJSON形式に変換している

`axios.defaults.headers.common['Authorization'] = `Bearer ${user.token}`;`...JWT認証のアプリにおいてaxiosでAPIwp叩く際に、headersにAuthorization:tokenをくっつける処理。

次に、作成した`auth/index.js`ファイルを読みこます親ファイルを作成する`javascript/store/index.js`

```js
import Vue from 'vue';
import Vuex from 'vuex';
import auth from '@/store/modules/auth';

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    auth,
  },
});
```

次に、直接axiosでAPIを叩く処理を記述していた箇所を変更する

まずは、`javascript/pacs/application.js`

```js
import store from '@/store'

documents.addEventListener('DOMContentLoaded', () = {
  const app = new Vue({
    vuetify,
    router,
    store,
    created() {
      const userString = localStorage.getItem('currentUser')
      if (userString) {
        const userData = JSON.parse(userString)
        this.$store.commit('auth/SET_CURRENT_USER', userData)
      }
    },
  }),
  //
});
```

`created()`...Vueのライフサイクルの１つであり、コンポーネントが作成された後に実行する処理を指定できる。localStorgeからcurrentUserの値を取得する。

次に、`PageUserLogin.vue`から`import axios from 'axios'`の記述を取り除き、以下のようにする

```vue
async login() {
  if (this.$refs.form.validate()) {
    try {
      const sessionParams = {
        session: {
          email: this.email,
          password: this.password,
        }
      }
      await this.$store.dispatch('auth/login', sessionParams)
      //
    }
  }
}
```

`await this.$store.dispatch('auth/login', sessionParams)`...`dispatch`は直接actionsで定義したアクションを実行するメソッド。第一引数に実行するアクションを、第二引数にそのアクションの引数を、第三引数にオプションを指定できる。`auth`以下のファイルで定義した`login`アクションを実行させる

<br>

## ログアウト機能

`app.vue`

```vue
<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" app>
      <v-list dense>
        <v-list-item to="/" link>
          //
        </v-list-item>

        <v-list-item link v-if="$store.getters['auth/currentUser']">
          <v-list-item-action>
            <v-icon>mdi-accont</v-icon>
          </v-list-item-action>

          <v-list-item-content>
            <v-list-item-title @click="logout">ログアウト</v-list-item-title>
          </v-list-item-content>
        </v-list-item>

        <v-list-item to="/login" link v-else>
          <v-list-item-action>
            <v-icon>mdi-account</v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title>ログイン</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
    //
  </v-app>
</template>

<script>
export default {
  //
  methods: {
    logout() {
      if (confirm('ログアウトしますか?')) {
        this.$store.dispatch('auth/logout');
      }
    }
  },
  //
};
</script>
```

`auth/index.js`において、logoutの際にSET_CURRENT_USER: nullとしていた箇所をCLEAR_CURRENT_USER処理に変更する

```js
const mutations = {
  SET_CURRENT_USER: (state, user) => {
    state.curretUser = user;
    localStorage.setItem('currentUser', JSON.stringify(user));
    axios.defaults.headers.common['AUthorization'] = `Bearer ${user.token}`
  },
  CLEAR_CURRENT_USER: () => {
    state.currentUser = null;
    localStorage.removeItem('currentUser');
    location.reload();
  }
};

const actions = {
  logout({ commit }) {
    commit('CLEAR_CURRENT_USER')
  }
};
```

`location.reload()`...現在のページの際読み込みを行うメソッド

<br>

## フォームのバリデーション追加

`PageUserLogin.vue`

```vue
<template>
  <v-text-field
    v-model="password"
    :rules="passwordRules"
    label="Password"
    requried
    prepend-icon="mdi-lock"
    type="password"
  ></v-text-field>
</template>

<script>
//
methods: {
  passwordRules() {
    return [
      v => !!v || 'Password is required',
    ]
  },
}
</script>
```

<br>

`PageUserRegister.vue`

```vue
<v-text-field
  v-model="password"
  :rules="passwordRules"
  //
></v-text-field>

<v-text-field
  v-model="passwordConfirmation"
  :rules="passwordConfirmationRules"
  //
></v-text-field>

<script>
//
methods: {
  passwordRules() {
    return [
      v => !!v || 'Passworc is required',
    ]
  },
  passwordConfirmationRules() {
    return [
      v => !!v || 'PasswordConfirmation is required',
      this.password === this.passwordConfirmation || 'Password must match'
    ]
  },
};
</script>
```
