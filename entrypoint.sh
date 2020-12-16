#!/bin/bash

/etc/init.d/cron start

cd /home/production/SMMID/root/js

npm install

cd /home/production/SMMID

perl /home/production/SMMID/script/smmid_server.pl -r -p 8088 2> /home/production/smmid.log

