## プルリクした際にコンフリクトが起きてしまった...

- 大まかな流れ

1. ローカルのGitリポジトリと本家を直接紐づける(`upstream`)
2. `git pull upstream main`
3. コンフリを起こすはずなので適切にコンフリを修正する
4. 自分のリモートリポジトリにpush

- 流れの詳細

1. 自分のローカルのリモートを確認する
2. $ git remote add upstream https://github.com/ORIGINAL_OWNER/repogitori
3. フォークと同期
4. upstreamで指定したリモートリポジトリの最新のmain情報を取り込み
   1. コンフリクトが発生
5. ローカルブランチ内でコンフリクトを修正
6. コミットしたのち、git push origin(自分のリポジトリ) pullreq
7. プルリクの申請

<br>

- そもそもプルリクを申請し直す必要はなく、`そのプルリク内でコンフリクトを修正→再度push`が本来の手順