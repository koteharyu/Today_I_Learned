# ransackなどのgemを使わずに検索機能を実装

今回はユーザーの検索を実装

```
# models/user

def self.search(search)
  if search
    User.where(['name LIKE ?', "%#{search}"])
  else
    User.all
  end
end
```

```
# 検索フォーム

= form_with url: search_users_path, method: :get, local: true do |f|
  = f.text_field :search, params[:search]
  = f.sbumit "search", class: "btn btn-primary"
```

```
# users_controller.rb

def index
  @users = User.search(params[:search])
end
```

<br>

## LIKE 曖昧検索

`WHERE カラム名 LIKE '値%'` ...`前方一致`

`WHERE カラム名 LIKE "%値"`...`後方一致`

`WHERE カラム名 LIKE '%値%'`...`部分一致`

`WHERE カラム名 LIKE "値_`...`値と末尾の一文字が一致`

<br>

`%`...0文字以上の任意の文字列

`_`...任意の一文字

<br>

[gemなしで検索機能を実装する](https://qiita.com/hayulu/items/6d121a2814997db099bb)
