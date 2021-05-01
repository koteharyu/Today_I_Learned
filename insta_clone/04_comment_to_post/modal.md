# instacloneのコメントのAjax・モーダル表示までの流れ

## 新規コメント篇

1. 投稿詳細ページにコメントフォームをレンダー
2. コメントを入力・投稿ボタンをクリック(action="/posts/:id/comments", method; :post)
3. commentsコントローラーのcreateアクションが呼ばれる
4. Ajax通信することを指定しているため(remote: true), create.js.slimが呼び出される
5. prependメソッドを使いことで、.comment-boxの先頭に新規コメントを追加している
6. 最後にコメントフォームのvalueの中身を空にして完成(.val('');)

[![Image from Gyazo](https://i.gyazo.com/444c563772564ce91a299cbd9c62e3ae.png)](https://gyazo.com/444c563772564ce91a299cbd9c62e3ae)

<br>

## コメント編集篇

1. コメントのユーザーidとcurrent_user.idが一致した場合のみ編集アイコンが表示される
2. layouts/application.html.slimに`.modal-container`を追記し、モダールの表示領域を確保
3. editアクションが呼ばれることで、comments/edit.js.slimが参照される
4. .modal-containerに`comments/modal_form`をレンダーする。その際のlocalsオプションを指定し、変数を指定
5. `comments/modal_form`の`#comment-edit-modal`を表示させる。その際に使う変数が4で指定したlocals
6. `comments/form`をレンダーするが、その際、モデルに渡す引数として、postが不必要(shallowオプションをルーティングで指定しているため)なため、`post: nil`を渡している
7. 次にupdateアクションが呼ばれ、update.js.slimを参照
8. replaceWithメソッドにより、更新したコメントに差し替える
9. モーダルを非表示にして完了

<br>

## 削除篇

1. 削除アイコンをクリックされると、commentsコントローラーのdestroyアクションが呼ばれる
2. これもremote: treuなため、destroy.js.slimが参照される
3. この処理は単純で、該当するidを持つコメントのdivごと削除すれば、データベースからも、HTML側からも削除されることになる

<br>

## ポイント

今までは、formについての理解が曖昧だったので、modalを通して投稿したり、編集したりする際にURLを意識して開発していたが、これは間違いだった。

`form_with`に渡すモデルの状況・状態によってcreateアクションが対応するのか、updateアクションが対応するのか、区別することを理解できたため、自在にモーダルを使えそうだと思った。

## 参考

[form_with/form_forについて](https://qiita.com/snskOgata/items/44d32a06045e6a52d11c#23-form_with-model-modela-modelb)
[miketaさんのgithub](https://github.com/miketa-webprgr/instagram_clone/pull/4)
