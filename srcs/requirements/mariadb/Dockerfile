# 1. ベースとなるOSを指定（Debian 11 Bullseye）
FROM debian:bullseye

# 2. apt-getを最新にして、MariaDBをインストール
RUN apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client

# 3. 先ほど作った設定ファイル（conf）をコンテナの正しい位置にコピー
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. 初期化スクリプト（tools）をコンテナの中にコピー
COPY tools/init.sh /usr/local/bin/init.sh

# 5. スクリプトに実行権限（x）を付与
RUN chmod +x /usr/local/bin/init.sh

# 6. コンテナが起動した時に最初に実行されるコマンド（スクリプトを指定）
ENTRYPOINT ["/usr/local/bin/init.sh"]
