# git-flowの導入から最初のブランチ作成まで

1. brew install git-flow
2. $ git flow init (in local)
3. $ git branch コマンドでブランチの状況を確認する
4. featureブランチを切る
  1. $ git flow feature start 01_login_logout
5. 開発が終わったら、featureブランチをdevelopブランチにマージする
  1. $ git add .
  2. $ git commit -m "hogehoge" 
  3. $ git flow feature finish 01_login_logout
  4. 3のコマンドでマージ・01_login_logoutブランチの削除・developブランチへの移動をしてくれる
  5. $ git push origin develp コマンドでリモートにプッシュ
  6. GithubでPRを出して、レビューをしてもらう
  7. GitHub上でマージしたら、再度developブランチからfeatureブランチを切り、次の開発を進める

[参考](https://qiita.com/ueueue0217/items/274fba0dff12d1e124b9)
[参考](https://qiita.com/masa7303/items/82ef36768077ca59d9f9))