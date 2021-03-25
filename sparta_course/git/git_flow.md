# git flow とはなんぞや？

<br>

[参考記事](https://qiita.com/KosukeSone/items/514dd24828b485c69a05)

<br>

- 用語説明
 - master/main 
   - プロダクトとしてリリースするためのブランチ。リリースしたらタグを付ける
 - develop
   - 開発ブランチ。コードが安定し、リリース準備ができたらmaster/mainへマージする。リリース前はこのブランチが最新バージョンとなる
 - feature branches
   - 機能の追加。developから分岐し、developにマージする
 - hotfixes
   - リリース後のクリティカルなバグフィクスなど、現在のプロダクトのバージョンに対する変更用。master/mainから分岐し、master/mainにマージし、タグを付ける。次にdevelopにマージする
 - release branches
   - プロダクトリリースの準備用。機能の追加やマイナーなバグフィクスとは独立させることで、リリース時に含めるコードを綺麗な状態に保(機能追加中で未使用のコードなどを含まないようにする)ことができる。developブランチにリリース予定の機能やバグフィクスをほぼ反映した状態でdevelopから分岐する。リリース準備が整い次第、master/mainにマージし、タグを付ける。次にdevelopにマージする

<br>

- `git flow`の初期化
1. 作業ディレクトリに移動し、`$ git flow init`を実行
  1. ブランチの名前などを聞かれるが、全て`Enter`でOK!
2. `git branch`で確認 
  1. master/main と develop ブランチが作成されていればOK
3. developブランチを切る場合
  1. `$ git push origin develop`

<br>

- 機能の作成を行うためにFeature branchを切る
 - この手順は、開発チームの誰か1人が行えばOK
 - 新しい機能を付ける前に、Feature branchを切る
 - 例として`top`という名前のブランチ名を切る
1. `$ git flow feature start top`を実行
2. `$ git branch`で確認
  1. `feature/top`が作成されていればOK
3. 下記のコマンドを実行し、ローカルに反映させる
  1. `$ git flow feature publish top`

<br>

- リモートリポジトリの最新データをプル
 - `$ git flow feature pull origin top`

<br>

- Githubへのpush
 - `$ git push origin feature/top`

<br>

- Rejectされてpushできない場合
 - rebaseを行う
 - rebaseとは、自身の変更を基準にして、branchにマージすること
 - `$ git pull --rebase origin feature/top`