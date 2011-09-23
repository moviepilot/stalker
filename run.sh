#!/bin/sh

. /etc/environment
. /etc/profile
. ~/.profile

/usr/local/bin/rvm use 1.8.7
cd /home/moviepilot/tmp/stalker-api-tester/
/home/moviepilot/daemons/nodejs/bin/node stalk.js "http://sheldon.staging.moviepilot.com:2311" endpoints.txt
/home/moviepilot/daemons/nodejs/bin/node stalk.js "http://db02.moviepilot.com:2311" endpoints.txt
exit 0
