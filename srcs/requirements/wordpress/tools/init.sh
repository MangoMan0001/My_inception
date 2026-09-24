#!/bin/bash
# /tools/init.sh

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPressの初期セットアップを開始します..."

    # credentials.txt からパスワードを抽出して変数に入れる
    # （grepで該当行を探し、cutで「=」の右側だけを切り取る）
    ADMIN_PASS=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials.txt | cut -d '=' -f 2)
    USER_PASS=$(grep WP_USER_PASSWORD /run/secrets/credentials.txt | cut -d '=' -f 2)

    wp core download --allow-root

    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$(cat /run/secrets/db_password.txt) \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url=$DOMAIN_NAME \
        --title=$SITE_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    wp user create \
        $WP_USER_LOGIN \
        $WP_USER_EMAIL \
        --role=author \
        --user_pass=$USER_PASS \
        --allow-root

    echo "ファイルの所有権を www-data に変更します..."
    chown -R www-data:www-data /var/www/html

    echo "WordPressのセットアップが完了しました！"
fi
