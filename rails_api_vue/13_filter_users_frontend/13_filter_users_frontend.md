# 13_filter_users_frontend

## qs

`qs`...セキュリティ強化されたクエリ文字列の解析及び文字列化ライブラリ

`$ yarn add qs`コマンドで導入

#### 基本的な使用方法

`parse`メソッド...クエリ文字列をparse関数に渡すと、オブジェクトを返す

```js
import qs from 'qs';
const parseStr = qs.parse('takasi=man&kanako=woman');
console.log(parseStr);
#=> { takasi: "man", kanako: "woman" }
```

<br>

`stringify`メソッド...オブジェクトからクエリ文字列を生成するメソッド

```js
const userObj = {
  user: {
    name: 'takasi',
    email: 'takasi@example.com'
  }
}

const queryStr = qs.stringify(userObj)
#=> user[name]=takasi&user[email]=takasi@example.com
```


## params[:q]

バックエンド側の絞り込み機能実装時に、検索文字列やタグの選択を`params[:q]&.permit(:name, tag_ids: [])`で受け取るように設定しているため、次はフロント側で辻褄を合わせていく

```vue
<template>
<!---簡易版-->
  <v-card class="mb-3">
    <v-card-text>
      <header>絞り込み条件</header>
      <v-row dense justify="start">
        <template>
          <v-checkbox v-for="tag in tags"
                      :key="tag.id"
                      v-model="query.selectedTags"
                      :label="tag.name"
                      :value="tag.id"
                      class="mr-5"
                      @click.native="fetchUsers"
                      hide-details="auto"
          >
          </v-checkbox>
        </template>
      </v-row>
      <v-row>
        <template>
          <v-col cols="12">
            <v-text-field label="UserName" v-model="query.userName" @input="fetchUsers"></v-text-field>
          </v-col>
        </template>
      </v-row>
    </v-card-text>
  </v-card>
</template>
<script>
//
data() {
  return {
    query: {
      userName: '',
      selectedTags: [],
    }
  },
},
methods: {
  async fetchUsers() {
    const searchParams = {
      q: {
        name: this.query.userName,
        tag_ids: this.query.selectedTags
      }
    }
    const pagingParams = { page: this.currentPage }
    const params = { ...searchParams, ...pagingParams }
    const paramsSerializer = (parasm) => qs.strigify(params, { arrayFormat: 'brackets' })
    const res = await axios.get(`/api/users`, { params, paramsSerializer })
  }
}
</script>
```

`query`というハッシュ型のデータを用意し、ここでタグとユーザー名を受け取るようにする。よって`v-model="this.query.selectedTags"`, `v-model="query.userName"`とバインドすることができる

`const searchParams`...ここが`params[:q]`の辻褄合わせ。`name`, `tag_ids`を受け取る

`fetchUsers`...タグを選択された時・検索フォームにnameが与えられた時に実行されるメソッド。

`paramsSerializer`...通常はGETリクエストのクエリパラメータには`Strting`型に変換された値が含まれる。userNameだけの絞り込みだとこれでも良いが、今回のように複数のタグでも絞り込むなど`Object型`を含みたい場合に使用するオプション

以下のような処理の流れなイメージ

```js
const params = {
  name: 'takasi',
  tag_ids: {
    1,
    3
  }
}

const paramsSerializer = (params) => qs.stringify(params)
axios.get(`/api/users`, { params, paramsSerializer })

console.log(req.query);
#=> {
  name: 'takasi',
  tag_ids: {
    1,
    3
  }
}
```

## 修飾子 native

`@click.native`...親要素でおきたイベントをトリガーにして子のメソッドを実行したい場合に使用する。解釈としては、タグの数だけ`v-for`で要素を増やしているためその親に`native`をつけている。

#### イベント修飾子について

Vue.jsが提供しているメソッド

#### stop

`.stop`...event.stopPropagation()を呼ぶためのメソッド。DOMがネストしている場合に、親要素に向かってイベントが連鎖・伝搬する。

```
<div @click="stopTest">
  <div @click.stop="stopTest">
    stopTestButton
  </div>
</div>
```

このようなネストしたDOMの場合、親要素に向かって`stop`が伝搬されるため、`stop`指定した子要素のstopTestイベントは実行されず、親要素のstopTestイベントだけ実行されるようになる

#### prevent

`.prevent`...event.preventDefault()を呼ぶためのメソッド。直訳するとデフォルトのイベントを妨げる。つまり定義されているイベントを無視するということ

```
<a @click.prevent="toGoogle" href="https://google.com">Google</a>
```

上記のようにすることで、本来googleへ飛ばす処理が無視されることになる
