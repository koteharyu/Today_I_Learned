# railsコマンドを実行するとエラーになる

[techessentialsでの質問はこちら](https://tech-essentials.work/questions/340)

### 環境

```
M1 mac
OS: Big Sur 11.3
Ruby: 2.6.6
MySQL: 5.7
```

## いつもと調子がおかしい

OSのアップデートを行ったり再起動を行ったりはしておらず、特に変わったことなかった。いつものように`rails s`をすると突然、Rubyのバージョンが違うと怒られた。`rbenv`を見てみるとインストールしていたはずの2.6.6が消えており、systemしか入っていなかった。また、homebrew周りのパスも`.zshrc`からも消えていたので、改めてパスなどを指定することに。以下がその時の`.zshrc`の一部

```
# .zshrcの一部

export PATH=/opt/homebrew/bin:$PATH
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
```

## rbenv install 2.6.6ができない！？

`rbenv install 2.6.6`を実行すると、BUILD FAILED (macOS 11.3 using ruby-build 20210309)が発生。[この記事](https://secret-garden.hatenablog.com/entry/2021/01/02/220713)を参考に`RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC rbenv install 2.6.6`コマンドで一応インストールすることには成功したが、絶対に何かおかしい。いずれ解決したい。以下が`rbenv install 2.6.6`を実行した際に発生したエラーログ。

```
Downloading ruby-2.6.6.tar.bz2...
-> https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.6.tar.bz2
Installing ruby-2.6.6...
ruby-build: using readline from homebrew

BUILD FAILED (macOS 11.3 using ruby-build 20210510)

Inspect or clean up the working tree at /var/folders/ct/vht_kbc11h37b7smlsvhp6tc0000gn/T/ruby-build.20210516193339.81947.66zZ62
Results logged to /var/folders/ct/vht_kbc11h37b7smlsvhp6tc0000gn/T/ruby-build.20210516193339.81947.log

Last 10 log lines:
        rb_native_mutex_destroy(&vm->waitpid_lock);
        ^
vm.c:2489:34: warning: expression does not compute the number of elements in this array; element type is 'const int', not 'VALUE' (aka 'unsigned long') [-Wsizeof-array-div]
                             sizeof(ec->machine.regs) / sizeof(VALUE));
                                    ~~~~~~~~~~~~~~~~  ^
vm.c:2489:34: note: place parentheses around the 'sizeof(VALUE)' expression to silence this warning
3 warnings and 1 error generated.
make: *** [vm.o] Error 1
make: *** Waiting for unfinished jobs....
1 warning generated.
```

## .rbenvの中身

.rbenvの中身は異常なさそう

```
$ ls .rbenv

shims    version  versions
```

## 解決に向けて

###　.zshrc

まず試したことは、`.zshrc`の中身を以下の様に編集した。

```
export PATH=/opt/homebrew/bin:$PATH
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/shims:$PATH"
```

### .rbenvの権限変更

`sudo chown -R haryu /Users/haryu/.rbenv`コマンドで権限を付与

### MySQL5.7をアクティブにする

`brew link --force mysql@5.7`コマンドでアクティブにする

### openssl周り

`openssl`とは、インターネット上で標準的に利用される暗号通信プロトコルであるSSL及びTLSの機能を実装したオープンソースのライブラリのこと。

一応、homebrewでのopensslのインストールは済んでいたが、`/usr/bin/`内のopensslを参照したいた模様。従って`export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"`コマンドで.zshrcに追記することで、`/opt/homebrew/opt/`内の`openssl@1.1/bin/openssl`参照するように変更

次に、oppenssl関連のパスを.zshrcに追記する。以下が最終的な.zshrcの中身(一部抜粋)

```
export PATH=/opt/homebrew/bin:$PATH
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/shims:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"
# ↓ oppenssl関連で追加したパス
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
```

### エラーログの変化

`gem install mysql2`コマンドを実行すると、以下のようなエラーログが

```
Building native extensions. This could take a while...
ERROR:  Error installing mysql2:
        ERROR: Failed to build gem native extension.

    current directory: /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/gems/2.6.0/gems/mysql2-0.5.3/ext/mysql2
/Users/haryu/.rbenv/versions/2.6.6/bin/ruby -I /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/site_ruby/2.6.0 -r ./siteconf20210518-74658-18dbvbr.rb extconf.rb
checking for rb_absint_size()... yes
checking for rb_absint_singlebit_p()... yes
checking for rb_wait_for_single_fd()... yes
-----
Using mysql_config at /opt/homebrew/bin/mysql_config
-----
checking for mysql.h... yes
checking for errmsg.h... yes
checking for SSL_MODE_DISABLED in mysql.h... yes
checking for SSL_MODE_PREFERRED in mysql.h... yes
checking for SSL_MODE_REQUIRED in mysql.h... yes
checking for SSL_MODE_VERIFY_CA in mysql.h... yes
checking for SSL_MODE_VERIFY_IDENTITY in mysql.h... yes
checking for MYSQL.net.vio in mysql.h... yes
checking for MYSQL.net.pvio in mysql.h... no
checking for MYSQL_ENABLE_CLEARTEXT_PLUGIN in mysql.h... yes
checking for SERVER_QUERY_NO_GOOD_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_NO_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_WAS_SLOW in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_ON in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_OFF in mysql.h... yes
checking for my_bool in mysql.h... yes
-----
Don't know how to set rpath on your system, if MySQL libraries are not in path mysql2 may not load
-----
-----
Setting libpath to /opt/homebrew/Cellar/mysql@5.7/5.7.34/lib
-----
creating Makefile

current directory: /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/gems/2.6.0/gems/mysql2-0.5.3/ext/mysql2
make DESTDIR\= clean

current directory: /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/gems/2.6.0/gems/mysql2-0.5.3/ext/mysql2
make DESTDIR\=
compiling client.c
compiling infile.c
compiling mysql2_ext.c
compiling result.c
compiling statement.c
linking shared-object mysql2/mysql2.bundle
ld: library not found for -lssl
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [mysql2.bundle] Error 1

make failed, exit code 2

Gem files will remain installed in /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/gems/2.6.0/gems/mysql2-0.5.3 for inspection.
Results logged to /Users/haryu/.rbenv/versions/2.6.6/lib/ruby/gems/2.6.0/extensions/-darwin-20/2.6.0/mysql2-0.5.3/gem_make.out
```

mysql周りでエラーが起きているよう。

### vendor/bundleフォルダを削除

bundleディレクトリを削除し、再度`bundle install`を実行すると正常にインストールされた様だが、以前`gen install mysql2`ではエラーが発生

ちなみに、最初に`bundle install --path vendor/bundler`とパスのオプションを渡していると、`bundle/config`内に指定したパスが記載されるため、次回以降は`bundle`or`bundle install`だけで良くなる

## 決め手！

未だmysql関連でエラーが出ている

そこで、`bundle/config`内に、`BUNDLE_BUILD__MYSQL2: "--with-opt-dir=/opt/homebrew/opt/openssl@1.1"`を指定することに。

すると`rails s`できるようになった！

[ブログ](https://paulownia.hatenablog.com/entry/2018/04/14/143739)に似たようなパスが書いてあるが、自分の環境に合わせる必要があるため、そのままコピペは注意するように！

### 感想

おそらくopenssleの参照先と、`BUNDLE_BUILD__MYSQL2: "--with-opt-dir=/opt/homebrew/opt/openssl@1.1"`が決め手だろうと思うが、正直何がどうなっているかよくわかっていない。自分も経験を積んで仮説と検証ができる様になりたいと心から思った。

## Vim

`vim <ファイル>`...<ファイル>をvimで開く

`shift + G`...一番下の行にカーソル移動

`o(オー)`...空の行が追加され、カーソルが合わさる

`vimtutor`...vimのチュートリアルが見れる
