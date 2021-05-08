# miketaさんから教えて頂いた内容まとめ

<br>

## 疑問点

1. Relationship.find(params[:id]).followed
2. Post.where(user_id: following_ids << id)

<br>

## 1 Relationship.find(params[:id]).followed

relationships_controller内のdestroyアクションにてこの記述があったが、特に`.followed`の箇所がなにをしているのかわからなかった

```
# relationships_controller

def destroy
 @user = Relationship.find(params[:id]).followed
 current_user.unfollow(@user)
end
```

予想としては、DELETE時に生成されるURLは/relationships/:idであるため、params[:id]にてRelationshipのidを取得し、そのIDが含まれるレコードのfollowed_idのユーザー情報を@userに代入するために必要な処理だと考えていた。

<br>

## 結論の前にまずは、考え方について

`Relationship.find(params[:id]).followed`は、少し複雑に見えるため、難しく思えてしまう。なので一旦、簡単な例を元に考え方を整理する。

例えば、以下のような、userは複数のpostを投稿できるようなリレーションシップがある場合

```
# models/user

has_many :posts
```

```
# models/post

belongs_to :user
```

userとpostは、1対多の関係だと言える

idが１であるユーザーが投稿した全てのpostを取得するには、`User.find(1).posts`とすればＯＫ

逆に、idが2であるpostを投稿したユーザーを取得するには、`Post.find(2).user`とすればＯＫ

これは、上記で定義したアソシエーションがあるから実現できている

<br>

できるかわからないが、上記の方法でそれぞれ取得できる理由を言語化してみる。

`has_many :posts`は、userモデル内で定義しているので、userは複数のpostsを保持することができるという意味。表現的に正しいか微妙だが、イメージとしては、この関連付けをすることで、userに関連づいているpostの集合体(配列)を返す`posts`メソッドが使えるようになる。

`belongs_to :user`は、postモデル内で、定義しているので、それぞれのpostはあるuserに紐づいている。これもイメージではあるが、postを投稿したuserを返す`user`メソッドが使えるようになる。

<br>

## Relationshipテーブルのおさらい

relationhsipsテーブルは、id, follower_id, followed_idのカラムを持つテーブルであることを再確認

```
relationships:
 id:          integer
 follower_id: integer
 followed_id: integer
```

<br>

## 話を`Relationship.find(params[:id]).followed`戻す

userとpostの関係をベースに`Relationship.find(params[:id]).followed`を紐解いていく。

まずは、`followed`とは何なのかについて。

この`followed`とは、先ほどのuserとpostの関係でいうと`Post.fist.user`の`user`に当たるメソッドのこと。つまり、`followed`メソッドは既にどこかに定義してあるということだ...

あった！

```
# models/relatioship

belongs_to :followed, class_name: "User"
```

`followed`メソッドを使うことで、`Relationship.first.followed`とすると、idが1であるレコードのfollowed_idと同じidを持つユーザー情報が返ってくる

つまり`@user = Relationship.find(params[:id]).followed`で行っている処理の流れとしては、次のようになる

1. アンフォローのリクエストをした際に生成されるURLは、/relationships/:id
2. params[:id]でrelationshipsのidを取得し、そのレコードを検索
3. そのレコードのfollowed_idカラムに格納してあるidと同じidをお持つuserをusersテーブルから取得
4. そのユーザーを@userに格納し、そのユーザーをfollowingから削除する

<br>

## 2 Post.where(user_id: following_ids << id)

ここでは、自分と、自分がフォローしているユーザーの投稿だけをfeedとして取得したい

`<< id`の理解があいまいだったので、この機会に解説して頂きました。

<br>

## そもそも`_ids`はどこからやってきたのか

`_ids`メソッドとは、ActiveRecordが用意しているかなり便利なメソッド。例えば、current_userがフォローしているユーザーのidを取り出したい時は、`current_user.folliwing.map(&:id)`と記述することで、idという変数にそれぞれ格納され取得できる。`_ids`メソッドを使うともっと簡単に記述ができるそう

`current_user.following_ids`これだけで、フォローしているユーザーのidが`配列`として返ってくる。すごすぎ

`following_ids`メソッドは、`has_many :following`の関連付をした際に、ActiveRecordが自動生成したものらしい。なるほど！

<br>

`current_user.following_id`とするとcurrent_userがフォローしているユーザーのidが配列として返ってくる

<br>

## Post.where(user_id: following_ids << id)の記述先

Post.where(user_id: following_ids << id)はmodels/user内に記述してる

そのため、`id`は、current_userのidという意味

`<<`は、配列へのpushのエイリアスであるため、following_idsにcurrent_userのidをpushしているということ

わかりやすく書き換えるとこんなイメージになるだろう

`Post.where(user_id: current_user.following_ids << current_user.id)`

<br>

## 結論

つまり、feedメソッドをuserクラスのオブジェクト(current_user)に対して呼び出すことで、current_userの投稿とcurrent_userがフォローしているユーザーの投稿を取得することができるというわけ！

```
# models/user

def feed
 Post.where(user_id: following_ids << id)
end
```

```
# posts_controller

def index
 @posts = current_user.feed
end
```

<br>

## 感謝

miketaさん、わざわざ貴重なお時間を頂いての解説ありがとうございました！疑問点が解決できただけでなく、他にも関連した技術や考え方まで教えて頂いてかなり勉強になりました！解答してもらうことは期待せずこれからも頼りにさせて頂きますw

## 自分の言葉で伝えるの難しい...

自分の中では、miketaさんの解説を聞くことで、かなり腑に落ち納得することができたが、もし自分と同じところで詰まった人がこの記事を見て解決したり納得したりさせれるのか...自身はない...

もっともっと自分の言葉でアウトプットに落とし込めるよう練習していきたいと思った。
