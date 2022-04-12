#!/bin/sh
echo "Move stuff around"
sudo rm -rf /home/ubuntu/WebGoat.tar.gz
echo "Start containers"
cd /home/ubuntu/webapps/WebGoat/
sudo chown -R ubuntu:ubuntu /home/ubuntu/webapps/WebGoat
/usr/bin/java -Dfile.encoding=UTF-8 -Dserver.port=8080 -Dserver.address=localhost -Dhsqldb.port=9001 -javaagent:./webgoat-standalone/target/contrast.jar -Dcontrast.config.path=./webgoat-standalone/target/contrast_security.yaml -jar ./webgoat-container/target/webgoat-container-7.1-war-exec.jar </dev/null &>/dev/null &
sleep 25
echo "Curl URLS"
sudo curl --silent --output /dev/null -X GET "https://webgoat.contrast.pw/"
sudo curl --silent --output /dev/null -X GET "https://webgoat.contrast.pw/#/basket"
sudo curl --silent --output /dev/null -X GET "https://webgoat.contrast.pw/#/search"
sleep 10
