#!/bin/bash

# MariaDBの初期化が終わっていない場合(初回実行)のみ実行する
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDBを初期化中..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # バックグラウンドで一時的にMariaDBを起動
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5 # 起動するまで少し待つ

    # .envから読み込んだ値を使って、初期設定のSQLコマンドを実行
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'\%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # 設定が終わったら一時起動していたMariaDBをシャットダウン
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

echo "MariaDBをフォアグラウンドで起動します..."
# execを使うことで、このスクリプト自身のプロセスをMariaDBに置き換えるから、PIDは変わらない
exec mysqld_safe --datadir=/var/lib/mysql
