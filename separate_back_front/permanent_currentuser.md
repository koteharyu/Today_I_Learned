# 認証情報の永続化

ページの更新などをした際に認証情報がリセットされてしまっていたため、試行錯誤

## 現状

サーバーサイド側で、JWTでの認証機能を実装済みとする。

`/src/store/modules/auth.js`ファイルにて`currentUser`という定数で認証情報を管理していく

```js
import axios from 'axios';

const apiUrl = 'http://localhost:3000';

const state = {
  currentUser: null,
};

const getters = {
  currentUser: (state) => state.currentUser,
};

const mutations = {
  SET_CURRENT_USER: (state, user) => {
    state.currentUser = user;
    localStorage.setItem('currentUser', JSON.stringify(user));
    axios.defaults.headers.common['Authorization'] = `Bearer ${user.token}`;
  },
};

const actions = {
  async login({ commit }, sessionParams) {
    const res = await axios.post(`${apiUrl}/api/session`, sessionParams);
    commit('SET_CURRENT_USER', res.data.user);
  },
  logout({ commit }) {
    commit('SET_CURRENT_USER', null);
  },
};

export default {
  namespaces: true,
  state,
  getters,
  actions,
  mutations,
};
```

`localStorage.setItem`...localstorage内で管理するitem名を`currentUser`に設定

一件問題なさそうに思えるが、なぜページの更新を行うとcurrentUserのデータがなくなってしまうのか...

それは!!

## main.js

エントリーポイントである`main.js`を全く持って無視していたからだった

つまり、ページの更新をした際行われる処理として、第一にmain.jsを参照され、それぞれのコンポーネントなどが生成される。そんなmain.jsにlocalstorageから値を持ってきて再度auth.jsの処理を行わせる記述をしていないことが原因だった。

`main.js`

```js
import Vue from 'vue';
import App from './App.vue';

new Vue({
  created() {
    const userString = localStorage.getItem('currentUser');
    if (userString) {
      const userData = JSON.parse(userString);
      this.$store.commit('SET_CURRENT_USER', userData);
    }
  },
  render: (h) => h(App),
}).$mount('#app');
```

この記述を加えることで、更新後もcurrentUserに値がセットされたまま処理を続行することができるようになった
