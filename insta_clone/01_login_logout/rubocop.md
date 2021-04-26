## rubocopとは

Rubocopとは、コーディング規約に沿っているかを確認できる「静的コード解析ツール(コーディングチェックツール)」のこと。ソースコードの品質を下げないために使われるRubyのコーディングチェックツール

- チェック出来る項目(他にもいっぱいあるけど)
 - インデント
 - 文字数の長さ
 - メソッド内の行数
 - 条件式の見やすさ
 - ソースコードの複雑度
 - ハッシュなどの末尾にあるカンマの有無

### 導入

```
# Gemfile

group :development do
 gem 'rubocop', require: false
 gem 'rubocop-rails'
end
```

rubocopは、ターミナル等で使用するため、bundlerによってアプリ側に自動で読み込む必要がないため、`require: false`にしている

### 設定ファイルについて

`$ bundle exec rubocop --auto-gen-config`コマンドで設定ファイルを作成

`.rubocop.yml`とは、独自のコーディング規約を設定するファイル。`inherit_from: .rubocop_todo.yml`を記述して、読み込む必要がある

`.rubocop_todo.yml`とは、規約を無視するための設定ファイル。現状は対応できない規約を一時的にスルーするための設定が書かれたファイル。そのため、最終的にはこのファイルの中身を空にすることが望ましい

### RuboCopの設定ファイルを変更

現状では、rubocopコマンドで出た警告をすべてスルーするという内容の記述が書かれているため、警告が1つも出ないため、.rubocop.ymlを編集する

```
inherit_from: .rubocop_todo.yml

# 追記した規約ファイルの読込
require:
 - rubocop-rails

# This file overrides https://github.com/bbatsov/rubocop/blob/master/config/default.yml

AllCops:
 # 除外ファイル
 Exclude:
   - 'vendor/**/*'
   - 'db/**/*'
   - 'bin/**/*'
   - 'spec/**/*'
   - 'node_modules/**/*'
 # どのCOPに引っかかったのかを表示する
 DisplayCopNames: true
Rails:
 Enabled: true

# ブロックが正しく記述されているかのCOP
Layout/MultilineBlockLayout:
 # 除外
 Exclude:
   - 'spec/**/*_spec.rb'

Metrics/AbcSize:
 Max: 25

Metrics/BlockLength:
 Max: 30
 Exclude:
   - 'Gemfile'
   - 'config/**/*'
   - 'spec/**/*_spec.rb'
   - 'lib/tasks/*'

Metrics/ClassLength:
 CountComments: false
 Max: 300

Metrics/CyclomaticComplexity:
 Max: 30

Metrics/LineLength:
 Enabled: false

Metrics/MethodLength:
 CountComments: false
 Max: 30

Naming/AccessorMethodName:
 Exclude:
   - 'app/controllers/**/*'

# 日本語でのコメントを許可
Style/AsciiComments:
 Enabled: false

Style/BlockDelimiters:
 Exclude:
   - 'spec/**/*_spec.rb'

# モジュール名::クラス名の定義を許可
Style/ClassAndModuleChildren:
 Enabled: false

# クラスのコメント必須を無視
Style/Documentation:
 Enabled: false

# 文字リテラルのイミュータブル宣言を無視
Style/FrozenStringLiteralComment:
 Enabled: false

Style/IfUnlessModifier:
 Enabled: false

Style/WhileUntilModifier:
 Enabled: false

Bundler/OrderedGems:
 Enabled: false
Rails/OutputSafety:
 Enabled: true
 Exclude:
   - 'app/helpers/**/*.rb'

Rails/InverseOf:
 Enabled: false

Rails/FilePath:
 Enabled: false
```

### ファイルの自動修正

`--auto-correct`オプションを使うことで、警告している箇所をある程度自動修正してくれる

または`-a`

Rubocopではどうやって修正したら良いかわからない箇所はスキップするため、ある程度

Rubocopが自動修正できた箇所は`Corrected`と表示される

`bundle exec rubocop`コマンドで、最終的に以下のような状態になれば、ソースコードの品質が保たれているといえる

```
$ rubocop
Inspecting 19 files
...................

19 files inspected, no offenses detected
```

まだまだ全然理解できてない。

[rubocop.org](https://rubocop.org/)
[Railsの品質を上げるRuboCopとは？インストールや使い方を紹介！](https://kitsune.blog/rails-rubocop)
[rubocopとは？](https://qiita.com/freestylehh46/items/f8dae4b962df681ed2ad)
[rubocop のしつけ方](https://blog.onk.ninja/2015/10/27/rubocop-getting-started)
[reference](https://qiita.com/piggydev/items/074e020e07af7ebc872d)