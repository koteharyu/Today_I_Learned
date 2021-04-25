gem 'font-awesome-sass', '~> 5.4.1'

をbundleインストールした際にエラーが発生し、インストールできなかった。

[この記事](https://srcw.net/archives/477)
[と、この記事](https://sustainabilityrvl.hatenablog.com/entry/2020/03/07/213946)

を参考に、インストールができた。

`gem 'font-awesome-sass', '< 5.0.13'`バージョンをこのように古く指定することで解決

## 導入までの流れ

`app/assets/stylesheets/application.scss`に

```
#app/assets/stylesheets/application.scss

@import 'font-awesome-sprockets';
@import 'font-awesome';

```