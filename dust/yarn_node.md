# yarn nodeに関するエラーについて

[これの続き...](https://github.com/koteharyu/TIL/blob/main/dust/mimemagic.md)

bundle installに成功し、`rails s`をした際に以下のようなエラーが発生

```
$ rails s

=> Booting Puma
=> Rails 6.0.4 application starting in development
=> Run `rails server --help` for more startup options
error Couldn't find an integrity file
error Found 1 errors.
========================================
  Your Yarn packages are out of date!
  Please run `yarn install --check-files` to update.
========================================


To disable this check, please change `check_yarn_integrity`
to `false` in your webpacker config file (config/webpacker.yml).


yarn check v1.22.10
info Visit https://yarnpkg.com/en/docs/cli/check for documentation about this command.

Exiting
```

お望み通り、`yarn install --check-files`を実行すると...

```
$ yarn install --check-files

yarn install v1.22.10
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
warning " > webpack-dev-server@3.11.0" has unmet peer dependency "webpack@^4.0.0 || ^5.0.0".
warning "webpack-dev-server > webpack-dev-middleware@3.7.2" has unmet peer dependency "webpack@^4.0.0".
[4/4] 🔨  Building fresh packages...
[1/3] ⠄ fsevents
[-/3] ⠄ waiting...
error /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass: Command failed.
Exit code: 1
Command: node scripts/build.js
Arguments:
Directory: /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass
Output:
Building: /opt/homebrew/Cellar/node/16.0.0_1/bin/node /Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/bin/node-gyp.js rebuild --verbose --libsass_ext= --libsass_cflags= --libsass_ldflags= --libsass_library=
gyp info it worked if it ends with ok
gyp verb cli [
gyp verb cli   '/opt/homebrew/Cellar/node/16.0.0_1/bin/node',
gyp verb cli   '/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/bin/node-gyp.js',
gyp verb cli   'rebuild',
gyp verb cli   '--verbose',
gyp verb cli   '--libsass_ext=',
gyp verb cli   '--libsass_cflags=',
gyp verb cli   '--libsass_ldflags=',
gyp verb cli   '--libsass_library='
gyp verb cli ]
gyp info using node-gyp@3.8.0
gyp info using node@16.0.0 | darwin | arm64
gyp verb command rebuild []
gyp verb command clean []
gyp verb clean removing "build" directory
gyp verb command configure []
gyp verb check python checking for Python executable "/usr/bin/python" in the PATH
gyp verb `which` succeeded /usr/bin/python /usr/bin/python
gyp verb check python version `/usr/bin/python -c "import sys; print "2.7.16
gyp verb check python version .%s.%s" % sys.version_info[:3];"` returned: %j
gyp verb get node dir no --target version specified, falling back to host node version: 16.0.0
gyp verb command install [ '16.0.0' ]
gyp verb install input version string "16.0.0"
gyp verb install installing version: 16.0.0
gyp verb install --ensure was passed, so won't reinstall if already installed
gyp verb install version is already installed, need to check "installVersion"
gyp verb got "installVersion" 9
gyp verb needs "installVersion" 9
gyp verb install version is good
gyp verb get node dir target node version installed: 16.0.0
gyp verb build dir attempting to create "build" dir: /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/build
gyp verb build dir "build" dir needed to be created? /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/build
gyp verb build/config.gypi creating config file
gyp verb build/config.gypi writing out config file: /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/build/config.gypi
(node:90219) [DEP0150] DeprecationWarning: Setting process.config is deprecated. In the future the property will be read-only.
(Use `node --trace-deprecation ...` to show where the warning was created)
gyp verb config.gypi checking for gypi file: /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/config.gypi
gyp verb common.gypi checking for gypi file: /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/common.gypi
gyp verb gyp gyp format was not specified; forcing "make"
gyp info spawn /usr/bin/python
gyp info spawn args [
gyp info spawn args   '/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/gyp/gyp_main.py',
gyp info spawn args   'binding.gyp',
gyp info spawn args   '-f',
gyp info spawn args   'make',
gyp info spawn args   '-I',
gyp info spawn args   '/Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass/build/config.gypi',
gyp info spawn args   '-I',
gyp info spawn args   '/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/addon.gypi',
gyp info spawn args   '-I',
gyp info spawn args   '/Users/haryu/.node-gyp/16.0.0/include/node/common.gypi',
gyp info spawn args   '-Dlibrary=shared_library',
gyp info spawn args   '-Dvisibility=default',
gyp info spawn args   '-Dnode_root_dir=/Users/haryu/.node-gyp/16.0.0',
gyp info spawn args   '-Dnode_gyp_dir=/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp',
gyp info spawn args   '-Dnode_lib_file=/Users/haryu/.node-gyp/16.0.0/<(target_arch)/node.lib',
gyp info spawn args   '-Dmodule_root_dir=/Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass',
gyp info spawn args   '-Dnode_engine=v8',
gyp info spawn args   '--depth=.',
gyp info spawn args   '--no-parallel',
gyp info spawn args   '--generator-output',
gyp info spawn args   'build',
gyp info spawn args   '-Goutput_dir=.'
gyp info spawn args ]
No receipt for 'com.apple.pkg.CLTools_Executables' found at '/'.

No receipt for 'com.apple.pkg.DeveloperToolsCLILeo' found at '/'.

No receipt for 'com.apple.pkg.DeveloperToolsCLI' found at '/'.

gyp: No Xcode or CLT version detected!
gyp ERR! configure error
gyp ERR! stack Error: `gyp` failed with exit code: 1
gyp ERR! stack     at ChildProcess.onCpExit (/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/lib/configure.js:345:16)
gyp ERR! stack     at ChildProcess.emit (node:events:365:28)
gyp ERR! stack     at Process.ChildProcess._handle.onexit (node:internal/child_process:290:12)
gyp ERR! System Darwin 20.4.0
gyp ERR! command "/opt/homebrew/Cellar/node/16.0.0_1/bin/node" "/Users/haryu/Documents/rails_api_curriculum/node_modules/node-gyp/bin/node-gyp.js" "rebuild" "--verbose" "--libsass_ext=" "--libsass_cflags=" "--libsass_ldflags=" "--libsass_library="
gyp ERR! cwd /Users/haryu/Documents/rails_api_curriculum/node_modules/node-sass
gyp ERR! node -v v16.0.0
gyp ERR! node-gyp -v v3.8.0
gyp ERR! not ok
```

<br>

## nodeのバージョン

もしかしたらnodeのバージョンが新しすぎることが問題ではないかということで`v12系統`をインストールしてみることに

まずは、[こちらの記事](https://qiita.com/kyosuke5_20/items/c5f68fc9d89b84c0df09)を参考にnodebrewのインストール

```
$ nodebrew -v
nodebrew 1.1.0

Usage:
    nodebrew help                         Show this message
    nodebrew install <version>            Download and install <version> (from binary)
    nodebrew compile <version>            Download and install <version> (from source)
    nodebrew install-binary <version>     Alias of `install` (For backward compatibility)
    nodebrew uninstall <version>          Uninstall <version>
    nodebrew use <version>                Use <version>
    nodebrew list                         List installed versions
    nodebrew ls                           Alias for `list`
    nodebrew ls-remote                    List remote versions
    nodebrew ls-all                       List remote and installed versions
    nodebrew alias <key> <value>          Set alias
    nodebrew unalias <key>                Remove alias
    nodebrew clean <version> | all        Remove source file
    nodebrew selfupdate                   Update nodebrew
    nodebrew migrate-package <version>    Install global NPM packages contained in <version> to current version
    nodebrew exec <version> -- <command>  Execute <command> using specified <version>

Example:
    # install
    nodebrew install v8.9.4

    # use a specific version number
    nodebrew use v8.9.4
```

ちゃんとインストールできたみたい

では続いて、12系統のどれかをインストールしようと思った矢先、問題が...

どのバージョンを指定しても以下のようにnot foundとなりインストールできない

```
$ nodebrew install 12.14.0
v12.14.0 is not found

Can not fetch: https://nodejs.org/dist/v12.14.0/node-v12.14.0-darwin-arm64.tar.gz
```

<br>

`nodebrew install stable`...安定版である`stable`を指定すると、問題なく`v16.4.0`がインストールできた

なぜ、バージョン指定ができないのか...???

## 妥協案

結局具体的な解決ができなかったため、dockerでの環境構築をすることにシフトチェンジ
