## localsについて

仮にposts_controllersに以下の記述があるとして

```posts_controllers.rb
def show
  @post = Post.find(params[:id)
end
```

```posts/foobar.html.erb
<%= render partial: 'post_partial', locals: { post: @post } %>

または省略形で
<%= rendner 'post_partial', post: @post %>
```

```posts/_post_partila.html.erb
<%= post.title%>
<%= post.body %>
```

```公式
公式(省略形)
<%= render 'パーシャル名', ローカル変数: インスタンス変数名 %>
```

つまりlocalsオプションを使用することで
`@post`というインスタンス変数を`post`というローカル変数に変換することができる。

<br>

## collectionについて

仮にposts_controllersに以下の記述があるとして

```posts_controllers.rb
def index 
  @posts = Post.all
end 
```

```posts/index.html.erb
<%= render partial: 'each_post', collection: @posts %>

応用形 asオプションでローカル変数を指定することができる
<%= render partial: 'each_post', collection: @posts, as: :post%>

```

collectionオプションを使用しなかった場合は以下の記述になるが

```posts/_each_post.html.erb
#collectionを使わなければ
<% @posts.each do |post| %>
  <%= post.body%>
<% end %>
```

collectionオプションを使用するで
eachメソッドを省くことができるため簡潔に記述することができる

```posts/_each_post.html.erb
#collectionを使用することで
<%= post.body%>
```
