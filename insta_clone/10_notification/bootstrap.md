通知機能実装時に使用したbootstrapについて軽くまとめる

```
# shared/header(一部抜粋)

li.nav-item
 .dropdown
   a#dropdownMenuButton.nav-link.position-relative href="#" data-toggle="dropdown" aria-expanded="false" aria-haspopup="true"
     = icon 'far', 'heart', class: "fa-lg"
     = render 'shared/unread_badge'
   #header-notifications.dropdown-menu.dropdown-menu-right.m-0.p-0 aira-labelledby="dropdownMenuButton"
     = render 'shared/header_notifications'
```

### dropdown

1. 親要素に`dropdown`クラスを付与
2. idに`dropdownMenuButton`を付与することで、buttonタグとして生成される
3. dropdownとして表示させたい項目の親要素に`dropdown-menu`クラスを付与
4. dropdownとして表示させたい項目の親要素に`aria-labelledby="dropdownMenuButton"`も付与(ボタンとドロップダウンを関連付けるため)
5. 表示させる項目に`dropdown-item`クラスを付与


- aria-XXX...読み上げブラウザなどに付加情報を与えるもの
- aria-haspopup="true"...要素がポップアップ部品をもつことを示す

[リファレンス](https://getbootstrap.jp/docs/4.2/components/dropdowns/)

[labelledby](https://bootstrap-guide.com/components/dropdowns)

[aria-haspopup](https://www.tohoho-web.com/bootstrap/dropdown.html)

[aria-XXX](https://www.tohoho-web.com/bootstrap/collapse.html)
