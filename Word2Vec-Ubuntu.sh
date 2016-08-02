#!/bin/bash
#プレーンなUbuntu14.04インスタンスでWikipediaデータからWord2Vecを計算するスクリプト
#下記を参考
#http://blog.umentu.work/ubuntu-word2vec%E3%81%A7%E6%97%A5%E6%9C%AC%E8%AA%9E%E7%89%88wikipedia%E3%82%92%E8%87%AA%E7%84%B6%E8%A8%80%E8%AA%9E%E5%87%A6%E7%90%86%E3%81%97%E3%81%A6%E3%81%BF%E3%81%9F/

#関連パッケージをインストール
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install -y git autoconf bison build-essential unzip libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev mecab mecab-ipadic mecab-ipadic-utf8 libmecab-dev ruby2.2 ruby2.2-dev

#wp2txt
sudo gem2.2 install wp2txt bundler

#Mecab NEologd
mkdir -p ~/trunk
cd ~/trunk
git clone https://github.com/neologd/mecab-ipadic-neologd.git
cd mecab-ipadic-neologd
./bin/install-mecab-ipadic-neologd -n -y

#Word2Vec
cd ~/trunk
wget https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/word2vec/source-archive.zip
unzip source-archive.zip
cd word2vec/trunk
make

#データダウンロード
cd ~/trunk
mkdir -p wikipedia
cd wikipedia
curl https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-pages-articles.xml.bz2 -o jawiki-latest-pages-articles.xml.bz2

#Wikipediaデータをテキスト変換
wp2txt --input-file jawiki-latest-pages-articles.xml.bz2

#品詞分解
cat jawiki-latest-pages-articles.xml*.txt | mecab -Owakati -d /usr/lib/mecab/dic/mecab-ipadic-neologd/ -b 81920 > wakati.txt


#word2vec計算
../word2vec/trunk/word2vec -train wakati.txt -size 200 -window 8 -sample 1e-4 -negative 25 -hs 0 -iter 15 -thread 35 -binary 1 -output output.bin
