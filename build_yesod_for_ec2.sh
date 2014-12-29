# 
# EC2上のAmazon Linuxで2014/12/21にYesod環境構築に成功したときの手順
# 参考URL
# http://qiita.com/a-suenami/items/ef4266a1b38dd5bd426e
# 
sudo yum -y update
sudo yum -y install wget
sudo yum -y install gcc gmp gmp-devel freeglut freeglut-devel zlib-devel
cd /usr/local/src/
sudo wget http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2
sudo tar jxvf ghc-7.6.3-x86_64-unknown-linux.tar.bz2
cd ghc-7.6.3
sudo ./configure
sudo make install
cd /usr/local/src/
sudo wget https://www.haskell.org/platform/download/2013.2.0.0/haskell-platform-2013.2.0.0.tar.gz
sudo tar xzvf haskell-platform-2013.2.0.0.tar.gz
cd haskell-platform-2013.2.0.0
sudo ./configure --with-ghc=/usr/local/bin/ghc --with-ghc-pkg=/usr/local/bin/ghc-pkg --with-hsc2hs=/usr/local/bin/hsc2hs
sudo make install
cabal update
cabal install cabal-install
cabal install yesod-platform yesod-bin
echo "export PATH=~/.cabal/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

yesod init
cd <app-dir>
cabal install -j --enable-tests --max-backjumps=-1 --reorder-goals --force-reinstalls
# cabalファイルのコンパイルオプションにTypeSynonymInstancesを追加しないとビルドに失敗する
# また、２回めのcabal installでは--force-reinstallsオプションは不要
yesod devel

#################################################
# PostgreSQLをDBに使う場合の措置
#################################################
# PostgreSQL 9.3のインストール
# CentOS環境下でのサービス名は postgresql93
sudo rpm -i http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm
sudo yum -y install postgresql93-server postgresql93-contrib
sudo service postgresql-9.3 initdb
sudo chkconfig postgresql-9.3 on
sudo service postgresql-9.3 start

sudo passwd postgres
# ここでLinuxのpostgresユーザのパスワードを設定

# ここからはpostgresユーザのpsqlコマンド上で作業
su - postgres
psql

# PostgreSQLにアプリ用ユーザを作る.
create user app createdb password 'app' login;

# ここで一旦psqlから抜け、さらにpostgresユーザからも抜ける.
# 作成したユーザでpsql接続可能にするために、PostgreSQLの設定ファイルを編集する.
\q
exit

# 全てのDB/ユーザでパスワード認証を経ての接続を可能にする
# CentOSの場合のパスは /var/lib/pgsql/9.3/data/pg_hba.conf
sudo vi /var/lib/pgsql93/data/pg_hba.conf

(ファイルの内容を下記に置換)
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer

# IPv4 local connections:
host    all             postgres        127.0.0.1/32            ident
host    all             all             0.0.0.0/0               password

# IPv6 local connections:
host    all             all             ::/0                    password

# 設定ファイルを書き換えた後はPostgreSQLを再起動する.
sudo service postgresql-9.3 restart

# このままではpersistence-postgresのコンパイルに失敗する.
# 対処する.
echo "export PATH=/usr/pgsql-9.3/bin/:\$PATH" >> ~/.bashrc
source ~/.bashrc
sudo yum -y install libpqxx-devel
createdb -U app -h localhost -E UTF8 app

