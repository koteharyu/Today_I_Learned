# DHH流って何？

最近になり、DHHという単語をよく目にする様になったが、この正体は一体なんなのか

## DHH

`David Heinemeier Hansson`略して`DHH`

まさかのRailsの創始者様の略称でしたーーー

口癖は`Please do investigate(自分で調べてください)`

[Railsを作った男たち](https://qiita.com/gogotanaka/items/40ea2d34f89a434fa594)

<br>

## DHH流とは

創始者が推奨するRailsの書き方を`DHH流`と呼ぶそうな

[DHHはどのようにRailsのコントローラを書くのか](https://postd.cc/how-dhh-organizes-his-rails-controllers/)

<br>

## DHH流ルーティングとは

DHHが推奨しているRailsのルーティングの手法のこと

考え方としては、RESTの原則に従って新しいコントローラーを作るタイミングを決めるというもの

つまり、コントローラーはデフォルトのCRUDアクション(index, show, new, create, edit, update, destroy)のみを使って、それ以外のアクションが必要になった場合は、別のコントローラーに分けなさいという内容

## DHH流ルーティングのメリット

1. コントローラーのスリム化
2. ルーティングのルールが明確になる

## コントローラーのスリム化

重要な責務のコントローラーはアクションが増えて肥大化しがち。別のコントローラーに切り分けることで、アクションの増加を防ぐことができ、コントローラーのスリム化に繋がる

### ルーティングのルールが明確になる

特にカスタムアクションのルーティング定義は、実装者の裁量に依存してしまいがちなもの。そのような実装者によるバラツキを防ぐこともできる

<br>

## ケーススタディ

`recipe`のリソースに対して、公開/非公開のアクションを付け加えたい場合

カスタムアクションで定義する場合は以下の様になるだろう

```
class RecipeController < ApplicationController
  def index
  end
  ////
  def publish
  //公開処理
  end

  def unpublish
  //非公開処理
  end
end
```

<br>

コントローラーを切り分けるDHH流に書くことで、デフォルトのCRUDアクションで対応することができる様になる

```
class Recipe::PublicationsController < ApplicationController
  def update
  //公開処理
  end

  def destroy
  //非公開処理
  end
end
```

### ルーティング

現在のディレクトリ構造は以下の様になっている

`app/controllers/recipes/publications_controller`

`app/controllers/recipes_controller`

この様な場合は`module`を使って記述する

```
resources :recipes do
  resource :publication, only: [:update, :destroy], module: "recipes"
end

recipe_publication PATCH  /recipes/:recipe_id/publication(.:format)  recipes/publications#update
                     PUT    /recipes/:recipe_id/publication(.:format)  recipes/publications#update
                     DELETE /recipes/:recipe_id/publication(.:format)  recipes/publications#destroy
             recipes GET    /recipes(.:format)                         recipes#index
                     POST   /recipes(.:format)                         recipes#create
          new_recipe GET    /recipes/new(.:format)                     recipes#new
         edit_recipe GET    /recipes/:id/edit(.:format)                recipes#edit
              recipe GET    /recipes/:id(.:format)                     recipes#show
                     PATCH  /recipes/:id(.:format)                     recipes#update
                     PUT    /recipes/:id(.:format)                     recipes#update
                     DELETE /recipes/:id(.:format)                     recipes#destroy
```

[moduleはコントローラーの名前空間を変更したい時に使う。](https://railsguides.jp/routing.html#%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%A9%E3%81%AE%E5%90%8D%E5%89%8D%E7%A9%BA%E9%96%93%E3%81%A8%E3%83%AB%E3%83%BC%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0)今回はリソース名と同じ名前を`module`に記述して、対応するコントローラー名をネストさせている

[DHH流のメリット](https://tech.kitchhike.com/entry/2017/03/07/190739)

[DHH流ルーティングについて](https://www.ryotaku.com/entry/2019/09/17/000000)
