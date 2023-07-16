<!-- TOC -->

- [画面](#画面)
- [参考記事](#参考記事)
- [エラー](#エラー)
  - [NoMethodError: undefined method \`match' for nil:NilClass](#nomethoderror-undefined-method-match-for-nilnilclass)
    - [内容](#内容)
    - [対応](#対応)
  - [WARN rbenv: 2.4.1 is not installed or not found in $HOME/.rbenv/versions/2.4.1 on IP アドレス](#warn-rbenv-241-is-not-installed-or-not-found-in-homerbenvversions241-on-ip-アドレス)
  - [cap aborted! SSHKit::Runner::ExecuteError: Exception while executing as](#cap-aborted-sshkitrunnerexecuteerror-exception-while-executing-as)
  - [bundle exec cap production deploy:db_create ができない](#bundle-exec-cap-production-deploydb_create-ができない)
- [デプロイ参考記事](#デプロイ参考記事)

<!-- /TOC -->

# 画面

![picture 1](images/6d6cbe471ffd83526df01926d5e36572ccc6eec6b8a5b5dedc230c0c61386354.png)

# 参考記事

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

# デプロイ参考記事

- [(初心者向け）vps を契約して、capistrano3 で Rails アプリをデプロイするまで [その 1 サーバー設定編]](https://qiita.com/ryo2132/items/f62690f0b16ec11270fe)
- [(初心者向け）vps を契約して、Capistrano3 で Rails アプリをデプロイするまで [その 2 ローカル設定編]](https://qiita.com/ryo2132/items/03f5f52b43742f5aef10)
