# 1. ベースOS
FROM debian:bookworm

# 2. PHP-FPMや通信ツールの調達
RUN apt-get update -y && \
    apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    mariadb-client

# 3. PHP-FPMの作業台、ソケット置き場を作成
RUN mkdir -p /run/php && \
    chmod 755 /run/php

# 4. WP-CLIのダウンロードと配置
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# 5. PHP-FPMの設定ファイルを配置
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 6. コンテナ起動時のスクリプトを配置
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 7. 作業ディレクトリ（WordPressのファイルを置く広場）の指定
WORKDIR /var/www/html

# 8. 起動スイッチ
ENTRYPOINT ["/usr/local/bin/init.sh"]
