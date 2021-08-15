# vue-image-crop-upload

[こちらを参考に導入](https://www.npmjs.com/package/vue-image-crop-upload)

`$ npm install vue-image-crop-upload`

次に任意のファイルを作成。使用しているVue.jsのバージョンによって指定方法が異なるため要注意。今回は2系統の実装方法

```vue
<div id="app">
	<a class="btn" @click="toggleShow">set avatar</a>
	<my-upload field="img"
        @crop-success="cropSuccess"
        @crop-upload-success="cropUploadSuccess"
        @crop-upload-fail="cropUploadFail"
        v-model="show"
		:width="300"
		:height="300"
		url="/upload"
		:params="params"
		:headers="headers"
		img-format="png"></my-upload>
	<img :src="imgDataUrl">
</div>

<script>
	import 'babel-polyfill'; // es6 shim
	import Vue from 'vue';
	import myUpload from 'vue-image-crop-upload/upload-2.vue';

	new Vue({
		el: '#app',
		data: {
			show: true,
			params: {
				token: '123456798',
				name: 'avatar'
			},
			headers: {
				smail: '*_~'
			},
			imgDataUrl: '' // the datebase64 url of created image
		},
		components: {
			'my-upload': myUpload
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
			cropSuccess(imgDataUrl, field){
				console.log('-------- crop success --------');
				this.imgDataUrl = imgDataUrl;
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
	});
</script>
```

次のコマンドを実行してーって言われたので素直に

```
 ERROR  Failed to compile with 1 error                                                                                                 17:30:29

This dependency was not found:

* babel-polyfill in ./node_modules/cache-loader/dist/cjs.js??ref--12-0!./node_modules/babel-loader/lib!./node_modules/cache-loader/dist/cjs.js??ref--0-0!./node_modules/vue-loader/lib??vue-loader-options!./src/components/AvatarUpload.vue?vue&type=script&lang=js&

To install it, you can run: npm install --save babel-polyfill
```

`$npm install --save babel-polyfill`

## babelがpolyfilするとは

`babelがpolyfilする`...ブラウザが対応できないJSのバージョンの構文を理解できるように変換する仕組み
