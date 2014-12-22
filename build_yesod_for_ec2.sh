# 
# EC2上のAmazon Linuxで2014/12/21にYesod環境構築に成功したときの手順
# 参考URL
# http://qiita.com/a-suenami/items/ef4266a1b38dd5bd426e
# 
# CentOS上でも構築に成功したが、そのコマンドは別の機会に.
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

