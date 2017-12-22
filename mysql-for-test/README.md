# dockerfile-mysql-test
```
docker build --tag mysql-for-test ~/docker/mysql-for-test/
docker run -d -p 3306:3306 --name mysql-for-test mysql-for-test
mysql -h $(docker-machine ip dev) -P 3306 -u root -p
or
mysql -h localhost --protocol tcp -P 3306 -u root -p
```
