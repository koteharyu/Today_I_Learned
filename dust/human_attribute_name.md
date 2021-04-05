## human_atribute_name(:カラム名)について

`ActiveRecord::Base`クラスメソッドであり、内部的に`i18n`モジュールを利用するクラスメソッド。

つまり、`config/locales/ja.yml`に定義している翻訳内容を解釈してくれるメソッド。

```
<object>.human_attribute_name(:カラム名)
```