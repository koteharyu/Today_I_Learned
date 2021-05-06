# 空白で検索文字列を区切って検索する方法

<br>

## 半角スペースでつなげることでor検索ができるようにする。e.g.「rails ruby」

まずは、検索フォームから送られてきたwordを空白で区切る

### 必要な前提知識

`split`メソッド...`"対象の文字列".split("区切りにする文字", "分割する回数")`

分割する回数は省略可能。もし省略した場合は、区切りにする文字全ての箇所で分割する

splitメソッドは、分割した文字列を配列として返すことに注意

<br>

次に空白の処理

指定では、半角空白でOR検索とするなので、split('<半角空白>')で要件を満たせそうだが、一手間加えて、全角空白でも対応できるようにしてみる

正規表現`[[:blank:]]`は、空白演算子と呼ばれるもので、半角・全角の空白を対象にしてくれるらしい

`+`を指定することで、連続した空白を除去してくれる

完成形としては、`/[[:blank:]]+/`になる

[キーワードを全角込みの空白で区切る](https://qiita.com/nao58/items/bf5d017a06fc33da9e3b)

<br>

### 実装

入力フォームから受け取った値を処理する箇所は、posts_controllerのsearchアクションであるため、そこに追記していく

大まかな流れとしては、送られてきた値を空白ごとに区切り、eachで回し、区切った値それぞれを@postに代入していく感じ

```
# posts_controller.rb

  def search
    #空白で繋いで、OR検索
    @search_form = SearchPostsForm.new(params.require(:search).permit(:body))
    search_forms = @search_form.body.split(/[[:blank:]]+/)
    search_forms.each do |key|
      @posts = Post.where('body LIKE ?', "%#{key}%")
    end
    @posts.page(params[:page])
  end
```

<br>

[検索キーワードを空白で2つに分ける](https://qiita.com/kusuhara_yuna/items/0b909ba38124c18ca6e2)
[railsで複数ワードでの検索機能](https://qiita.com/Orangina1050/items/ca4e5dc26e0a32ee3137)
[キーワードを全角込みの空白で区切るRuby](https://qiita.com/nao58/items/bf5d017a06fc33da9e3b)

正直、ここは、エラーが出て先に進めれなかったので、一旦後回しにしようと思う。。。

絶対追記するし、実装させる！！
