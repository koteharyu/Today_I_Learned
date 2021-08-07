# 07_profile_edit_frontend.md

## vue-image-crop-upload

`vue-image-crop-uplead`...Vue.jsに置ける画像のトリミングやアップロードを簡単に実装できるライブラリ。

#### 導入

今回は、yarnにて導入

`$ yarn add vue-image-crop-upload`

プロジェクトで使用しているVue.jsのバージョンによって記述方法が異なるため注意が必要。今回は、Vue2系統を使用しているため、それに合わせた実装方法を残していく。

```vue
<template>
  <div>
    <avatar-upload field="img"
        @crop-success="cropSuccess"
        @crop-upload-success="cropUploadSuccess"
        @crop-upload-fail="cropUploadFail"
        v-model="show"
        :width="300"
        :height="300"
        langType="ja"
        img-format="png"></avatar-upload>
  </div>
</template>

<script>
// importのパス指定に注意が必要
  import AvatarUpload from 'vue-image-crop-upload/upload-2.vue';

  export default {
      data() {
          return {
              show: false,
          }
      },
      components: {
          AvatarUpload
      },
      methods: {
          toggleShow() {
              this.show = !this.show;
          },
          /**
           * crop success
           *
           * [param] imgDataUrl
           * [param] field
           */
          async cropSuccess(imgDataUrl, field){
              console.log('-------- crop success --------');
              await this.$store.dispatch('auth/updateProfile', { user: { avatar: { data: imgDataUrl } } })
          },
          /**
           * upload success
           *
           * [param] jsonData  server api return data, already json encode
           * [param] field
           */
          cropUploadSuccess(jsonData, field){
              console.log('-------- upload success --------');
              console.log(jsonData);
              console.log('field: ' + field);
          },
          /**
           * upload fail
           *
           * [param] status    server api return error status, like 500
           * [param] field
           */
          cropUploadFail(status, field){
              console.log('-------- upload fail --------');
              console.log(status);
              console.log('field: ' + field);
          }
      }
  }
</script>
```

`import AvatarUpload from 'vue-image-crop-upload/upload-2.vue';`...読み込むライブラリのバージョン指定に注意。

`img-format="png"`...この指定により受け付ける拡張子を`png`,`jpg`に限定することができる

#### 成功例

[![Image from Gyazo](https://i.gyazo.com/6f81caa980aa4a23e45471d1c0161dec.gif)](https://gyazo.com/6f81caa980aa4a23e45471d1c0161dec)

#### 失敗例

[![Image from Gyazo](https://i.gyazo.com/4be1667525470db72b5bd57e8c8b6e7e.gif)](https://gyazo.com/4be1667525470db72b5bd57e8c8b6e7e)

## CurrentUserの更新

`store/index.js`にて`auth`として`store/modules/auth/index.js`をimportしているため、`store/modules/auth/index.js`で定義した定数?アクション?を使用する際には、`this.$store.getters['auth/currentUser']`, `await this.$store.dispatch('auth/updateProfile', userParams)`のようにする

`dispatch`...非同期でactionsの定義したアクションを実行させるメソッド。

```js
async updateProfile() {
    const userParams = {
        user: {
            name: this.user.name,
            introduction: this.user.introduction
        }
    }
    await this.$store.dispatch('auth/updateProfile', userParams)
    this.close()
}
```

userParamsに更新時のパラメーターをセットし、actionsのupdateProfileアクションを実行させmutationsのSET_CURRENT_USERに渡している
