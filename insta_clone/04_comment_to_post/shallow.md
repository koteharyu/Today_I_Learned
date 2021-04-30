# shallowとは？？

shallowを使ってネスト構造を作ることで、不要なリソースを作らずに済む。

```
resources :articles do
 resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :updae, :destroy]
```

と

```
resources :articles do
 resources :comments, shallow: true
end
```

は、同じリソースを生成する

[Railsガイド2.7.2](https://railsguides.jp/routing.html)

<br>

```
resources :reviews, expect: [:index] do
 resources :likes, only: [:create, :destroy]
end

$ rails routes

review_likes POST /reviews/:review_id/likes(.format) likes#create
review_like DELETE /reviews/:review_id/like/:id(.format) likes#destroy
```

となる。

likesのidがレビューのidに依らず一意であるならば

```
/likes/:id(.format)
```

でも良い

つまり、:review_idを含めないようにするということ

shalow: trueオプションを使ことで、理想的なURLが生成され、prefixも少し短くすることができる

```
resources :reviews, expect: [:index] do
 resources :likes, only: [:crete, :destroy] , shallow: true
 end
end

$ rails routes

review_likes POST /reviews/:review_id/likes(.format)
      like DELETE /liks/:id(.format)
```

[shallowオプション](https://kossy-web-engineer.hatenablog.com/entry/2018/10/17/063136)

<br>

# instaclone

## not user shallow

```
resources :posts do
  resources :comments
end

$ rails routes | grep comments

post_comments GET    /posts/:post_id/comments(.:format)                                                       comments#index
            POST   /posts/:post_id/comments(.:format)                                                       comments#create
new_post_comment GET    /posts/:post_id/comments/new(.:format)                                                   comments#new
edit_post_comment GET    /posts/:post_id/comments/:id/edit(.:format)                                              comments#edit
post_comment GET    /posts/:post_id/comments/:id(.:format)                                                   comments#show
            PATCH  /posts/:post_id/comments/:id(.:format)                                                   comments#update
            PUT    /posts/:post_id/comments/:id(.:format)                                                   comments#update
            DELETE /posts/:post_id/comments/:id(.:format)                                                   comments#destroy
```

確かに、`:post_id`が付与されてしまっている

<br>

一転、`shallow: true`オプションをつけることで

```
resources :posts, shallow: true do
    resources :comments
end

$ rails routes | grep comments

post_comments GET       /posts/:post_id/comments(.:format)                                                       comments#index
              POST      /posts/:post_id/comments(.:format)                                                       comments#create
new_post_comment GET    /posts/:post_id/comments/new(.:format)                                                   comments#new
edit_comment GET        /comments/:id/edit(.:format)                                                             comments#edit
comment GET             /comments/:id(.:format)                                                                  comments#show
            PATCH       /comments/:id(.:format)                                                                  comments#update
            PUT         /comments/:id(.:format)                                                                  comments#update
            DELETE      /comments/:id(.:format)                                                                  comments#destroy
```

paramsからコメントpost.idを自動的に取得するため、`:post_id`を省略できる
