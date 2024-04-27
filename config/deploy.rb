# capistranoのバージョン固定
lock "3.18.1"

# デプロイするアプリケーション名
set :application, 'kakeibo'

# cloneするgitのレポジトリ
# 1-3で設定したリモートリポジトリのurl
set :repo_url, 'git@github.com:jun0222/rails_scaffold_kakeibo.git'

# deployするブランチ。デフォルトはmainなのでなくても可。
set :branch, 'main'

# deploy先のディレクトリ。
set :deploy_to, '/var/www/kakeibo'

# シンボリックリンクをはるファイル
set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')

# シンボリックリンクをはるフォルダ
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# 保持するバージョンの個数(※後述)
set :keep_releases, 5

# rubyのバージョン
# rbenvで設定したサーバー側のrubyのバージョン
set :rbenv_ruby, '2.5.1'

# 出力するログのレベル。
set :log_level, :debug

# 環境変数の設定
set :default_env, {
  'NODE_OPTIONS' => '--openssl-legacy-provider',
  'KAKEIBO_DATABASE_PASSWORD' => ENV["KAKEIBO_DATABASE_PASSWORD"]
}

# デプロイのタスク
namespace :deploy do

  # unicornの再起動
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  # データベースの作成
  desc 'Create database'
  task :db_create do
    on roles(:db) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
                # データベース作成のsqlセット
                # データベース名はdatabase.ymlに設定した名前で
                  sql = "CREATE DATABASE IF NOT EXISTS kakeibo_production;"
                  # クエリの実行。
                # userとpasswordはmysqlの設定に合わせて
                execute "mysql --user=root --password=root -e '#{sql}'"

        end
      end
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end