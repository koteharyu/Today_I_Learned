# add_flash_typesについて

application_controllerに`add_flas_types`の記述があり、気になったので調べたみた

ざっくりいうと、`add_flas_types`メソッドを使うことで、flashのキーを自由に指定できるらしい

つまり

```
# application_controller.rb

class ApplicationController < ActionController::Base
 add_flash_types :success, :info, :warning, :danger
end
```

と記述することで、bootstrap対応のキーを使用することができるようになるというわけ

[RailsでflashメッセージをBootstrapで表示するスマートな方法](https://www.tom08.net/entry/2017/02/08/215921)
[Railsドキュメント](https://railsdoc.com/page/add_flash_types)
