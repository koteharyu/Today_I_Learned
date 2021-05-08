# layoutメソッドとは

namespace/mypages_controllerとnamespace/base_controllerを作成した上、namespace/base_controller内に`layout 'maypage'`という見慣れない記述あったので調べてみた

```
# namespace/base_controller

class Mypage::BaseController < ApplicationController
  layout 'mypages'
end
```

<br>

## layoutメソッドとは

layout `XXX`とすることで、コントローラーやアクション毎に使用するレイアウトを切り替えるこができるようになる

特にlayoutメソッドを使用しない場合は、`app/views/layouts/application.html.slim`ファイルがアプリケーションに含まれる全てのテンプレート用レイアウトとして使用され、それぞれのコントローラーのアクション毎にレンダリングされるviewファイルが異なる

例えば、posts_controllerのindexアクションが呼ばれた場合は、`/layouts/application.html.slim`と`posts/index.html.slim`がレンダリングされる

<br>

特定のコントローラーに含まれるアクションから呼び出されるテンプレートに指定したレイアウトを設定したい場合は、`app/views/layouts/コントローラー名.html.slim`というファイルを作成する

今回の例でいうと、`app/views/layouts/mypages`ファイルを作成しておくと、自動的に適用される

<br>

[コントローラやアクション毎に使用するレイアウトを切り替える](https://www.javadrive.jp/rails/template/index3.html)
