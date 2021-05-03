# ActiveModel::Model

ransackなどの検索用gemを使わずに検索機能を実装しようとしている際に、ここら辺の壁にぶち当たりまして、調べ出した次第です。

<br>

## そもそもActiveModelって何をしてるの？

ActiveModelのおかげで非ActiveRecordモデルとやり取りが実現できる

(ちなみにActiveRecordは、モデルに相当するもので、ビジネスデータとビジネスロジックを表すシステムの階層) by[Railsガイド](https://railsguides.jp/active_record_basics.html)

ActiveModelは多くのモジュールを含むライブラリで、クラスで使用する既知の一連のインターフェースを提供する

by[Railsガイド](https://railsguides.jp/active_model_basics.html)

<br>

## includeメソッドの復習

`include`メソッドは、クラスやモジュールに他のモジュールをインクルード(Mix-in)する。引数には、モジュールを指定する(複数指定可能)。戻り値はクラスやモジュール自身

[Rubyリファレンス](https://ref.xaio.jp/ruby/classes/module/include)

つまり、他のモジュールをincludeすることで、そのモジュール内で使われているメソッドなどが使えるようになると言うこと

クラスの継承とも似ているが、、、includeの引数に指定できるのは、モジュールだけなので注意

- クラスを引き継ぎたい場合は、クラスの継承
- モジュールを引き継ぎたい場合は、include

<br>

## ActiveModel::Model

`include ActiveModel::Model`となっているので、ActiveModel::Modelと言うモジュールを引き継いでいることがわかった。

ActiveModel::Modelをincludeすることで、次の機能が使えるよになる

- モデルの調査
- 変換
- 翻訳
- バリデーション
- form_withやrenderなどのAction Viewヘルパーメソッド

[Railsガイド](https://railsguides.jp/active_model_basics.html#model%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB)

<br>

## いったん結論

普通にクラスとして定義したままの状態では、モデルに使える機能(バリデーションや、form_withなど)などが使えないため、ActiveModel::Modelをincludeする

<br>

[include ActiveModel::Modelとは](https://www.y-hakopro.com/entry/2019/10/15/204805)
