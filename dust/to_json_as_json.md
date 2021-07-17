# as_jsonとto_jsonの違い

`as_json`...JSONに近いハッシュに変換するメソッド

`to_json`...JSONを文字列化させるメソッド

## 例

```
example_hash = { hoge: "fuga" }
#=> {:hoge=>"fuga"}
```

as_json

```
example_hash.as_json
#=> {"hoge"=>"fuga"}
```

to_json

```
example_hash.to_json
#=> "{\"hoge\":\"huga\"}"
```
