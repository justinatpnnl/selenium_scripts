#!/bin/sh
script_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$script_path"
(trap 'kill 0' SIGINT; java -jar ./selenium-server-standalone-3.141.59.jar -role hub & java -Dwebdriver.chrome.driver=./webdrivers/chromedriver77 -Dwebdriver.gecko.driver=./webdrivers/geckodriver25 -jar ./selenium-server-standalone-3.141.59.jar -role node -hub http://localhost:4444/grid/register -port 5555 -browser "browserName=chrome,maxInstances=2" -browser "browserName=firefox,maxInstances=2")
