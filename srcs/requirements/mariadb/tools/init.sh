#!/bin/bash

# MariaDBの初期化が終わっていない場合(初回実行)のみ実行する
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDBを初期化中..."

    # 1. シークレットからパスワードを読み込んで一時変数に格納
    DB_ROOT_PASS=$(cat /run/secrets/db_root_password.txt)
    DB_PASS=$(cat /run/secrets/db_password.txt)

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # バックグラウンドで一時的にMariaDBを起動
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5 # 起動するまで少し待つ

    # .envから読み込んだ値を使って、初期設定のSQLコマンドを実行
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'\%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

    # 設定が終わったら一時起動していたMariaDBをシャットダウン
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo "MariaDBをフォアグラウンドで起動します..."
# execを使うことで、この監視者スクリプト自身のプロセスをMariaDB本体に置き換えるから、PIDは変わらない
exec mysqld_safe --datadir=/var/lib/mysql
