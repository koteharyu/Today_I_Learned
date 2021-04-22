# form関係のヘルパーのオプションである`multipart`について

`multipart`とは、画像やCSVなどのデータの種類を指定すること

もしもマルチパートを指定していないと、ファイルを読み込んでも、ファイル名をただの文字列として認識してしまい、ファイルを画像やCSVとし取り込むことができなくなる

例えば、`image.jpeg`を読み込んでも、image.jpegという文字列としてだけ認識される

<br>

`multipart: true`をオプションで付けることで、マルチパートを認識可能にする

画像を画像として、CSVをCSVとして取り込みたい場合は、`multipart: true`と記述して、マルチパートの指定をする

よって、ファイルそのものを正しく読み込むことができる

<br>

Rails4以降のformヘルパーでは、`multipart: true`を省略可能にできる

<br>

以下のように、関連付けられた`file_field`が存在すれば自動的に`multipart: true`が適用される

```
= form_with url: import_csv_path, local: true do |f|
 = f.file_field :file
 = f.submit t('common.button.import')
```