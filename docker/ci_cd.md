# CI/CD

機能追加するたびに、`heroku container:push`, `heroku container:release`をするのは大変なので自動化を行っていく

CI...継続的インテグレーション。ビルド・テストを自動実行

CD...継続的デリバリー。githubにてマージされたら自動デプロイを行う

## github

いつも通り、branchを切ってプルリクを作成する

## CI

1. テストコードを記載
2. CircleCIに登録
3. プロジェクトを登録
4. configを設定
5. 環境変数を設定
6. Githubにプッシュ
7. テストを修正

### configを設定

`.circleci/config.yml`ファイルを作成する

```yml
#.circleci/config.yml

version: 2.1
orbs:
  ruby: circleci/ruby@1.1.2
  heroku: circleci/heroku@1.2.3

jobs:
  build:
    docker:
      - image: circleci/ruby:2.7
    working_directory: ~/rails-docker-hryau6/src
    steps:
      - checkout:
          path: ~/rails-docker-hryau6
      - ruby/install-deps

  test:
    docker:
      - image: circleci/ruby:2.7
      - image: circleci/mysql:5.5
        environment:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: app_test
          MYSQL_USER: root
    environment:
      BUNDLE_JOBS: "3"
      BUNDLE_RETRY: "3"
      APP_DATABASE_HOST: "127.0.0.1"
      RAILS_ENV: test
    working_directory: ~/rails-docker-hryau6/src
    steps:
      - checkout:
          path: ~/rails-docker-hryau6
      - ruby/install-deps
      - run:
          name: Database setup
          command: bundle exec rails db:migrate
      - run:
          name: test
          command: bundle exec rake test

  deploy:
    docker:
      - image: circleci/ruby:2.7
    steps:
      - checkout
      - setup_remote_docker:
          version: 19.03.13
      - heroku/install
      - run:
          name: heroku login
          command: heroku container:login
      - run:
          name: push docker image
          command: heroku container:push web -a $HEROKU_APP_NAME
      - run:
          name: release docker image
          command: heroku container:release web -a $HEROKU_APP_NAME
      - run:
          name: database setup
          command: heroku run bundle exec rake db:migrate RAILS_ENV=production -a $HEROKU_APP_NAME

workflows:
  version: 2
  build_test_and_deploy:
    jobs:
      - build
      - test:
          requires:
            - build
      - deploy:
          requires:
            - test
          filters:
            branches:
              only: main
```

orbs...jobsのシェア機能

次に、database.ymlのテスト欄のホストを修正する

```yml
test:
  <: *default
  database: app_test
  host: <%= ENV.fetch("APP_DATABASE_HOST") {'db'}%>
```

もし環境変数に`APP_DATABASE_HOST`の値がセットされていたらその値を使って、セットされていなければ、`db`という値を使用するという記述

つまり、ローカルでの作業時には`db`を使用、cicleCI時には環境変数を使用してねということ

### 環境変数を設定

masterkeyを環境変数に設定する。なぜならこのファイルはgit管理していないから

`heroku config:add RAILS_MASTER_KEY='<貼り付け>' -a rails-docker-hryau6`

## CD

マージされたら自動的にデプロイされるようにする機能

1. configを修正
2. 環境変数の設定
3. Viewファイルを修正
4. Githubにプッシュ
5. マージ・デプロイ

### 環境変数の設定

cicleCIのプロジェクト内で環境変数`$HEROKU_APP_NAME`を設定する

あと、`HEROKU_API_KEY`という名前でherokuAPIキーも必要になる
