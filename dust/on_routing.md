現場Rails chapter7-1-1

## routes.rb における　オプション `on`について

`on`オプションを使うことで、別のnewアクションを追加できる

```
# onオプションないバージョン

# routes.rb

resouces :tasks do
 post :confirm, action: :confirm_new
end

$ rails routes | grep tasks

task_confirm POST /tasks/:task_id/confirm(:format) tasks#confirm_new
```

```
# onオプションを使ったバージョン

# routes.rb

resouces :tasks do
 post :confirm, action: :confirm_new, on: :new
end

$ rails routes | grep tasks

confirm_new_task POST /tasks/new/confirm(:format) tasks#confirm_new
```

`on`オプションを付けることで、POST + `/tasks/new/confirm`のパスが認識され、tasksコントローラーの`confirm_new`アクションにルーティングされる

また、同時に、`confirm_new_task_path`や`confirm_new_task_url`のルーティングヘルパーが作成される