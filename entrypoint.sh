#!/bin/bash

/etc/init.d/cron start

cd /home/production/SMMID/root/js

npm install

perl /home/production/SMMID/script/smmid_server.pl -p 8088

