## turbolinkとは

turbolinksとは、画面遷移を高速化させるライブラリのこと。画面全体を更新するのではなく、画面の一部だけを更新されることで高速化を実現させる

リンクを生成するa要素のクリックをフックにして、移動先のページをAjaxで取得する。

取得ページのデータが遷移前のページと同じものがあれば、再利用し、title, body要素を置き換えて表示させる

turbolinksが原因で、JavaScriptが正しく動作しない

具体的には、ページ読込を起点としたJavaScriptが機能しなくなる。

通常であれば、ページが読み込まれたタイミングでloadイベントが発生するが、Turboliksによって画面が切り替わった場合は、loadイベントは発生しなくなるから

また、jQuery.readyやDOMContentLoadedを使用しても、ページ切り替え時にそのイベントは発生しない

loadイベントを発生させたい場合は、Turbolinksを無効化させる必要がある

[参考1](https://www.ryotaku.com/entry/2019/01/15/213420)
[参考2](https://kossy-web-engineer.hatenablog.com/entry/2018/11/29/093958)