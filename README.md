# Rails の全部盛りリポジトリ

TODO: リポジトリ名変更

- 個人用ツール
- ライブラリの動作確認
- 実装試しうち
- 設計(必要ならブランチごとにかえる、その場合別ブランチは継続運用するというより単一の変更を試すために使う。色々合わせた確認がしたいならそれ用に作る)
- 試したソースコードなどにコメントや、ドキュメントを細かくつけて再利用可能にする

# 家計簿機能画面

![picture 1](images/6d6cbe471ffd83526df01926d5e36572ccc6eec6b8a5b5dedc230c0c61386354.png)

# 家計簿機能参考記事

- [Rails scaffold を初心者向けに解説！実際にアプリを作ってみよう！](https://udemy.benesse.co.jp/development/system/scaffold.html)
- [Ruby on Rails 4 と Bootstrap で管理画面のレイアウトを作成する](https://www.imd-net.com/column/2760/)

# エラー

## NoMethodError: undefined method `match' for nil:NilClass

### 内容

```sh
$ bundle exec cap production deploy
(Backtrace restricted to imported tasks)
cap aborted!
NoMethodError: undefined method `match' for nil:NilClass
```

### 対応

IP アドレスの環境変数`SERVER_IP`未指定が原因だったので、

```sh
bundle exec cap production deploy SERVER_IP=IPアドレス
```

で一旦動作することを確認。環境変数に入れるようにする。

## WARN rbenv: 2.4.1 is not installed or not found in $HOME/.rbenv/versions/2.4.1 on IP アドレス

`config/deploy.rb`で`set :rbenv_ruby, '2.5.1'`として解決。

## cap aborted! SSHKit::Runner::ExecuteError: Exception while executing as

```bash
ssh-add ~/.ssh/id_rsa
```

で解決。

## bundle exec cap production deploy:db_create ができない

直接サーバーで SQL を実行。

## bundler のバージョンがあっていても can't find gem bundler

```bash
bundler:config
$HOME/.rbenv/bin/rbenv exec bundle config --local deployment true
/home/username/.rbenv/versions/2.5.1/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe'
:
can't find gem bundler (>= 0.a) with executable bundle
 (
Gem::GemNotFoundException
```

必要なデプロイの設定の修正を git push できていなかっただけ。push して解決。  
（やはり上手くいかないなら、手順書レベルの基本を見直すべき）

# デプロイ参考記事

- [(初心者向け）vps を契約して、capistrano3 で Rails アプリをデプロイするまで [その 1 サーバー設定編]](https://qiita.com/ryo2132/items/f62690f0b16ec11270fe)
- [(初心者向け）vps を契約して、Capistrano3 で Rails アプリをデプロイするまで [その 2 ローカル設定編]](https://qiita.com/ryo2132/items/03f5f52b43742f5aef10)

# bundler のバージョン切り替え（2.3.26 にしたい場合）

```bash
gem install bundler -v 2.3.26
bundle _2.3.26_ --version
```

# デプロイコマンド

```
bundle exec cap production deploy
```

# webpacker のエラー ERR_OSSL_EVP_UNSUPPORTED でデプロイできない

https://www.nslabs.jp/rails-switch-from-webpacker-to-jsbundling-rails.rhtml

# git@github.com: Permission denied (publickey). でデプロイできない

[参考](https://stackoverflow.com/questions/7968656/why-is-a-cap-deploy-giving-permission-denied-publickey)

```bash
ssh-add -k
```

# デプロイエラー Compilation failed: Browserslist: caniuse-lite is outdated. Please run: npx update-browserslist-db@latest

node が新しいことによって起きている。
deploy.rb に以下を追加することで解決。

```ruby
# 環境変数の設定
set :default_env, {
  'NODE_OPTIONS' => '--openssl-legacy-provider'
}
```

# 状況

mysql 繋がらない。パスワード利用で db ダメ。
ssh した方が良さそう。

# cli から rubocop 実行

```bash
bundle exec rubocop -a パス
```

# デプロイエラー git@github.com: Permission denied (publickey).

github 用の key を ssh-add する必要があるのに、vps の key を ssh-add していた。以下で解決。

```bash
ssh-add github用のkey
```

# デプロイエラー Mysql2::Error::ConnectionError: Access denied for user 'username'@'localhost' (using password: NO)

password: NO となっているので、credentials.yml.enc に記載されているパスワードが利用されていない。以下で解決。

```bash
# railsキャッシュクリア
rails tmp:cache:clear

# vpsに入ってmysqlパスワードが利用できるか確認
mysql -u ユーザー名 -p

# credentials.yml.enc の内容編集。master.key で暗号化されるファイル。
EDITOR="vi" bin/rails credentials:edit

# rails console で credentials内の環境変数確認
rails console
puts Rails.application.credentials.dig(:production, :database_password)

# サーバーにデプロイする必要のあるファイルを scp でアップロード → deploy.rb のset :linked_files, fetch(:linked_files, []).push('')にも記載
scp -P 10022 config/credentials.yml.enc vpsのユーザー名@vpsのipアドレス:/var/www/kakeibo/shared/config/
scp -P 10022 config/settings.yml vpsのユーザー名@vpsのipアドレス:/var/www/kakeibo/shared/config/
scp -P 10022 config/database.yml vpsのユーザー名@vpsのipアドレス:/var/www/kakeibo/shared/config/
```

- 参考記事

  - [MySQL の using password: No エラー](https://qiita.com/kimino0525/items/e06840fc998d646f98e1)
  - [credentials.yml.enc の基礎について](https://qiita.com/gyu_outputs/items/92c4a2a2f96edb10e298)
  - [yml などシンボリックリンクしているファイルをデプロイ必要では？と仮説の元](https://github.com/capistrano/capistrano/issues/1532#issuecomment-160897337)

# Mysql2::Error::ConnectionError: Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.socksource ~/.bashrc' (2)

- ローカルで `socket: /var/lib/mysql/mysql.sock `にしてもダメだったから、サーバー側で書き換え
- db ユーザー名やパスワード、ローカルの prj ではなくて、サーバー側の設定を使っていそう。

  - デプロイはホストマシンとサーバー側でやることだから、ホストマシン上の設定、プロジェクトのソースコード（もホストマシンにあるが）とサーバーの設定、間の設定（github など使っているもの）を見ないといけない。
  - web app のフロントエンドとバックエンドを見る時にそれぞれと間の通信をチェックするのと同じ。
  - これで credencials.yml.enc の内容をサーバー側で利用できた。
  - `copilot`からこのあたりのヒントを得られた
  - あと調べることより、仮説を自分なりにアウトプットしながらやる。基本的にはエラーメッセージ以上の情報はない。仮説がなければ調べるほど薄まる

# Mysql2::Error::ConnectionError: Access denied for user 'username'@'localhost' to database 'kakeibo_production'

- `deploy.rb` は root ユーザーで root というパスワードを使って、sql を実行しようとしていたので db 作成できていなかった。
- サーバーに入って、直接 root ユーザーログインし、deploy.rb のユーザー名とパスワードを使って、db 作成したら解決。
  - 基本的にサーバー側の設定が必要では？という考えがあれば基本うまくいく
- あと、当該のコマンドは`bundle exec cap production deploy:db_create`に設定されていたが、そちらの実行もせず、`bundle exec cap production deploy`しかしていなかった。

# mv /var/www/kakeibo/releases/current /var/www/kakeibo mv:cannot overwrite directory '/var/www/kakeibo/current' with non-directory

> /var/www/kakeibo/current を非ディレクトリで上書きしようとしたときに発生します。Capistrano はデプロイ時に current シンボリックリンクを最新のリリースディレクトリに更新しますが、current が既に非ディレクトリとして存在するとこのエラーが発生します。

```bash
# これで解決
rm -rf /var/www/kakeibo/current
```

# nginx の再起動

```bash
sudo service nginx restart
```

# サーバー側のログ

```bash
# アプリケーションログ
tail -f /var/www/kakeibo/current/log/production.log

# unicorn ログ
tail -f /var/www/kakeibo/shared/log/unicorn.log
```

# デプロイした後キャッシュを消す？

不要かもしれない

```bash
bundle exec cap production deploy:restart
```

# cap でデプロイするときは、コミットして push が必要。

- healthcheck の routes が反映されず困った。

# デプロイしてキャッシュ消す

```
bundle exec cap production deploy && bundle exec cap production deploy:restart
```

# デプロイ先で 500 エラー出た時の調査

- [この記事](https://obel.hatenablog.jp/entry/20170614/1497406949)を参考にローカルでプロダクションビルド起動

```bash
# ローカルでプロダクションビルド起動
bin/rails s -e production
```

`log/production.log` を見ると、アプリケーションのエラーがわかる。
デプロイ時のデバッグではサーバー上で debug モード起動すること、  
ローカルでプロダクションビルドするのは基本。  
詳細見ないとデバッグ不可。デバッグは具体が重要。

※DB 接続先は prod のものそのまま使うとエラーになるので、一時的に`database.yml`の環境名を書き換えてローカルの設定で prod として動かす。

# assets:precompile でエラー

※ ローカルでプロダクションビルドして調査。

- css のエラー
  environment/deploy.rb で precompile を `false` から `true` にして解決。
- favicon.ico がないエラー

  - `rails assets:precompile`してもう一度 prod 起動。解決。

と思ったが、色々エラーが再発したりした。  
node や ruby のバージョンをエラーメッセージに従い変えるも、  
うまくいかず結局根本原因が、サーバー側で unicorn が起動していなかったことと気づく。  
以下あたりのコマンドを叩いた。rbenv で 2.7.1 にしようとしても、2.5.1 指定だから〜とエラーになって設定場所不明など。

```bash
volta list
volta install node@14
volta pin node@14
node -v
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rails webpacker:compile
bin/rails s -e production
bin/rails webpacker:install
```

`production.rb`の以下の書き換えも実施

```ruby
config.public_file_server.enabled = true
config.assets.compile = false
```

Puma の再起動、Nginx の再起動、過去の経験、サーバー側の log ディレクトリの内容を見て、  
サーバー側の rbenv の作業をやっていたこともあり、  
サーバー側で unicorn.log を見てみる。エラーが出ていた。  
`/var/www/kakeibo/releases/存在しない過去verのtimestamp/Gemfile not found (Bundler::GemfileNotFound)`

上記のエラー自体はよくあるもので、検索すればたくさん情報が出たが、  
一旦デプロイ後に unicorn のプロセスをサーバー側で kill して、  
ローカルで deploy.rb でコメントして記載した、 unicorn:start セクションの
コメントを外して実行することで解決。

おそらくデプロイを繰り返しているうちに、過去 ver をみるエラーになってしまった。

```bash
# unicorn止める時はサーバー側でプロセス見て masterを kill -9
ps -ef | grep unicorn | grep -v grep

# unicorn起動はローカルから操作、deploy.rb で設定する。デプロイするたびにこれやらないとダメ。deploy.rbの工夫でマシになりそう。
cap production unicorn:start
```

# 本番環境でだけ Settings.yml が本番でだけ読み込まれない

ファイル名を本来の settings.yml（先頭小文字にしたらいけた）

# デプロイ時注意

- まずは healthcheck から。それが通らないと次に進めない。
- できたらブランクのプロジェクトデプロイからが変数少なく確実。
- 500 エラーなどはアプリケーションよりも、低レイヤーの確認も必要。unicorn や nginx のログを見るのがそう。
- まずはログを出す、それがないと何が起きているかわからない。

# デプロイプロセス

```bash
# デプロイコマンド実行 もしかしたらこれだけでいけるかも？
bundle exec cap production deploy

# サーバー側でunicornのプロセスをkill
ps -ef | grep unicorn | grep -v grep

# ローカルでunicorn起動
# コメントアウトを外してから実行する
bundle exec cap production unicorn:start
```

