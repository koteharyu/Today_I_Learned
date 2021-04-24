## m1 mac homebrewにmysqlをインストールする方法

1. する余裕があれば、`brew update`
2. `brew search mysql`でインストールできるmysqlを確認
3. `brew install mysql@<version>`
4. mysqlのパスを設定
  1. if you need to have mysql@version first in your path, run: 下の echoからコピー
5. ペースト
6. `view .zshrc`で中身を確認し、ペーストしたパスが記載されていることを確認
7. `source .zshrc`でmysqlのパスを反映させる
8. `mysql --version`でインストールの有無を確認
9. `mysql_secure_installation`コマンドでmysqlの初期設定を行う
10. Enterを押す
11. rootの新しいpassword, confirmationを入力
12. Remove anonymous users? の質問には、`y`を入力
13. Disallow root login remotely?以降の質問には`Enter`を入力
14. `All done`と入力されれば完了
15. `mysql --user=root --password`コマンドを入力し、先ほど設定したrootのパスワードを入力し、ログイン
16. `mysql> quit`でログアウト