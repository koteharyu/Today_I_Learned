# rails + vue = calendar

## curl

```
$ curl -X POST -d '{"name": "curlから作成した予定", "start": "2020-10-11 10:00:00", "end": "2020-10-11 11:00:00"}' -H "Content-Type: application/json" http://localhost:3000/events
```

`-X`...使用するHTTPメソッドを指定する

`-d`...送信するパラメーターの値の指定

`-H 'Content-Type: applicaiton/json'`...JSONデータを送信することの宣言

`URL`...最後に送信先のURLを指定

## Vue導入

- vue-cliのコマンドでVue.jsのプロジェクトを作成する
  - プロジェクトの設定を聞かれるので１つずつ答えていく
- Vue.jsのサーバーを起動してブラウザでウェルカム画面を確認する

`$ npm install -g @vue/cli@4.5.3`...Vue-cliのインストール

`$ vue create frontend`コマンドでfrontendというディレクトリを作成する

1. Manually selectfeatures...利用するプリセットを自分で決めるための
2. 「Vuex」「Linter/Formatter」...プロジェクトで使用するライブラリの設定
   1. スペースキーで選択・解除ができる
3. 「ESlint + Prettier」...linter/formatterの設定
4. 「Lint on save」...リントするタイミング
5. 「In dedicated config files」...ESlintなどの設定ファイルを集約するか各設定ファイルで分けるかの設定
6. 「N」...今回選択した設定ファイルをプリセットとして保存しておくか
7. 「Use NPM」...パッケージ管理としてNPMを使うように設定

`$ npm run serve`...サーバーを起動。`serve`であることに注意!!

`localhost:8080`にアクセスするとvueのウェルカム画面が見れる

## コンポーネント

vueでは複数のコンポーネントを作成し、それらを組み合わせて１つのページを構築する

１つのコンポーネントは、`template`, `script`, `style`のブロックを定義することができる

`template`...コンポーネントの見た目を定義するブロック

`script`...コンポーネントの処理を定義するブロック。JavaScriptで記述し、`export default`の中にvueの処理を記述する

`style`...コンポーネントのCSSを定義するブロック

## 親コンポーネント

`scr/App.vue`...このコンポーネントが全てのコンポーネントの親となる

scriptブロック内で、importするコンポーネントを記述し、`components`キーの値にそのimportするコンポーネントを指定する

## how to use

### data

`data`...コンポーネントで扱う変数とその値を定義する。

```js
data: () => ({
  message: 'Hello World'
}),
```

`() => ({ ... })`の内部に`変数: 値`の記法で定義する

### v-if

templateブロックの中で条件分岐して表示を変えることができる

```js
<div v-if="条件式">
  // Content
</div>
<div v-else>
// Content
</div>
```

### v-for

templateブロックの中で配列の各値をfor文で表示することができる

```vue
<template>
  <div>
    <ul>
      <li v-for="item in items" :key="item.id">
        {{ item.text }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  data: () => ({
    items: [
      { id: 1, text: "item 1"},
      { id: 2, text: "item 2"},
      { id: 3, text: "item 3"},
    ],
  }),
};
</script>
```

`item in items`で`items`変数の各要素が`item`変数に代入される

`v-for`を使うときは`key`属性に一意な値を指定することが推奨されている

`:key="item.id"`を指定すると、文字列ではなく変数`item.id`の値をkeyに指定することを意味することができる

ちなみに`:key"`...`v-bind:key`を省略した書き方

### @click

ユーザーがクリックした時に特定のメソッドを呼び出すことができる

```vue
<template>
  <div>
    <button @click="clickedEvent">ボタン</button>
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  methods: {
    clickedEvent() {
      console.log("clicked!");
    },
  },
};
</script>
```

コンポーネントのメソッドは、`methods`の中に定義する

### v-model

Vueには、双方向バインディングと呼ばれる、ユーザーからの入力とアプリケーションの状態を同期する機能が提供されている

```vue
<template>
  <div>
    <p>
      {{message}}
    </p>
    <input v-model="message">
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  data: () => ({
    message: "hello world"
  }),
};
</script>
```

フォームに何か入力すると、messageの値が入力と同期するようになる

### props

vueでは複数のコンポーネントを組み合わせて１つのページを構築している

`props`...親のコンポーネントの値を子のコンポーネントに渡したい時に使う

```vue
HelloWorld.vue

<template>
  <div>
    <p>
      {{message}}
    </p>
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  props: ['message'], // 親コンポーネントからmessageを受け取る
};
</script>
```

```vue
App.vue

<template>
  <div id="app">
    <HelloWorld message="this is props test"/> <!-- messageの値を渡す -->
  </div>
</template>

<script>
import HelloWorld from "./components/HelloWorld.vue";

export default {
  name: "App",
  components: {
    HelloWorld,
  },
};
</script>
```

## Prettier

`prettier`...JavaScriptでよく使われているコードフォーマッター

`package.json`の`script`の中に`npm run`で実行したいコマンドを定義することができる

`frontend/package.json`ファイルを以下のように編集

```json
"scripts": {
  "lint": "vue-cli-service lint",
  "prettier": "prettire --write '.src/**/*.{vue.js}'"
}
```

`npm run prettier`コマンドを実行すると`prettire --write '.src/**/*.{vue,js}'`が実行されるというわけ

`--write`オプション...整形する対象とするファイルを指定し、`src`ディレクリ以下の拡張子が`.vue`or`.js`のファイルを整形対象とする

### オプション指定

`frontend/.prettierrc`ファイルを新規作成し、JSON形式で以下のように記述する

```json
{
  "singleQuote": true,
  "printWidth": 140,
  "trailingComma": "all"
}
```

`"singleQuote": true`...文字列を囲う時はシングルクォートにするオプション

`"printWidth": 140`...1行の文字数が140以上の場合は改行させるオプション

`"trailingComma": "all"`...配列の最後の要素などの末尾にカンマを入れるオプション

## axios

`axios`...APIを呼び出してデータを取得するためのライブラリ

`$ npm install --save axios`

`--save`...package.jsonのdependenciesに登録させるオプション。npm5.0以降だとデフォルトでこのオプションが付くようになったとのこと

> git にコミットする際、パッケージをインストールしているフォルダ node_modules は .gitignore によって除外されます。
違う開発環境を git からクローンして構築する場合、package.json を元に復元します。
よって、同じパッケージ環境を簡単に構築することができます。

```vue
<template>
  <div>
    <h1>Calendar</h1>
    <p>events:</p>
    <p>
      {{ events }}
    </p>
    <button type="submit" @click="fetchEvents()">
      fetchEvents
    </button>
  </div>
</template>

<script>
import axios from 'axios'; // axiosをインポート

export default {
  name: "Calendar",
  data: () => ({
    events: []
  }),
  methods: {
    fetchEvents(){
      // GETリクエストを送信し、取得したデータをevents変数に代入する
      axios
        .get('http://localhost:3000/events')
        .then((response) => {
          this.events = response.data;
        })
        .catch((error) => {
          console.error(error)
        });
    }
  }
};
</script>
```

現状のまま`fetchEvents`ボタンを押しても何も取得できず、このようなエラーが発生しているだろう

[![Image from Gyazo](https://i.gyazo.com/c76c1019980e08976c731f7c561d513d.png)](https://gyazo.com/c76c1019980e08976c731f7c561d513d)

### cors

`cors`...Cross-Origin Resource Sharing。異なるオリジン間でリソースを共有したい時に、自身とは異なるオリジンにリソースへにアクセスを許可するための仕組み。

このcorsの設定を行わないと、Railsは他のオリジンからのアクセスを拒否するため、API通信を行うことができないため、`localhost:8080`からのリクエストを許可する設定をする必要がある

### cors設定 in Rails

Gemfile内にコメントされた`rack-cors`があるので、それをコメントアウトし、bundle install

```gemfile
gem 'rack-cors'
```

次に、`backend/config/initializers/cors.rb`ファイルを以下のようにする

```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:8080'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

## Vuex

`Vuex`...Vue.jsアプリで最もよく使われている状態管理ライブラリ。コンポーネント間で状態を共有するための仕組みを提供する

`ストア`...状態管理において、データの集約先のこと。どのコンポーネントからもストアを参照できるようにすることで、値の受け渡しをシンプルにする

### Flux

`Flux`...Vuexにて使われている状態管理のアーキテクチャのこと。一方通行のデータフローのアーキテクチャ

[![Image from Gyazo](https://i.gyazo.com/e34353837a1446fa0f5307b4356e3711.png)](https://gyazo.com/e34353837a1446fa0f5307b4356e3711)

- 管理しているデータは「State」が保持しており、コンポーネントはこのStateを参照して(renderして)値を取得する
- Stateで管理しているデータの値を変更する場合は、直接Stateを更新するのではなく、Actionを呼び出す(dispatchする)ことで指示を与える
- ActionはAPIを呼び出してデータを取得するなどの非同期処理を行う
  - ActionではまだStateを変更せず、Mutationの呼び出し(commit)を行う
- MutationではActionから値を受け取り、Stateの更新(mutate)を行う
  - Stateの値を更新できるのはこのMutationのみ

このように、状態を変化させる処理を「Action」「Mutation」「State」に役割分担させ、データを循環させるように管理するアーキテクチャをFluxと呼ぶ

### storeの作成

Vuexを使って複数のコンポーネント間でデータを共有するために、`store`を用意する

`frontend/src/store/modules/events.js`ファイルを作成する

```js
import axios from 'axios';

const apiUrl = 'http://localhost:3000';

const state = {
  events: []
};

const getters = {
  events: state => state.events
}

const mutations = {
  setEvents: (state, events) => (state.events = events)
}

const actions = {
  async fetchEvents({ commit }) {
    const response = await axios.get(`${apiUrl}/events`);
    commit('setEvents', response.data);  // mutationを呼び出す
  }
}

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
};
```

「state」「getters」「mutations」「actions」の４つが必要

`state`...状態管理するデータを定義

`getters`...stateの値を取り出す関数を定義する

`mutations`...eventsデータをstateに保存する関数を定義する

`actions`...axiosでAPIリクエストを送信してeventsデータを取得し、mutationを呼び出す関数を定義する

### store/index.js

次に`frontend/src/store/index.js`を以下のように編集する

```js
import Vue from 'vue';
import Vuex from 'vuex';
import events from './modules/events';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    events
  }
});
```

`Vuex.Store`の中の`modules`に`events.js`からexportしたものを入れることで、eventsストアが利用可能になる

### Vuexのヘルパー

Vuexには`mapGetters`, `mapActions`などの便利なヘルパーがあり、ストア名と関数名を指定することでそれらを使用できるようになる

#### 1.状態を呼び出す

- `mapState`
- `mapGetters`

`computed`内に記述する

#### 2.状態を変化させる

- `mapMutations`
- `mapActions`

`methods`内に記述する

### コンポーネントへの反映

```vue
Calendar.vue

<script>
import { mapGetters, mapActions } from 'vuex';
import CalendarDetails from './CalendarDetails.vue';

export default {
  name: 'Calendar',
  components: {
    CalendarDetails,
  },
  computed: {
    ...mapGetters('events', ['events']),
  },
  methods: {
    ...mapActions('events', ['fetchEvents'])
  }
}
</script>
```

ボタンを押すと、mapActionsでimportしたストアのfetchEventsアクションが実行されてデータを取得し、stateに保存される

stateに保存された値をmapGettersでimportしたeventsゲッターで取得し、ビューに表示させる

```vue
CalendarDetails.vue

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'CalendarDetails',
  computed: {
    ...mapGettres('events', ['events'])
  },
  methods: {
    ...mapActions('events', ['fetchEvents'])
  }
}
</script>
```

## Vuetify

`Vuetify`...Vue,jsで使用できるマテリアルデザインのUIフレームワーク。レイアウトを構築するグリッドシステムから、ボタンなどの細かいパーツまで幅広くUIを提供している

`$ vue add vuetify`コマンドでvuetifyをインストールする。なお、質問には以下のように回答する

1. y
2. Default

サーバーを再起動させ、再度localhost:8080にアクセスするとvuetifyのウェルカム画面が表示されればOK

ただし、既存のコード(src/App.vue)が書き変わってしまうことに注意。

Vuetifyを使用するためには、`<v-app>`タグで全体を囲う必要がある

```vue
src/App.vue

<template>
  <v-app>
    <v-main>
      <Calendar/ >
    </v-main>
  </v-app>
</template>

<script>
import Calendar from './components/calendar';

export default {
  name: 'App',
  components: {
    Calendar
  }
};
</script>
```

### Vuetifyのコンポーネントを使って書き換え

```vue
Calendar.vue

<template>
  <div>
    <h1 class="text-h1">Calendar</h1>
    <v-list>
      <v-list-item v-for="event in events" :key="event.id">
        {{ event.name }}
      </v-list-item>
    </v-list>
    <v-btn type="submit" @click="fetchEvents()">fetchEvents</v-btn>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'Calendar',
  computed: {
    ...mapGeetters('events', ['events]),
  },
  methods: {
    ...mapActions('events', ['fetchEvents']),
  }
};
</script>
```

`v-list`...vuetifyでの`ul`

`v-list-item`...vuetifyでの`li`

## Calendar

`v-calendar`...vuetifyが提供するカレンダーのコンポーネント

```vue
<v-sheet height="1--vh">
  <v-calendar></v-calendar>
</v-sheet>
```

## APIから受け取ったイベントデータの加工

現状だと、受け取ったJSON形式のイベントデータのstart, endは文字列となっているため、Date型に変換させたい。ちなみに、Vuexではストアで管理している値をコンポーネントに渡すために`getters`を定義してるため、このメソッドを編集する

```js
// src/store/modules/events.js

const getters = {
  events: state => state.events.map(event => {
    return {
      ...event,
      start: new Date(event.start),
      end: new Date(event.end)
    };
  }),
};
```

`...`...スプレッド構文。

```js
// 例

x = { a: 100, b: 200, c: 300 }
{ a: 100, b: 200, c: 300 }

y = { ...x, c: 500}
{ a: 100, b: 200, c: 500 }
```

returnで新しいオブジェクトを作って返すのだが、その新しいオブジェクトの要素として、eventオブジェクトの要素を展開して入れる。その後に、start要素を`new Date(event.start)`で上書きしている。(endも同様)

```vue
Calendar.vue

<template>
  <div>
    <v-sheet height="100vh">
      <v-calendar v-model="value" :events="events" @change="fetchEvents"></v-calendar>
    </v-sheet>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'Calendar',
  data: () => {
    value: new Date('2020-10-01') // 表示する月を指定
  },
  computed: {
    ...mapGetters('events', ['events']),
  },
  methods: {
    ...mapActions('events', ['fetchEvents']),
  },
};
</script>
```

`:events`...ストアから取得したイベントデータを表示させる

`@change`...ストアの`fetchEvents`アクションを指定する

## date-fns

`date-fns`...Date型の処理を簡単に扱うためのライブラリ

`$ npm install date-fns --save`

```vue
Calendar.vue

<template>
  <div>
    <v-sheet height="6vh" class="d-flex" align-center>
      <v-btn outlined small class="ma-4" @click0"setToday">今日</v-btn>
      <v-btn icon @click="$refs.calendar.prev()">
        <v-icon>mdi-chevron-left</v-icon>
      </v-btn>
      <v-btn icon @click="$refs.calendar.next()">
        <v-icon>mdi-chevron-right</v-icon>
      </v-btn>
      <v-toolbar-title>{{ title }}</v-toolbar-title>
      <v-sheet height="94vh">
        <v-calendar
          ref="calendar"
          v-model="value"
          :events="events"
          @change="fetchEvents"
          locale="ja-jp"
          :day-format="(timestamp) => new Date(timestamp.date).getDate()"
          :month-format="(timestamp) => (new Date(timestamp.date),getMonth() + 1) + ' /'"
          ></v-calendar>
      </v-sheet>
    </v-sheet>
  </div>
</template>

<script>
import { format } from 'date-fns'
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'Calendar',
  data: () => ({
    value: new Date('2020-10-01'),
  }),
  computed: {
    ...mapGetters('events', ['events']),
    title() {
      return format(this.value, 'yyyy年 M月');
    },
  },
  methods: {
    ...mapActions('events', ['fetchEvents']),
    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd')
    },
  },
};
</script>
```

`$refs.calendar.prev()`...v-calendarに`ref="calendar"`を指定することで、`$refs.calendar.メソッド()`で`<v-calendar>`に定義されているメソッドを呼び出すことができる

`prev()`, `next()`...Vuetifyのカレンダーコンポーネントで定義されているメソッドで、`value`の値を前の月の最終日/次の月の初日に変更できる

`format`...date-fnsのヘルパー

`locale`...カレンダーで使用する言語の指定

## 予定をクリックしたらアラートを表示させる

`@click:event="showEvent"`...`<v-calendar>`の属性に指定し、`methods`内に`showEvent({event}) { alert(event.name) }`を記述する

showEventメソッドを新たに作り、`@click:event`にそのメソッドを指定する。`event`は引数。

## ダイアログの表示

ダイアログ...ユーザーに入力を求めたり、何かを通知するための小さなウィンドのこと

```vue
Calendar.vue

....
</v-sheet>

<v-dialog :value="dialogMessage !== ''">
  <h1> {{ dialogMessage}} </h1>
</v-dialog>

<script>
export default {
  ///
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
    dialogMessage: '',
  }),
  methods: {
    showEvent( {event}) {
      this.dialogMessage = event.name
    }
  }
}
</script>
```

`dialogMessage`変数を用意し、`showEvent`が呼ばれたら変数に予定名を代入する。

ダイアログの表示は`<v-dialog>`を使用する。`:value`には、表示したい時はtrue, 表示したくない時はfalseとなる条件式を指定する。

今回は、初期状態ではダイアログが表示されず、予定をクリックした時にdialogMessageに値が代入されてダイアログが表示されるようになる。

## Vuexストアへの機能追加

ダイアログにイベントの詳細情報を表示させるため、eventsストアを編集し、クリックされた予定を保持するためのステートを追加し、そのステートを取得するためのゲッターを追加する。さらに、ステートを更新するためのアクションとミューテーションも追加する。

`modules/events.js`

```js
import axios from 'axios';

const apiUrl = 'http://localhost:3000';

const state = {
  events: [],
  event: null,
};

const getters = {
  events: state => state.events.map(event => {
    return {
      ...event,
      start: new Date(event.start),
      end: new Date(event.end)
    };
  }),
  event: state => state.event ? {
    ...state.event,
    start: new Date(state.event.start),
    end: new Date(state.event.end)
  } : null,
};

const mutations = {
  setEvents: (state, events) => (state.events = events),
  setEvent: (state, event) => (state.event = event),
};

const actions = {
  async fetchEvents({ commit }) {
    const response = await axios.get(`${apiUrl}/events`);
    commit('setEvents', response.data);
  },
  setEvent({ comit }, event) {
    commit ('setEvent', event);
  },
};
```

eventステートの初期値はnullにしておく。

eventデータを取得する時は、eventsと同様に、startとendをDate型に変換させる。

setEventアクションはsetEventミューテーションを呼び出すだけで、APIリクエストを送るなどはしない。

## 予定の詳細を表示させる

```vue
<template>
<!-- 省略 -->
    <v-dialog :value="event !== null">
      <div v-if="event !== null">
        <v-card>
          <h1>イベント詳細</h1>
          <p>name: {{ event.name }}</p>
          <p>start: {{ event.start }}</p>
          <p>end: {{ event.end }}</p>
          <p>timed: {{ event.timed }}</p>
          <p>description: {{ event.description }}</p>
          <p>color: {{ event.color }}</p>
        </v-card>
      </div>
    <v-dialog>
  </div>
</template>

<script>
import { format} from 'date-fns';
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'Calendar',
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
  }),
  computed: {
    ...mapGetters('events', ['events', 'event']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
  },

  methods: {
    ...mapActions('events', ['fetchEvents', 'setEvent']),
    setToday(){
      this.value = format(new Date(), 'yyyy/MM/dd')
    },
    showEvent({ event }) {
      this.setEvent(event);
    },
  }
};
</script>
```

`...mapGetters('events', ['events', 'event'])`, `...mapActions('events', ['fetchEvents', 'setEvent'])`...Vuexストアに追加したステートとアクションを呼び出して使用できるようにする

`showEvent({ event }) {this.setEvent(event);}`...showEventメソッドを呼び出したらsetEventアクションを実行するようにして、ストアにイベントデータを保持させる

## 見た目

#### v-car

`v-card`には`v-card-title`,`v-card-subtitle`,`v-card-text`,`v-card-actions`と４つの子コンポーネントが用意されている

#### width

`width="600"`のように指定する

#### padding

`class="pb-16"`のように指定する

`{プロパティ}{向き}-{サイズ}`...公式

`a`...all

#### 中央よせ

`class="d-flex justify-center align-center"`...コンポーネントの子要素を中央寄せにできる

#### カラム

`v-row`,`v-col`を使ってカラムを構築

```vue
<v-row>
  <v-col cols="2">first col</v-col>
  <v-col>second col</v-col>
</v-row>
```

#### icon

`v-icon`

[このサイトが利用可能](https://materialdesignicons.com/)

## ダイアログを閉じる

`closeDialog`メソッドを定義し、呼ばれたらsetEventにnullを代入する

`@click:outside="closeDialog"`...ダイアログの外側をクリックしても閉じるように

## コンポーネントの分離

`<slot></slot>`...コンテンツの受け渡しの際に使う

呼び出しがわで`<DialogSection><p>hoge</p></DialogSection>`と書くと、slotの部分が`<p>hoge</p>`に書き換わる。

コンポーネント分離のメリット

- １つのファイルのコード量が減り、見通しがよくなる
- コンポーネントの持つ役割がはっきりする
- コンポーネントの影響範囲が小さくなり、修正しやすくなる
- コンポーネントを複数の箇所で使いまわせる

## EventFormDialog

`<v-text-field v-model="name" label="タイトル">`...フォームに何かを入力した時に`name`変数にその値が代入される

## appendEvent

次に、予定の作成処理を行う。

```js
events.js

const actions = {
  async createEvent({ commit }, event) {
    const response = await axios.post(`${apiUrl}/events`, event);
    commit('appendEvent', response.data);
  }
}

const mutations = {
  appendEvent: (state, event) => (state.events = [...state.events, event])
}
```

予定の作成処理として`createEvent`を新たに定義。第二引数にこのアクションを呼び出すときの引数が代入される。つまり新規のevent。

`axios.post`でeventデータをパラメーターとしてPOSTリクエストを送る。responseにはデータベースに登録されたeventデータが代入される。このデータを`appendEvent`にmutateする。

mutationsに置ける、appendEvent内のevent変数には新規作成したイベントのレスポンスデータが入る。

`[...state.events, event]`...state.events配列の末尾に新規作成したeventデータを追加することができる。

eventsステートはカレンダーに予定を表示するために使われているため、このステートを更新することでカレンダーにも予定が反映される仕組み。

## 保存ボタン

```vue
EventFromFialog.vue

</v-card-text>
<v-card-actions class="d-flex justigy-end">
  <v-btn @click="submit">保存</v-btn>
</v-card-actions>
//

<script>
import { mapGetters, mapActions } from 'vuex';
import DialogSection from './DialogSection';

export default {
  name: 'EventFormDialog',
  components: {
    DialogSection,
  },
  data: () => ({
    name: '',
  }),
  computed: {
    ...mapGetters('events', ['setEvent', 'setEditMode', 'createEvent']),
    closeDialog() {
      this.setEditMode(false);
      this.setEvent(null);
    },
    submit() {
      const params = {
        name: this.name,
        start: this.event.start,
        end: this.event.end
      };
      this.createEvent(params);
      this.closeDialog();
    },
  },
};
</script>
```

新規登録のためのsubmitメソッドを追加。

paramsにはPOSTリクエストを送るためのパラメータを入れる。

`this.name`...`v-text-field`におけるnameから取得

`this.event`...Calendarコンポーネントの`initEvent`メソッドでセットした値が入っており、そのstartとendをそれぞれ取得する。

`createEvent`アクションを呼び出し、paramsの値を持つ新しいイベントデータを作成し、`closeDialog`メソッドでダイアログを非表示にする。

## DatePicker

`DatePicker`...Vuetifyが提供する日付選択ライブラリ

日付選択部分を別のコンポーネント(DateForm.vue)に切り分ける

```vue
DateForm.vue

<template>
  <v-menu offset-y>
    <template v-slot:activator="{ on }">
      <v-btn text v-on="on">{{  value || '日付を選択'}}</v-btn>
    </template>

    <v-date-picker
      :value="value.replace(/\//g, '/')"
      @input="$emit('input', $event)"
      no-title
      locale="ja-jp"
      :day-format="value => new Date(value).getDate()"
    ></v-date-picker>
  </v-menu>
</template>

<script>
export default {
  name: 'DateForm',
  props: ['value'],
};
</script>
```

`v-date-picker`...Vuetifyが提供する日付選択カレンダー

`v-model`に`startDate`変数を指定することで、カレンダーで選択した日付の値がこの変数に代入される。`locale`,`:day-format`で日本語表記に変更している

`startDate: ''`...nullだと`read property 'replace' of null`エラーが出たため、初期値を文字列の空文字にすることで解決。

`props`にvalueを指定することで、親コンポーネントとのやりとりで使う変数を宣言。propsで受け取る値は変更不可能なため、`v-model="value"`と書くことはできない。そのため、`:value`はpropsから受け取る値を保持する変数、`@input`はその変数(:value)の値が更新された時に呼び出されるようにする。

`$event`...DatePickerで選択した日付が入る

`$emit('input', $event)`を実行すると親コンポーネントの値を更新する

`v-menu`...DatePickerをメニュー形式で表示させる

`template`...そのメニュー(v-menu)を表示する(有効にする)部分

`v-slot:activator`は、`v-menu`のactivatorというスロットを指す。`v-slot:activator="{ on }"`は、activatorスロットから`on`というプロパティを取得している。これを`v-btn v-on="on"`と指定することで、このボタンがクリックされた時にactivatorスロットを経由してメニューが有効になる流れ

#### v-model

`v-model`...`:value`, `@input`の指定を省略した記法。つまり、下記は＝である

```vue
<input v-model="searchText">

上と下は同意

<input
  :value="searchText"
  @input="seachText = $event.target.value"
>
```

`:value`...searchText変数の値を読み込んでフォームを表示するためのプロパティ

`@input`...フォームの値が変更された時に実行する処理を指定するプロパティ

`$event.target.value`...そのフォームに入力された値が入り、その値をsearchTextに代入する。ただし、カスタムコンポーネント(今回のようなDateForm)で使用する場合は、`$event`を使用する

## クリックした日付をカレンダーのデフォルトに

```vue
<template>
  <DateForm v-model="startDate" />
  <DateForm v-model="endDate" />
</template>

<script>
import { format } from 'date-fns';

export default {
  //
  data: () => ({
    startDate: '',
    endDate: '',
  }),
  computed: {
    ...mapGetters('events', ['event']),
  },
  created() {
    this.startDate = format(this.event.start, 'yyyy/MM/dd');
    this.endDate = format(this.event.end, 'yyyy/MM/dd')
  },
  submit() {
    const params = {
      name: this.name,
      start: this.event.start,
      end: this.event.end
    },
    //
  }
}
</script>
```

`created`...Vueのライフサイクルの１つであり、コンポーネントが作成された後に実行する処理を指定できる。

dataで初期化した変数startDate, endDateに、カレンダーでクリックした時の日付を文字列に変換し代入している。`this.event.start(end)`は、CalendarコンポーネントのinitEventメソッドでeventステートに代入した値を取得している

## Vuelidate

frontendディレクトリ内で`$ npm install vuelidate --save`コマンドを実行

```vue
EventFormDialog.vue

<script>
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';

export default {
  mixins: [validationMixin],
  //
  data: () => ({
    //
  }),
  validations: {
    name: { required },
    startDate: { required },
    endDate: { required },
  },
  //
};
</script>
```

Vuelidateライブラリの`validationMixin`というmixinをimportし、`mixins`でそれを指定する。

mixinオブジェクトで記述したcreatedの処理がコンポーネントに混ぜ込まれて実行される。`validationMixin`はVuelidateライブラリが提供するmixinオブジェクトなため、これをminxinmに指定することでVuelidateの機能が使えるようになる。

コンポーネントのvalidationsにバリデーションを行いたい値と条件を指定する。ここでは、name, startDate, endDateの3つの値に対して入力必須の条件である`required`を指定する。

## 保存ボタンの非活性化

validationsの条件にマッチしない場合、保存ボタンを押せないようにする

```vue
EventFormDialog.vue

<v-btn :disabled="isInvalid" @click="submit">保存</v-btn>
//
<script>
//
computed: {
  ...mapGetters('events', ['event']),
  isInvalid() {
    return this.$v.$invalid;
  },
},
methods: {
  //
  submit() {
    if (this.isInvalid) {
      return
    }
    //
  }
}
</script>
```

computedにisInvalidメソッドを追加。`$v`は現在のバリデーションの状態を保持している。そのため`$v.$invalid`は指定したバリデーションのどれかがマッチしない場合trueを返す。つまり、バリデーションに引っかかったことを伝える。

`:disabled="isInvalid"`...バリデーションエラーが起きた場合、isInvalidがtrueになりdisabledによってボタンが非活性化となる。

## 日時のバリデーション

上記まででpresence: treuのバリデーションの実装が終わったため、続いては日時による矛盾に対策する

まずは、開始・終了日時を受け取り、それらを比較して正しい値であるかをtrue/falseで返すメソッド(isGreaterEndThanStart)を作成する

```js
// detetime.js

export const isGreaterEndThanStart = (startDate, startTime, endDate, endTime, allDay) => {
  if (allDay) {
    const start = new Date(startDate).getTime();
    const end = new Date(endDate).getTime();
    return end >= start;
  } else {
    const start = new Date(`${startDate} ${startTime}`).getTime();
    const end = new Date(`${endDate} ${endTime}`).getTime();
    return end > start;

  }
};
```

isGreaterEndThanStartメソッド...このメソッドは、allDayの値によって分岐させる。もしallDayがtrueの場合は時刻は無関係となるため日付だけで比較し、falseの場合は時間も含めて比較させる。もし終了日時が開始日時よりも後であればtrueを返すメソッド。

次に、isGreaterEndThanStartをimportさせる

```vue
EventFormDetail.vue

<script>
import { isGreaterEndThanStart } from '../fucntions/datetime';

export default {
  //
  computed: {
    ...mapGetters('events', ['event']),
    isInvalidDatetime() {
      return !isGreaterEndThanStart(startDate, startTime, endDate, endTime, allDay);
    },
    isInvalid() {
      return this.$v.$invalid || this.isInvalidDatetime;
    }
  }
}
</script>
```

computedに`isInvalidDatetime`メソッドを追加。isGreaterEndThanStartメソッドを反転させた値を返すため、もし終了日時開始日時よりも前であればtrueになる。

isInvalidメソッドにor条件を追加。

## エラー表示

不適切な日時であればそれがわかるようにスタイルを追加する

```vue
EventFormDialog.vue

<template>
  <DateForm v-model="endDate" :isError="isInvalidDatetime"/>
    <div v-show="!allDay">
      <TimeForm v-model="endTime" :isError="isInvalidDatetime" />
    </div>
</template>
```

isInvalidDatetimeは値の入力の状態によって動的に変化するため、`:isError`のようにv-bindで指定する

```vue
DateForm.vue

<template>
  <v-menu offset-y>
    <template v-slot:activator="{ on }">
      <v-btn text v-on="on" :class="{ 'red lighten-4 rounded' : isError }">
        {{ value || '日付を選択' }}
      </v-btn>
    </template>
    //
  </v-menu>
</template>

<script>
export default {
  name: 'DateForm',
  props: ['value', 'isError']
};
</script>
```

propsにisErrorを追加

`:class`...このような記法では、条件指定ができる。その条件を満たすときにclassを適用することができる。今回であれば、isErrorがtrueであればこのclassを適用させる。

TimeForm.vueコンポーネントも同様に修正

## 日付の日本語化

```js
// datetime.js

import { ja } from 'date-fns/locale';

export const formatDateToJa = date => {
  return format(new Date(date), 'M月d日(E)', { locale: ja });
};
```

日本語表記の日付を返す`formatDateToJa`メソッドを新たに定義

```
'2021-06-12' => '6月1日2(日)'
```

```vue
DateForm.vue

<v-btn text v-on="on" :class="{ 'red lighten-4 rounded' : isError }">
  {{ formatDateToJa(value) || '日付を選択' }}
</v-btn>

<script>
import { formatDateToJa } from '../functions/datetime';

export default {
  name: 'DateForm',
  props: ['value', 'isError'],
  methods: {
    formatDateToJa,
  },
};
</script>
```

テンプレート内で使用するため`methods`内に定義する。

## 削除機能

- Vuexストアに削除アクションを使い
- 予定詳細ダイアログに削除ボタンを表示
- 削除処理の追加

```js
// events.js

//
const mutations = {
  removeEvent: (state, event) => (state.events = state.events.filter(e => e.id !== event.id)),
  resetEvent: state => (state.event = null),
},

const actions = {
  async deleteEvent({ commit }, id) {
    const response = await axios.delete(`${apiUrl}/events/${id}`);
    commit('removeEvent', response.data);
    commit('resetEvent');
  },
};
```

actionsに`deleteEvent`アクションを追加。このアクションの引数に削除対象のevent.idを渡し、削除APIを叩く。APIを叩いた後、removeEvent, resetEventミューテーションを実行させる。

`removeEvent`...eventsステートから削除した予定だけを除く処理

`resetEvent`...eventステートにnullを代入することで、予定詳細ダイアログが閉じて最新のカレンダー画面が表示される

## 削除ボタン

```vue
EventDetailDialog.vue

<v-card-actions class="d-flex justify-end pa-2">
  <v-btn icon @click="del">
    <v-icon size="20px">mdi-trash-can-outline</v-icon>
  </v-btn>
</v-card-actions>

<script>
//
methods: {
  ...mapActions('events', ['setEvent','deleteEvent']),
  del() {
    this.deleteEvent(this.event.id);
  },
};
</script>
```

mapActionsから作成したdeleteEventを呼び出せるようにする。

`del`メソッド...deleteEventを呼び出すためのクリックイベント。削除するイベントは今詳細を表示している予定なため、削除するイベントのidは`this.event.id`で取得できる

## イベントの編集機能

- 編集ボタンを表示させる
- 編集ボタンの処理を追加する
- Vuexストアにイベントの更新アクションを追加する
- 更新処理を実行する
- キャンセルボタンの追加

```vue
EventDetailDialog.vue

<template>
  <v-card class="pb-12">
    <v-card-actions class="d-flex jutify-end pa-2">
      <v-btn icon @click="edit  ">
        <v-icon size="20px">mdi-pencil-outline</v-icon>
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
///
methods: {
  ...mapActions('events', ['setEvent', 'deleteEvent', 'setEditMode']),
  closeDialog() {
    this.setEvent(null);
  },
  del() {
    this.deleteEvent(this.event.id);
  },
  edit() {
    this.setEditMode(true);
  },
};
</script>
```

編集ボタンをリクックしたらeditメソッドを呼び出す処理を追加。

editメソッド...setEditModeアクションを実行し、isEditModeステートの値をtrueに変更させることで、イベント作成ダイアログを表示させる。

現状、編集ボタンを押すとそのイベントの時間や色が引き継がれている。これはなぜかというと、`EventFormDialig`コンポーネントの`created`で最初にeventステートの値を代入しているから。よって、name, descriptionなどもcreated時に代入させる

```vue
EventFormDialog.vue

<script>
///
created() {
  this.name = this.event.name;
  this.description = this.event.description;
}
</script>
```

createdにname, descriptionを追加し、eventステートの値を代入するように変更。

## vuexストアに更新アクションを追加

```js
// events.js

const mutations = {
  updateEvent: (state, event) => (state.events = state.event.map(e => (e.id === event.id ? event :e)));
};

const actions = {
  async updateEvent({ commit }, event) {
    const response = await axios.put(`${apiUrl}/events/${event.id}`, event);
    commit('updateEvent', response.data);
  },
};
```

actionsのupdateEventアクションで、更新のAPIを叩く。その後、mutatuonsのupdateEventを実行させる

mutationsのupdateEventアクションでは、更新されたイベントデータを取得し、eventsステートの中にある更新前のデータを更新後のデータに入れ替える処理をしている。よってカレンダーの画面に最新のデータが表示される。

## 更新処理

現状のイベントフォームが表示されるのは、「カレンダーで日付をクリックして新規作成フォームを表示させるパターン」と「イベント詳細の編集ボタンを押すパターン」の2パターンある。このままでは、編集ボタンから呼び出したフォームから保存をすると更新されずに新規イベントとして保存されてしまうため、この問題を解決させる。

解決策として、「eventステートのidの有無」で分岐させる。

```vue
EventFormDialog.vue

<script>
//
methods: {
  ...mapActions('events', ['setEvent', 'setEditMode', 'createEvent', 'updateEvent']),
  ///
  submit() {
    if (this.isInvalid) {
      return;
    }
    const params = {
      ...this.event,
        name: this.name,
        start: `${this.startDate} ${this.startTime} || ''`,
        end: `${this.endDate} ${this.endTime} || ''`,
        description: this.description,
        color: this.color,
        timed: !this.allDay,
      };
      if (params.id) {
        this.updateEvent(params);
      } else {
        this.createEvent(params);
      }
      this.closeDialog();
  }
}
</script>
```

`...this.event`...APIに送信するパラメーターの値にあるこれはスプレッド構文であり、`this.event`の全ての属性をここに展開させている。展開される属性にはname, descriptionが含まれるが、それ以降に直接指定することで上書きをする。なぜ全てを展開するかというと`params.id`を使えるようにするため。eventステートにid属性があれば`id: 1`のようにparamsのキーとして指定される。まだidがなければparamsのキーにidは指定されない。

## キャンセルボタン

イベントの作成時にキャンセルボタンを押すとカレンダーに戻り、更新時に押すと詳細画面に戻るキャンセルボタンを実装する

```vue
EventFormDialog.vue

<v-card-actions class="d-flex justify-end">
  <v-btn @click="cancel">キャンセル</v-btn>
</v-card-actions>

<script>
//
methods: {
  cancel() {
    this.setEditMode(false);
    if (!this.event.id) {
      this.setEvent(null);
    }
  },
}
</script>
```

イベントの新規作成時ではキャンセルボタンを押したらeventステートの値をリセットしたいため`if (!this.event.id)`で条件分岐させる。

## Calendarモデルへの紐付け

Calendarモデルを作成し、Eventモデルと紐付けをする。Eventモデルへcalendar_idカラムを追加

変更ポイント

```rb
# events_controller

class EventsController < ApplicationController

  def index
    render json: Event.all.to_json(include: :calendar)
  end

  def show
    render json: Event.find(params[:id]).to_json(include: :calendar)
  end

  def create
    event = Event.new(event_params)
    if event.save
      render json: event.to_json(include: :calendar)
    else
      render json: event.errors, status: 422
    end
  end

  def update
    event = Event.find(params[:id])
    if event.update(event_params)
      render json: event.to_json(include: :calendar)
    else
      render json: event.errors, status: 422
    end
  end

  def destroy
    event = Event.find(params[:id])
    event.destroy!
    render json: event.to_json(include: :calendar)
  end

  private

  def event_params
    params.require(:event).permit(:name, :start, :end, :timed, :description, :color, :calendar_id)
  end
end
```

event_paramsへの`calendar_id`の追加

`.to_json(include: :calendar)`...このオプションをつけることで、イベントに紐づいているカレンダーデータも含めたイベントデータをJSONに変換して取得できる

`Event.all時のレスポンスJSON`

```json
[{"id": 1, "name": "予定1", "start": "...", ..., "calendar_id": 1 }]
```

`Event.all.to_json(include: :calendar)時のレスポンスJSON`

```json
[{"id": 1, "name": "予定1", "start": "...", ..., "calendar": { "id": 1, "name": "カレンダー1", ...} }]
```

イベントに紐づくカレンダー情報全て一緒に取得しているのがわかる。

## カレンダー一覧の表示

カレンダーのデータをAPI経由で取得し、画面にカレンダー一覧を表示させる

- Vuexストアにカレンダー全件を取得するアクションを追加する
- カレンダー一覧を表示するCalendarListコンポーネントを作成する
- CalendarListコンポーネントを表示する

## Vuexストアにカレンダー全件を取得するアクションを追加する

`src/store/modules/calendars.js`を作成し、vuexストアを編集する

```js
import axios from 'axios';

const apiUrl = 'http://localhost:3000';

const state = {
  calendars: [],
};

const getters = {
  calendars: state => state.calendars,
};

const actions = {
  async fetchCalendars({ commit }) {
    const response = await axios.get(`${apiUrl}/calendars`);
    commit('setCalendars', response.data);
  },
};

const mutations = {
  setCalendars: (state, calendars) => (state.calendars = calendars)
};

export default {
  namespace: true,
  state,
  getters,
  actions,
  mutations,
};
```

次に、作成したcaledars.jsを`store/index.js`にインポートする

```js
import calendars from './modules/calendars';

export default new Vuex.Store({
  modules: {
    events,
    calendars,
  },
})
```

## serializerの追加

`src/functions/serializers.js`に以下を追記し、デフォルトのカラーを青に加工させる

```js
//
export const serializeCalendar = calendar => {
  if (calendar === null) {
    return null;
  }
  return {
    ...calendar,
    color: calendar.color || 'blue',
  };
};
```

次に、このファイルをcalendar.jsにインポートする

```js
// modules/calendars.js

import { serializeCalendar } from '../../functions/serializers';

//
const getters = {
  calendars: state => state.calendars.map(calendar => serializeCalendar(calendar)),
};
```

## カレンダー一覧を表示するCalendarListコンポーネントを作成する

`src/components/calendars/CalendarList.vue`を作成

```vue
<template>
  <v-list dense>
    <v-list-item-group :value="selectedItem">
      <v-subheader>マイカレンダー</v-subheader>
      <v-list-item v-for="calendar in calendars" :key="calendar.id">
        <v-list-item-content class="pa-0">
          <v-checkbox
            dense
            v-model="calendar.visibility"
            :color="calendar.color"
            :label="calendar.name"
            class="pa-0"
          ></v-checkbox>
        </v-list-item-content>
      </v-list-item>
    </v-list-item-group>
  </v-list>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'CalendarList',
  data: () => ({
    selectedItem: null,
  }),
  computed: {
    ...mapGetters('calendars', ['calendars']),
  },
  created() {
    this.fetchCalendars();
  },
  methods: {
    ...mapActions('calendars', ['fetchCalendars']),
  },
}
</script>
```

`created()`...の中でfetchCalendarsアクションを実行することで、CalendarListコンポーネントが呼び出されたタイミングでfetchCalendarsが呼び出され、APIからカレンダーデータを取得しcalendarsステートにデータを保持するようになる。

`computed`...calendarsステートの初期値は`空配列[]`だが、createdでfetchCalendarsアクションを実行しているため、computedのタイミングではカレンダーデータがすでに代入されている

`v-model="calendar.visibility"`...visibilityの値に応じてチェックするかどうかを決める

`:color="calendar.color"`...チェックボックスをcolorの値の色に変更させる。動的なため`:`をつける

`:label="calendar.name"`...動的にcalendar.nameの値を表示させる

v-listの中を`v-list-item-group`で囲い、valueに`selectedItem`を指定することでホバーした時に背景色をつけることができる

## CalendarListを表示させる

```vue
# Calenadr.vue

<template>
  <div>
    <v-sheet height="6vh" class="d-flex align-center" color="grey lighten-3">
      <v-btn outlined small class="ma-4" @click="setToday">今日</v-btn>
      <v-btn icon @click="$refs.calendar.prev()">
        <v-icon>mdi-chevron-left</v-icon>
      </v-btn>
      <v-btn icon @click="$refs.calendar.next()">
        <v-icon>mdi-chevron-right</v-icon>
      </v-btn>
      <v-toolbar-title>{{ title }}</v-toolbar-title>
    </v-sheet>
    <v-sheet height="94vh" class="d-flex">
      <v-sheet width="200px">
        <CalendarList />
      </v-sheet>
      <v-sheet class="flex">
        <v-calendar
          ref="calendar"
          v-model="value"
          :events="events"
          @change="fetchEvents"
          locale="ja-jp"
          :day-format="(timestamp) => new Date(timestamp.date).getDate()"
          :month-format="(timestamp) => new Date(timestamp.date).getMonth() + 1 + ' /'"
          @click:event="showEvent"
          @click:day="initEvent"
        ></v-calendar>
      </v-sheet>
    </v-sheet>

    <v-dialog :value="event !== null" @click:outside="closeDialog" width="600">
      <EventDetailDialog v-if="event !== null && !isEditMode" />
      <EventFormDialog v-if="event !== null && isEditMode" />
    </v-dialog>
  </div>
</template>

<script>
import { format } from 'date-fns';
import { mapGetters, mapActions } from 'vuex';
import EventDetailDialog from '../events/EventDetailDialog';
import EventFormDialog from '../events/EventFormDialog';
import CalendarList from '../calendars/CalendarList';
import { getDefaultStartAndEnd } from '../../functions/datetime';

export default {
  name: 'Calendar',
  components: {
    EventDetailDialog,
    EventFormDialog,
    CalendarList,
  },
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
  }),
  computed: {
    ...mapGetters('events', ['events', 'event', 'isEditMode']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
  },
  methods: {
    ...mapActions('events', ['fetchEvents', 'setEvent', 'setEditMode']),
    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd');
    },
    showEvent({ nativeEvent, event }) {
      this.setEvent(event);
      nativeEvent.stopPropagation();
    },
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
    },
    initEvent({ date }) {
      date = date.replace(/-/g, '/');
      const [start, end] = getDefaultStartAndEnd(date);
      this.setEvent({ name: '', start, end, timed: true });
      this.setEditMode(true);
    },
  },
};
</script>
```

`v-sheet`を使って画面を3領域にしている

```vue
<template>
  <v-sheet height="6vh" class="d-flex align-center">
    <!--ヘッダー-->
  </v-sheet>
  <v-sheet height="94vh" class="d-flex">
    <v-sheet width="200px">
      <!--サイドバー-->
    </v-sheet>
    <v-sheet class="flex">
      <!--カレンダー-->
    </v-sheet>
  </v-sheet>
</template>
```

サイドバーを横幅200pxに指定。カレンダーは画面横幅に泡褪せて伸縮するように指定。

## イベントにカレンダー情報を紐付ける

- CalendarSelectFormコンポーネントを作成する
- カレンダー選択フォームを表示して保存できるようにする
- イベント詳細ダイアログにカレンダーを表示する

## CalendarSelectFormコンポーネントを作成する

`src/components/forms/CalendarSelectForm.vue`ファイルを作成する

```vue
<template>
  <v-menu offset-y>
    <template v-slot:activator="{ on }">
      <v-btn v-on="on">{{ calendar.name }}</v-btn>
    </template>
    <v-list max-height="300px">
      <v-list-item v-for="c in calendars" :key="c.id" @click="calendar = c">
        {{ c.name }}
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'CalendarSelectForm',
  props: ['value'],
  computed: {
    ...mapGetters('calendars', ['calendars']),
    calendar: {
      get() {
        if (this.value === undefined || this.value === null) {
          this.$emit('input', this.calendars[0]);
          return this.calendars[0];
        }
        return this.value;
      },
      set(value) {
        this.$emit('input', value);
      },
    },
  },
};
</script>
```

`props: ['value']`...今回はカレンダーオブジェクトをvalueで受け取る想定

computedの中でcalendarプロパティを用意する。プロパティはデフォルトでは読み込み専用だが、`set`メソッドを定義することで更新時の処理も設定することができる。

`get`メソッド...calendarプロパティが呼び出された時に返す値を定義する。propsで渡されるvalueの値はカレンダーオブジェクトを想定しているが、イベント作成時はカレンダーオブジェクトが`undefined`or`null`で渡されてくる。もしイベント作成時ならデフォルトでcalendarsの最初のデータをそのイベントのカレンダーとして扱うための処理。イベント編集時であればvalueにはそのイベントのカレンダーオブジェクトが入っているため、そのままの値を返す処理。

`set`メソッド...calendarプロパティに値を代入する時に行う処理を定義する。calendarプロパティにvalueを代入すると、`this.$emit('input', value)`を呼び出すようにしている。

`@click="calendar = c"`を指定することで、クリックしたカレンダーのオブジェクトを引数にして`set`メソッドを呼び出し、親コンポーネントにカレンダーオブジェクトを伝達する

## カレンダー選択フォームを表示して保存できるようにする

CalendarSelectFormをEventFormDialogにimportする。

```vue
<template>
  <v-card class="pb-12">
    <v-card-actions class="d-flex justify-end pa-2">
      <v-btn icon @click="closeDialog">
        <v-icon size="20px">mdi-close</v-icon>
      </v-btn>
    </v-card-actions>
    <v-card-text>
      <DialogSection icon="mdi-square" :color="color">
        <v-text-field v-model="name" label="タイトル"></v-text-field>
      </DialogSection>
      <DialogSection icon="mdi-clock-outline">
        <DateForm v-model="startDate" />
        <div v-show="!allDay">
          <TimeForm v-model="startTime" />
        </div>
        <span class="px-2">–</span>
        <DateForm v-model="endDate" :isError="isInvalidDatetime" />
        <div v-show="!allDay">
          <TimeForm v-model="endTime" :isError="isInvalidDatetime" />
        </div>
      </DialogSection>
      <DialogSection>
        <CheckBox v-model="allDay" label="終日" class="ma-0 pa-0" />
      </DialogSection>
      <DialogSection icon="mdi-card-text-outline">
        <TextForm v-model="description" />
      </DialogSection>
      <DialogSection icon="mdi-calendar">
        <CalendarSelectForm :value="calendar" @input="changeCalendar($event)" />
      </DialogSection>
      <DialogSection icon="mdi-palette">
        <ColorForm v-model="color" />
      </DialogSection>
    </v-card-text>
    <v-card-actions class="d-flex justify-end">
      <v-btn @click="cancel">キャンセル</v-btn>
      <v-btn :disabled="isInvalid" @click="submit">保存</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';

import DialogSection from '../layouts/DialogSection';
import DateForm from '../forms/DateForm';
import TimeForm from '../forms/TimeForm';
import TextForm from '../forms/TextForm';
import ColorForm from '../forms/ColorForm';
import CheckBox from '../forms/CheckBox';
import CalendarSelectForm from '../forms/CalendarSelectForm';
import { isGreaterEndThanStart } from '../../functions/datetime';

export default {
  name: 'EventFormDialog',
  mixins: [validationMixin],
  components: {
    DialogSection,
    DateForm,
    TimeForm,
    TextForm,
    ColorForm,
    CheckBox,
    CalendarSelectForm,
  },
  data: () => ({
    name: '',
    startDate: null,
    startTime: null,
    endDate: null,
    endTime: null,
    description: '',
    color: '',
    allDay: false,
    calendar: null,
  }),
  validations: {
    name: { required },
    startDate: { required },
    endDate: { required },
    calendar: { required },
  },
  computed: {
    ...mapGetters('events', ['event']),
    isInvalidDatetime() {
      return !isGreaterEndThanStart(this.startDate, this.startTime, this.endDate, this.endTime, this.allDay);
    },
    isInvalid() {
      return this.$v.$invalid || this.isInvalidDatetime;
    },
  },
  created() {
    this.name = this.event.name;
    this.startDate = this.event.startDate;
    this.startTime = this.event.startTime;
    this.endDate = this.event.endDate;
    this.endTime = this.event.endTime;
    this.description = this.event.description;
    this.color = this.event.color;
    this.allDay = !this.event.timed;
    this.calendar = this.event.calendar;
  },
  methods: {
    ...mapActions('events', ['setEvent', 'setEditMode', 'createEvent', 'updateEvent']),
    closeDialog() {
      this.setEditMode(false);
      this.setEvent(null);
    },
    submit() {
      if (this.isInvalid) {
        return;
      }
      const params = {
        ...this.event,
        name: this.name,
        start: `${this.startDate} ${this.startTime || ''}`,
        end: `${this.endDate} ${this.endTime || ''}`,
        description: this.description,
        color: this.color,
        timed: !this.allDay,
        calendar_id: this.calendar.id,
      };
      if (params.id) {
        this.updateEvent(params);
      } else {
        this.createEvent(params);
      }
      this.closeDialog();
    },
    cancel() {
      this.setEditMode(false);
      if (!this.event.id) {
        this.setEvent(null);
      }
    },
    changeCalendar(calendar) {
      this.color = calendar.color;
      this.calendar = calendar;
    },
  },
};
</script>
```

dataに`calendar`変数を追加する。

submitメソッドでAPIを呼び出すときに送るパラメーターに`calendar_id`を追加する。フロントエンドでは基本的に変数名は、キャメルケースで書くが、Rails側ではスネークケースで扱う。なぜこのparamsの中身でスネークケースを使うかというと、このparamsのキーはそのままRailsに送られるため統一する必要があるから。

`calendar: { required }`...calendarの入力を必須に。この条件を追加することで、calendarの値がnullの場合に`this.$v.$invalid`がfalseと評価され、保存できなくする

```
<DialogSection icon="mdi-calendar">
  <CalendarSelectForm :value="calendar" @input="changeCalendar($event)" />
</DialogSection>
```

`v-model="calendar"`と書いてもいいが、ここではあえて`:value`, `@input`に分解している。その目的は、カレンダーの値が更新された時にそのカレンダーのカラーをイベントのカラーに変更するため。

`@input`...フォームの値が変更された時に実行する処理を指定するプロパティ。ここではCalendarSelectFormの中で`this.$emit('input', value)`が実行された時に、`$event`
でそのvalueを受け取る。valueにはカレンダーオブジェクトが入っていることを意識。

`chaneCalendar`メソッド...calendar変数に引数の値を代入する処理に加えて、color変数にそのカレンダーオブジェクトのcolorの値を代入する。こうすることで、カレンダーを選択した時にカレンダーのカラーをイベントのカラーに変更することができる

## イベント詳細ダイアログにカレンダーを表示する

EventDetailDialogを以下のように編集

```vue
<template>
  <div v-if="event !== null">
    <v-card class="pb-12">
      <v-card-actions class="d-flex justify-end pa-2">
        <v-btn icon @click="edit">
          <v-icon size="20px">mdi-pencil-outline</v-icon>
        </v-btn>
        <v-btn icon @click="del">
          <v-icon size="20px"> mdi-trash-can-outline </v-icon>
        </v-btn>
        <v-btn icon @click="closeDialog">
          <v-icon size="20px">mdi-close</v-icon>
        </v-btn>
      </v-card-actions>
      <v-card-title>
        <DialogSection icon="mdi-square" :color="event.color">{{ event.name }}</DialogSection>
      </v-card-title>
      <v-card-text>
        <DialogSection icon="mdi-clock-time-three-outline">
          {{ event.startDate }} {{ event.timed ? event.startTime : '' }} ~ {{ event.endDate }} {{ event.timed ? event.endTime : '' }}
        </DialogSection>
      </v-card-text>
      <v-card-text>
        <DialogSection icon="mdi-card-text-outline">
          {{ event.description || 'no description' }}
        </DialogSection>
      </v-card-text>
      <v-card-text>
        <DialogSection icon="mdi-calendar">{{ event.calendar.name }}</DialogSection>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import DialogSection from '../layouts/DialogSection.vue';

export default {
  name: 'EventDetailDialog',
  components: {
    DialogSection,
  },
  computed: {
    ...mapGetters('events', ['event']),
  },
  methods: {
    ...mapActions('events', ['setEvent', 'deleteEvent', 'setEditMode']),
    closeDialog() {
      this.setEvent(null);
    },
    del() {
      this.deleteEvent(this.event.id);
    },
    edit() {
      this.setEditMode(true);
    },
  },
};
</script>
```

## カレンダー作成機能

- Vuexストアにカレンダー作成アクションを追加する
- カレンダー作成ダイアログを表示するCalendarFormDialogコンポーネントを作成する
- CalendarFormDialogを表示する

## Vuexストアにカレンダー作成アクションを追加する

modules/calendar.jsに追記

```js
const state = {
  calendar: null,
};

const getters = {
  calendar: state => serializeCalendar(state.calendar),
},

const mutations = {
  appendCalendar: (state, calendar) => (state.calendars = [...state.calendars, calendar]),
  setCalendar: (state, calendar) => (state.calendar = calendar),
};

const actions = {
  async createCalendar({ commit }, calendar) {
    const response = await axios.post(`${apiUrl}/calendars`, calendar);
    commit('appendCalendar', response.data);
  },
  setCalendar({ commit }, calendar) {
    commit('setCalendar', calendar);
  },
};
```

actionsのcreateCalendarでcommitされた新規カレンダーが、mutationsのappendCalendarの引数として渡され、これまでのカレンダーsと新規カレンダーが配列`[...state.calendars, calendar]`として`state.calendars`に代入される

## CalendarFormDialog

カレンダー作成ダイアログを作成

```vue
<template>
  <v-card class="py-12">
    <v-card-text>
      <DialogSection icon="mdi-square" :color="color">
        <v-text-field v-model="name" label="カレンダー名"></v-text-field>
      </DialogSection>
      <DialogSection icon="mdi-palette">
        <ColorForm v-model="color" />
      </DialogSection>
    </v-card-text>
    <v-card-actions class="d-flex justify-end">
      <v-btn @click="close">キャンセル</v-btn>
      <v-btn @click="submit" :disabled="$v.$invalid">保存</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import DialogSection from '../layouts/DialogSection';
import ColorForm from '../forms/ColorForm';

export default {
  name: 'CalendarFormDialog',
  mixins: [validationMixin],
  components: { DialogSection, ColorForm },
  data: () => ({
    name: '',
    color: null,
  }),
  validations: {
    name: { required },
  },
  computed: {
    ...mapGetters('calendars', ['calendar']),
  },
  created() {
    this.name = this.calendar.name;
    this.color = this.calendar.color;
  },
  methods: {
    ...mapActions('calendars', ['createCalendar', 'setCalendar']),
    close() {
      this.setCalendar(null);
    },
    submit() {
      if (this.$v.$invalid) {
        return;
      }
      const params = {
        ...this.calendar,
        name: this.name,
        color: this.color,
      };
      this.createCalendar(params);
      this.close();
    },
  },
};
</script>
```

dateにてname, color変数を用意。createdでcalendarステートに入っている値がそれぞれ代入される

`name: { required }`...calendar.nameが必須であるバリデーション

キャンセルボタンをクリックするとcloseメソッドが呼ばれ、setCalendarの値にnullを渡すことで、calendarステートをリセットする。これは、calendarステートがnullの時にダイアログを表示しないようにするため。

保存ボタンをクリックするとsubmitメソッドが呼ばれ、APIリクエストを送信するパラメータを用意し、createCalendarアクションを呼び出す。もしカレンダー名が空であれば`:disabled="$v.$invalid"`によって保存ボタンが非活性化になる。

## CalendarFormDialogの表示

CalendarList.vueにはめ込む

```vue
<template>
  <v-list dense>
    <v-list-item>
      <v-list-item-content>
        <v-subheader>マイカレンダー</v-subheader>
      </v-list-item-content>
      <v-list-item-action>
        <v-btn icon @click="initCalendar">
          <v-icon size="16px">mdi-plus</v-icon>
        </v-btn>
      </v-list-item-action>
    </v-list-item>
    <v-list-item-group :value="selectedItem">
      <v-list-item v-for="calendar in calendars" :key="calendar.id">
        <v-list-item-content class="pa-0">
          <v-checkbox dense v-model="calendar.visibility" :color="calendar.color" :label="calendar.name" class="pa-0"></v-checkbox>
        </v-list-item-content>
      </v-list-item>
    </v-list-item-group>
    <v-dialog :value="calendar !== null" @click:outside="closeDialog" width="600">
      <CalendarFormDialog v-if="calendar !== null" />
    </v-dialog>
  </v-list>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import CalendarFormDialog from '../calendars/CalendarFormDialog.vue';

export default {
  name: 'CalendarList',
  components: {
    CalendarFormDialog,
  },
  data: () => ({
    selectedItem: null,
  }),
  computed: {
    ...mapGetters('calendars', ['calendars', 'calendar']),
  },
  created() {
    this.fetchCalendars();
  },
  methods: {
    ...mapActions('calendars', ['fetchCalendars', 'setCalendar']),
    initCalendar() {
      this.setCalendar({
        name: '',
        visivility: true,
      });
    },
    closeDialog() {
      this.setCalendar(null);
    },
  },
};
</script>
```

`initCalendar`メソッド...setCalendarアクションにカレンダーオブジェクトを渡して、calendarステートに値を代入する

`closeDialog`...setCalendarにnullを渡すことで、calendarステートをnullにする。`calendar !== null`の伏線

## カレンダーの編集

Vuexストアにカレンダーの更新アクションを追加

```js
const mutations = {
  updateCalendar: (state, calendar) => (state.calendars = state.calendars.map(c => (c.id === calendar ? calendar : c))),
};

const actions = {
  async updateCalendar({ commit }, calendar) {
    const response = await axios.put(`${apiUrl}/calendars/${calendar.id}`, calendar);
    commit('updateCalendar', response.data);
  }
};
```

次に、CalendarListにて各カレンダーの右側に編集ボタンを表示させる

```vue
<template>
//
  <v-list-item-action class="ma-0">
    <v-menu transition="scale-transition" offset-y min-width="100px">
      <template v-slot:activator="{ on }">
        <v-btn icon v-on="on">
          <v-icon size="12px">mdi-dots-vertical</v-icon>
        </v-btn>
        <v-btn></v-btn>
      </template>
      <v-list>
        <v-list-item @click="edit(calendar)">編集</v-list-item>
      </v-list>
    </v-menu>
  </v-list-item-action>
</template>

<script>
//
methods: {
  edit(calendar) {
    this.setCalendar(calendar);
  },
},
</script>
```

v-list-item-actionを追加することで、カレンダー名の右隣にドットアイコンを表示させる

`edit(calendar)`...編集ボタンを押した時に、そのカレンダーオブジェクトが引数として渡される。そのデータをcalendarステートに代入する。calendarステートにカレンダーオブジェクトが代入されると、ダイアログが表示される。カレンダー作成時とは異なり、calendarステートにはすでにカレンダー名やカラーの値が入っているため、ダイアログにはそのカレンダー情報が入力済みの状態で表示される

次に、編集アクションを呼び出す処理を追記する

イベント編集時同様に、params.idの有無によってcreate or updateを分岐させる

CalendarFormDialogを編集する

```vue
//
<script>
//
methods: {
  ...mapActions('calendars', ['createCalendar', 'updateCalendar', 'setCalendar']),
  //
  submit() {
    if (this.$v.$invalid) {
      return;
    }
    const params = {
      ...this.calendar,
      name: this.name,
      color: this.color,
    };
    if (params.id) {
      this.updateCalendar(params)
    } else {
      this.createCalendar(params)
    }
    this.close();
  },
},
</script>
```

## カレンダーの削除処理

```js
const mutations = {
  removeCalendar: (state, calendar) => (state.calendars = state.calendars.filter(c => c.id !== calendar.id)),
};

const actions = {
  async deleteCalendar({ commit }, id) {
    const response = await axios.delete(`${apiUrl}/calendars/${id}`);
    commit('removeCalendar', response.data);
  },
};
```

`filter()`...条件に一致した要素のみで新たに配列を作るメソッド。つまり、削除対象以外を取り除く。

次に、削除ボタンを表示させる。編集するのはCalendarList

```vue
<v-list-item @click="edit(calendar)">編集</v-list-item>
<v-list-item @click="del(calendar)">削除</v-list-item>

<script>
//
methods: {
  ...mapActions('calendars', ['fetchCalendar', 'deleteCalendar', 'setCalendar']),
  //
  del(calendar) {
    this.deleteCalendar(calendar.id);
  },
}
</script>
```

## 選択したカレンダーのイベントのみ表示させる

- visibilityがtrueのカレンダーの予定だけ表示させる
- チェックボックスでカレンダーのvisibilityを更新する
- カレンダーを更新したらイベントデータを取得しなおす

## visibilityがtrueのカレンダーの予定だけ表示させる

カレンダーにはboolean型のvisibilityがあり、これがtrueの時に画面に表示させ、falseであれば非表示にする

```js
// events.js

const getters = {
  events: state => state.events.filter(event => event.calendar.visibility).map(event => serializeEvent(event)),
};
```

一度、visibilityがtrueであるカレンダーに紐づくイベントのみの配列を作り直し、それぞれのイベントにシリアライズをかける

## チェックボックスでカレンダーのvisibilityを更新する

CalendarListの編集

```vue
//
<v-ckeckbox
  dense
  v-model="calendar.visibility"
  ;color="calendar.color"
  :label="calendar.name"
  @click="toggleVisibility(calendar)"
  class="pa-0"
></v-ckeckbox>

<script>
//
methods: {
  ...mapActions('calendars', ['fetchCalendars', 'updateCalendar', 'deleteCalendar', 'setCalendar']),
  //
  toggleVisibility(calendar) {
    this.updateCalendar(calendar);
  },
}
</script>
```

`toggleVisibility()`...updateCalendarアクションにクリックしたカレンダーのデータを渡す。v-checkboxに`v-model="calendar.visibility"`を指定しているため、チェックボックスをクリックしたらcalendar.visibilityの値が反転する。その状態のデータでカレンダーを更新APIを叩くため、結果的にvisibilityの値が反転するように更新される。

## カレンダーを更新したらイベントデータを取得しなおす

チェックボックスをクリックしてカレンダーのデータを更新したら、イベントデータを再取得する必要がある。再取得しないと画面上に変化がないため。

```js
// calendars.js

const actions = {
  //
  async updateCalendar({ dispatch, commit }, calendar) {
    const response = await axios.put(`${apiUrl}/calendars/${calendar.id}`, calendar);
    commit('updateCalendar', response.data);
    dispatch('events/fetchEvents', null, { root: true });
  },

  async deleteCalendar({ dispatch, commit }, id) {
    const response = await axios.delete(`${apiUrl}/calendars/${id}`);
    commit('removeCalendar', response.data);
    dispatch('events/fetchEvents', null, { root: true});
  },
}
```

`dispatch`メソッド...直接actionsで定義したアクションを実行するメソッド。第一引数に実行するアクションを、第二引数にそのアクションの引数を、第三引数にオプションを指定できる。

`{ root: true }`...dispatchしている`events/fetchEvents`はevents.jsで定義したアクションだが、このオプションを指定することで別のストアのアクションを実行できるようになる

## イベント一覧機能の実装

同じ日付には４つまでのイベントを表示させ、それ以上のイベントは`more`にする。ちなみに５つ目登録後、3イベント + `2 more`と表示になる

- クリックした日付を保持するclickedDateステートをvuexストアに追加する
- 日付をクリックしたらダイアログを表示する
- クリックした日付の予定を取得するためのdayEventsゲッターをvuexストアに追加
- イベント一覧を表示するDayEventListコンポーネントを作成
- イベント一覧ダイアログを表示

## クリックした日付を保持するclickedDateステートをvuexストアに追加する

```js
// events.js

const state = {
  clickedDate: null,
};

const getters = {
  clickedDate: state => state.clickedDate,
};

const mutations = {
  setClickedDate: (state, date) => (state.clickedDate = date),
};

const actions = {
  setClickedDate({ commit }, date) {
    commit('setClickedDate', date);
  }
}
```

## 日付をクリックしたらダイアログを表示する

まずはテストとして日付をクリックしたら`hoge`とダイアログを表示させる

```vue
Calendar.vue

<v-calendar
  ref="calendar"
  v-model="value"
  :events="events"
  @change="fetchEvents"
  locale="ja-jp"
  :day-format="timestamp => new Date(timestamp.date).getDate()"
  :month-format="timestamp => new Date(timestamp.date).getMonth() + 1 + ' /'"
  @click:event="showEvent"
  @click:day="initEvent"
  @click:date="showDayEvent"
  @click:more="showDayEvent"
></v-calendar>
//
<v-dialog :value="clickedDate !== null" @click:outside="closeDialog" width="600">
  <v-card ligh>hoge</v-card>
</v-dialog>

<script>
//
computed: {
  ...mapGetters('events', ['events', 'event', 'isEditMode', 'clickedDate']),
},
methods: {
  ...mapActions('events', ['fetchEvents', 'setEvent', 'setEditMode', 'setClickedDate']),
  closeDialog() {
    this.setClickedDate(null);
  },
  initEvent({ date }) {
    if (this.clickedDate !== null) {
      return;
    }
  },
  showDayEvents({ date }) {
    date = date.replace(/-/g, '/');
    this.setClieckedDate(date);
  },
}
</script>
```

`@click:date`...日付をクリックした時に発火

`@click:more`...moreをクリックした時に発火

`showDayEvent`...mapActionsで読み込んだsetClickedDateアクションを実行する。引数のdate変数にはクリックした日付が`2021-7-16`のような文字列で入ってくるため`2021/7/16`に変換させる。

`:value="clickedDate !== null"`...clickedDateに値がある時にだけダイアログを表示させる

initEventメソッド時も同じで、clickedDateに値がある時は、initEventメソッドを実行させない

## クリックした日付の予定を取得するためのdayEventsゲッターをvuexストアに追加

クリックした日付のイベント一覧を表示させるためには、クリックした日付に紐づくイベントを取得する必要がある

```js
// events.js

import { isWithinInterval } from 'date-fns';

const getters = {
  dayEvents: state => state.events.map(event => serializeEvent(event)).filter(event => isWithinInterval(new Date(state.clickedDate), { start: new Date(event.startDate), end: new Date(event.endDate) })),
}
```

`isWithinInterval`...指定した期間内にあるかどうかを検証するメソッド

```js
isWithinInterval(
  new Date(2021, 1,3),
  { start: new Date(2021, 1, 2), end: new Date(2021, 1, 10) }
)
#=> true

isWithinInterval(
  new Date(2021, 1, 11),
  { start: new Date(2021, 1, 2), end: new Date(2021, 1, 10) }
)
#=> false
```

## 日付を扱うロジックはdatetime.jsへ

events.jsで定義したisWithinIntervalの処理をdatetime.jsへ移す

```js
// datetime.js

import { format, addHours, isWithinInterval } from 'date-fns';

export const isDateWithinInterval = (date, startDate, endDate) => {
  return isWithinInterval(new Date(date), { start: new Date(startDate), end: new Date(endDate)});
}
```

よってevents.jsは以下のように描きかわる

```js
import { isDateWithinInterval } from '../../functions/datetime';

const getters = {
  dayEvents: state => state.events.map(event => serializeEvent(event)).filter(event => isDateWithinInterval(state.clickedDate, event.startDate, event.endDate)),
}
```

## イベント一覧を表示するDayEventListコンポーネントを作成

`events/DayEventList.vue`を作成

```vue
<template>
  <v-card class="pb-8">
    <v-card-actions class="d-flex justify-end">
      <v-btn icon @click="closeDialog">
        <v-icon>mdi-close</v-icon>
      </v-btn>
    </v-card-actions>
    <v-card-title class="d-flex justify-center">
      {{ formatDateToJa(clickedDate) }}
    </v-card-title>
    <v-card-text>
      <v-list>
        <v-list-item v-for="event in dayEvents" :key="event.id">
          <v-list-item-content class="pa-0">
            <v-btn depressed :color="event.color" class="white--text justify-start">
              <template v-if="event.timed">
                {{ event.startTime }}
              </template>
              {{ event.name }}
            </v-btn>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-card-text>
  </v-card>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import { formatDateToJa } from '../../functions/datetime';

export default {
  name: 'DayEventList',
  computed: {
    ...mapGetters('events', ['dayEvents', 'clickedDate']),
  },
  methods: {
    ...mapActions('events', ['setClickedDate']),
    formatDateToJa,
    closeDialog() {
      this.setClickedDate(null);
    },
  },
};
</script>
```

`{{ formatDateToJa(clickedDate) }}`...クリックした日付を表示

`:color="event.color"`...イベントのカラーを表示

`v-if="event.timed"`...時刻を表示する場合のみ、startTimeを表示させる

## ダイアログの表示

```vue
<v-dialig :value="clickedDate !== null" @click:outside="closeDialog" width="600">
  <DayEventList />
</v-dialig>

<script>
import DayEventList from '../events/DayEventList'

export default {
  components: {
    DayEventList
  }
}
</script>
```

## sort

日付内イベント一覧の表示順を、開始時刻が早い順に並び替えを行う

datetime.js

```js
//
export const compareDates = (a, b) => {
  if (a.start < b.start) return -1;
  if (a.start > b.start) return 1;
  return 0;
}
```

events.js

```js
import { isDateWithinInterval, compareDates } from '../../functions/datetime';

const getters = {
  dayEvents: state =>
    state.events.map(event => serializeEvent(event))
    .filter(event => isDateWithinInterval(state.clicedDate, event.startDate, event.endDate))
    .sort(compareDates),
}
```

## 終日の開始時刻と終了時刻の加工

終日であれば開始時刻を`00:00:00`, 終了時刻を`23:59:59`に加工し、一覧表示の際は、一番上に並び替えさせる

serializers.js

```js
import { format, set } from 'date-fns';

export const serializeEvent = event => {
  if (event === null) {
    return;
  }

  let start = new Date(event.start);
  let end = new Date(event.end);

  if (!event.timed) {
    start = set(start, { hours: 0, minutes: 0, seconds: 0});
    end = set(end, { hours: 23, minutes: 59, seconds: 59});
  }
}
```

`let`...上書きを許す変数宣言
