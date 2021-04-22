# route.rbで使用する`member`と`collection`についての自分なりのまとめ

<br>

## `member`と`collection`との違い

ざっくりいうと、`id`が付与されるかされないかの違い

`member`は`id`が付与される

`collection`は`id`が付与されない

<br>

## `member`

```
resouces :posts do
 member do
   get :comments
 end
end
```

とすることで、`/posts/:id/comment`のように、postを識別するための`id`が付与された、commentsについてのルーティングができる

<br>

## `collection`

```
resouces :users do
 collection do
   get :slide
 end
end
```

とすることで、`/users/slide`のように、slideアクションのurlにuserを識別するための`id`が付与されない