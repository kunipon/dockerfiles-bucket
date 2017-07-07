FROM mysql:5.7

# Set debian default locale to ja_JP.UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# set user infomation.
ENV MYSQL_ROOT_PASSWORD root-password
ENV MYSQL_USER test-user
ENV MYSQL_PASSWORD test-password
ENV MYSQL_DATABASE test


# MySQLをrootで実行する設定に書き換える
RUN sed -e 's/^ *user *= *mysql$/user = root/' -i /etc/mysql/my.cnf

# Set MySQL character
RUN { \
    echo '[mysqld]'; \
    echo 'character-set-server=utf8mb4'; \
    echo 'collation-server=utf8mb4_general_ci'; \
    echo '[client]'; \
    echo 'default-character-set=utf8mb4'; \
} > /etc/mysql/conf.d/charset.cnf