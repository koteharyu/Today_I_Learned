# CarrierWaveのCache機能について

## cacheとは

Cacheとは、バリデーションの失敗後でも選択したファイルを記憶・保持してくれる機能のこと

```
# models/user

validates :name, presence: true
validates :email, presence: true
```

models/userでは、nameとemailにpresence: trueのバリデーションが設定されているため、プロフィールを更新する際に、name, emailどちらか、または両方が空欄であればバリデーションエラーが発生し、edit.html.slimにレンダーされる流れである。

そうなれば、再度必要事項を記入し、再度アバターにしたい画像を選択する必要が生じてしまう。

このcache機能を使えば、再度画像ファイルを選択する必要を省くことができる

## 実装方法

以下の２点を実装することで、cache機能を使うことができる

- 画像アップロード時に`<カラム名>_cache`という名前のhidden_fieldを追加する
- ストロングパラメーターに`<カラム名>_cache`の記述を追記する

## 実装

```
# mypage/accounts/edit.html.slim

= form_with model: @user, url: mypage_account_path, local: true do |f|
  = f.hidden_field :avatar
```

```
# mypage/accounts_controller

def account_params
  params.require(:user).permit(:name, :email, :avatar, :avatar_cache)
end
```

[CarrierwaveのCache機能を使用し、バリデーション後の画像データを保持する方法](https://techtechmedia.com/cache-carrierwave-rails/)
