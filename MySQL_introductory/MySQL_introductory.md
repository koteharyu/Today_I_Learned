# [MySQLで学ぶデータベース](https://www.udemy.com/share/103jPaAEAbeVhRRX4D/)

<br>

## 5

入門書なでには大文字での記述になっているがmysqlは大文字でも小文字でもどちらでも記述できる

`create database <データベース名>;`...データベースを作成するコマンド

`show databases;`...既存のデータベースを参照するコマンド

`drop database <データベース名>;`...指定したデータベースを削除するコマンド

SQLは`;`単位で一行と認識するため、どこで改行しても末尾に`;`をつければ良い

create databaseのオプション指定

```
create database if not exists <データベース名>
  charcter set=utf8mb4
  collate=utf8mb4_bin
  encryption='N';
```

`charcter set=utf8mb4`...文字コードの指定、マルチバイトを４バイトとして扱う

`collate=utf8mb4_bin`...collateとは照合順序。文字コードとバイナリーを指定。一番厳密な比較の方法

`encryption='N'`...暗号化のこと。Yにすると暗号化できる

`use <データベース名>`...使用するデータベースの切り替えコマンド。選択されているデータベースは太文字になってるよ

<br>

## 6

`create table <テーブル名>(<カラム名> データの型, <カラム名> データの型, <カラム名> データの型);`...テーブルとカラムの作成

`shwo tables;`...選択中のテーブルを表示

テーブルの中身(columns)の確認方法

1. `desc <テーブル名>;` (desc == describe)
2. `show columns from <テーブル名>;`

<br>

テーブルのイメージはエクセル。シートがテーブル

縦...カラム、フィールド

横...レコード

`drop table <テーブル名>;`...テーブルの削除をするコマンド

<br>

## 7

`alter table <テーブル名> add column(省略可) <追加カラム名> <データ型>`...カラムの追加コマンド。一番下にカラムが追加される

`first`オプションをつけることで、追加するカラムを先頭に追加できる

`after <既存のカラム名>`オプションをつけることで指定したカラムの次に追加することができる

`alter table <テーブル名> rename column(省略可) <変更前カラム名> to <変更したいカラム名>;`...既存のカラム名の変更

`alter table <テーブル名> modify column(省略可) <既存にカラム名> <変更したいデータ型を指定>;`...指定したデータ型へのカラム変更

modifyは、カラムと型を指定しなければいけないという癖があるが、first, afterオプションを使って、カラムの順番を変更することも可能

`alter table <テーブル名> drop column <カラム名>;`...指定したカラムの削除

### 注意

カラムやカラムの型は簡単に変更できるが、すでにデータが格納されているカラムの型を変更するには、すでに格納済みのデータの型と一致しなくなるなどデメリットが多いため、設計を重要視するように!!

<br>

## 8 insert

`insert into`...カラムにデータを挿入

```
insert into <テーブル名> values(<カラムに対応する値>,<カラムに対応する値>,<カラムに対応する値>,<カラムに対応する値>);

select <カラム>,<カラム>,<カラム>,<カラム> from <テーブル名>;
```

```
insert into <テーブル名> (特定のカラム指定) values(指定したカラムに対応する値);

select * from <テーブル名>;
```

`*`はテーブル内の全カラム指定

特定のカラムのみにデータをinsertしたSQLを発行するごとにレコード数が増える

`truncate <テーブル名>`...指定したテーブル内のデータを全て削除するコマンド(カラムは消えませんよ)

### nullと空文字

データを何も指定しなければ`null`がレコードに記録される

('')のように空文字をデータ登録すると空欄(空)が登録される

`alter table <テーブル名> modify column <カラム名> <カラムの型> not null;`...not null制約を追加

そうすることで、指定されたカラムにnullが登録されそうになるとエラー(dosent have a default value)が出る

(空文字とnullは違うので、空文字は登録できる)

<br>

### date型

`date型`は、日付を格納する型

指定方法は２つある

- '2020-10-10'のように、`-`で区切る
- '2020/10/10'のように、`/`で区切る

<br>

### datetime型

日付と時刻を格納する型

<br>

## 9 primary key

### unique key

`unique key`オプションをつけることで、idのように重複しない、ユニークな値のみ格納するように指定できる

顧客番号カラムの追加流れ

1. truncate 顧客情報　... 顧客情報テーブルにあるデータを全て削除
2. alter table 顧客情報 add column 顧客番号 init unique key;

<br>

### primary key

日本語だと`主キー`という

カラム詳細に`PK`の表示がつく

<br>

### auto_increment

カラム詳細に`AI`の表示がつく

unique key や primary keyは、重複したデータを格納できないようにすることができるが、いちいち連番を手動で降らなければいけないというデメリットがある。

そのデメリットを解決するための手段が`auto_increment`オプションだ

このauto_incrementオプションを指定することで、`insert into 顧客情報 (顧客名) values('haryu'); `と顧客番号の値を指定しなくても自動的に対応するユニークな番号が降られて便利

addする場合`alter table <テーブル名> add <追加するカラム> int auto_increment`とするとエラーになったので、まずは`primary key`オプションを指定した上で`alter alter table <テーブル名> add <追加するカラム> int auto_increment`をする必要がありそうだ

create tableする場合は、以下のように一括で指定できる

```
create table <テーブル名> (商品ID int primary key auto_increment, 商品名 text)
```
<br>

## 10 delete・update

`delete from <テーブル名> where <カラム名>=<値>;`...カラム名が値であるレコードを削除する

`update <テーブル名> set <カラム名>="<値>" where <カラム名>=<値>;`

<br>

## 11 import

`varchar(文字数)`...文字制限をかけることができる

`where句`で絞り込み条件を指定できる

その際使用できるのは、=, <, >, <=, >=, <>

`<>`...ノットイコール。つまり等しくない `!=`と同意

## 12 and/or

論理演算子で繋げることもできるよ

`and not`

`select * from 顧客 where 姓="上野" and not(名="孝")` #=> 上野正樹

つまり、性が上野かつ、名が孝でない人って意味

### and or で繋ぐときの注意

`select * from 顧客 where (姓="上野" or 名="孝") and 生年月日="1961-02-13";`のように条件が正しく動作するよう`()`で括る必要があるので注意

## 14 like曖昧

select * from 顧客 where 姓 `like` "上`%`"; #=> 上野　上杉。。。

select * from 顧客 whrer 姓　`like` "`%`上"; #=>　川上　最上。。。

select * from 顧客 where 姓　`like` "`%`上`%`" #=> 上野　上杉 川上　最上。。。

"上`%`"...`前方一致`

"`%`上"...`後方一致`

"`%`上`%`"...`部分一致`

## 15 order by

デフォルトでは、primary key auto_incrementが指定されているカラムが`asc`昇順で並んでいる

select * from 顧客 order by id desc; #=> idが降順になり、大きいから小さいに並び変わる

int date型の場合、すんなりorder byできるが、漢字やひらがなとカタカナが混ざったカラムをorder byする際は注意が必要

漢字の場合、それぞれ振られている文字コードの管理順に並ぶため、50音順には並ばない

ひらがなとカタカナが混ざってる場合、まずはひらがなが50音順に並び替えられ、次にカタカタが並び変わるため、ひらがな・カタカタどちらかで統一したほうがいいかもね

## 16 limit

limit句を使うことで、取得する件数を限定することができる。mysql work benchではデフォルトでは1000件

select * from 顧客 limit 10 =#> 1~10

select * from 顧客 limit `20`, 10 #=> 21~30

ここでいう`20`は、飛ばす件数を指定している。つまり21番目から10件取得するという意

### where, order by, limitの順番に注意

1. where
2. order by
3. limit

の順番に繋げないとエラーになるよ

select * from 顧客 where 姓 like '上%'(前方一致) order by id desc limit 3; みたいに使用しよう

## 17 relation

safe updateの解除方法

1. MySQLWorkBenchをクリック
2. preferences...
3. SQLEditor
4. 一番下にある、Safe Updatesのチェックを外す
5. OKクリック
6. 画面閉じたら、reconnect to DBMSボタンをクリックし、再接続する

`describe(desc) <テーブル名>`...指定したテーブルの構造を確認

## 19 inner join 2つのテーブルを接続

select * from 商品 innner join カテゴリー on 商品.カテゴリー = カテゴリー.id;

```
select * from <結合したいテーブル１> inner join <結合したいテーブル２> on <結合したいテーブル１>.<カラム名> = <結合したいテーブル２>.<カラム名>
```

select * from 商品, カテゴリー where 商品.カテゴリー = カテゴリー.id

```
select * from <結合したいテーブル１>,<結合したいテーブル２> where <結合したいテーブル１>.<カラム> = <結合したいテーブル２>.<カラム>
```

基本的に<結合したいテーブル>は省略可能だが、`id`などの<結合したいテーブル>は省略できないので注意（両テーブル内のユニークなカラムなら省略可能と言う認識でいいだろう）

Relational DataBase = RDB

## 20 3つのテーブルのリレーション

```
select * from 購入履歴, 顧客, 商品 where 購入履歴.顧客 = 顧客.id
	and 購入履歴.商品 = 商品.id;
```

のように、`,`区切りで結合するテーブルを指定し、対応するカラムをくっつける

## 外部結合

`inner join`を使って結合すると、両方のテーブルに値があるものを表示するため、購入履歴がない客の情報が表示されないというデメリットがある

そのために外部結合を使用する

`left join`...左のテーブルをベースに右のテーブルを結合する...つまり左に指定したテーブルは全て表示した上で、右のテーブルをサブ的な感じで結合する

```
select * from 顧客(左) left join 購入履歴(右)
  on 顧客.id = 顧客
```

`right join`...left joinの全く真逆

### inner join, left joinは結合可能

```
select * from 顧客 left join 購入履歴 on 顧客.id = 顧客
  inner join 商品 on 商品.id = 商品
  order by 顧客.id
```

## 22 max/min/concat

### concat

select `concat`(姓,名) from 顧客; #=> 姓カラムと名カラムを繋げて表示できる

### distinct(重複を取り除く)

select `distinct` 姓 from 顧客 order by 姓; #=> 重複する苗字の人を１人だけ表示する

### 計算

select *, 価格 * 1.1 from 商品;

#=>

|id|カテゴリー|商品名|価格|価格*1.1|
|-|-|-|-|-|
|1|1|Tシャツ|1200|1320.0|
|2|1|パーカー|2500|2750.0|

新たに指定したカラムを一時的に表示できる

でも、新たにできたカラム見にくいよね...そんな時は`as`を使ってカラム名を指定しよう！

select *, 価格 * 1.1 as 税込価格 from 商品;

#=>

|id|カテゴリー|商品名|価格|税込価格|
|-|-|-|-|-|
|1|1|Tシャツ|1200|1320.0|
|2|1|パーカー|2500|2750.0|

### 件数取得 count

select count(*) from 商品;

とすることで、商品テーブルに格納されているレコード件数を全件取得する

### sum 合計

select sum(価格) from 商品; #=> 商品カラムの合計値を出す

### avg 平均

select avg(価格) from 商品; #=> 商品カラムの平均値を出す

### max 最高値

select max(価格) from 商品; #=> 商品カラムの最高値を出す

### min 最低値

select min(価格) from 商品; #=> 商品カラムの最低値を出す

## 23 group by

購入履歴テーブルの商品ごとの件数の取得したい

```
select sum(個数) from 購入履歴 where 商品=1

#=> 商品idが１の合計件数が取得
```

いちいち商品のidを打ち直して件数を取得するのは、日が暮れる

そのために、`group by`を使って一気に絞る！

```
select 商品, sum(個数) from 購入履歴 group by 商品;
```

イメージは、参照するテーブル内のカラムで絞る感じかな

## 24 view

viewを作ることで、複雑なselect構文を簡単に呼び出すことができる

```
create view <View名> as
  select 商品.id as 商品ID, カテゴリー名, 商品名, 価格
    from 商品 inner join カテゴリー
    on カテゴリー=カテゴリー.id;
```

注意！

view名は、viewとも、テーブルとも、データベースとも違う一意な名前にすること

```
select * from <ビュー名>  # コマンドで、ビューを見れる
```

`create or replcae`構文を使うことで、存在しなければ作成、存在していれば、上書きすることができる便利な記法

## 25 sub query

サブクエリとしたいselect文を()でくくり、名前をつける

`(select ~~~~) as <任意なサブクエリ名>`

## 26 union

`union`とは、２つのセレクト文を繋ぐことができる。似たデータ構造時のみ使おう

```
select 姓, 名 from 顧客
union
select 姓, 名 from メルマガ顧客
```

よって、顧客データの下にメルマガ顧客が追加される

`union`は重複を取り除くので、それが嫌なら`union all`を使う
