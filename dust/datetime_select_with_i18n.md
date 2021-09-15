# datetime_selectとi18nの共存

datetime_selectを使用している箇所に以下のエラーが発生したため、その解決策を残す

```
ActionView::Template::Error (undefined method `map' for "translation missing: ja.date.order":String):
```

## 解決策

原因としては、`ja.date.order":String`が定義されていないということだろう

そのため、`locales/ja.yml`を以下のようにすれば良い

```rb
ja:
  date:
    order:
      - :year
      - :month
      - :day
```

### ちなみに

以下を基準にしたら良さそう

```rb
ja:
  date:
    formats:
      default: "%Y/%m/%d"
      short: "%m/%d"
      long: "%Y年%m月%d日(%a)"

    day_names: [日曜日, 月曜日, 火曜日, 水曜日, 木曜日, 金曜日, 土曜日]
    abbr_day_names: [日, 月, 火, 水, 木, 金, 土]

    month_names: [~, 1月, 2月, 3月, 4月, 5月, 6月, 7月, 8月, 9月, 10月, 11月, 12月]
    abbr_month_names: [~, 1月, 2月, 3月, 4月, 5月, 6月, 7月, 8月, 9月, 10月, 11月, 12月]

    order:
      - :year
      - :month
      - :day

  time:
    formats:
      default: "%Y/%m/%d %H:%M:%S"
      short: "%y/%m/%d %H:%M"
      long: "%Y年%m月%d日(%a) %H時%M分%S秒 %Z"
    am: "午前"
    pm: "午後"

```
