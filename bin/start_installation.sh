#!/bin/bash

SCRIPT_NAME=$(basename $0)
DIR_NAME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function prepend_timestamp() {
	awk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $0; fflush(); }'
}

source "$DIR_NAME/env.sh"
# load the correct version of npm
. "$NVM_DIR/nvm.sh" && nvm use "$NODE_VERSION_KINECT_DAEMON"

# launch the kinect daemon
(node "$DIR_NAME/launch_and_poll_kinect_daemon.js" 2>&1 & \
 echo $! > "$DIR_NAME/../pid/launch-and-poll-kinect-daemon.pid") \
	| prepend_timestamp \
	| tee -a "$DIR_NAME/../log/launch-and-poll-kinect-daemon.log" &

# launch mongod
"$DIR_NAME/start_mongod_master.sh" 2>&1 \
	| tee -a "$DIR_NAME/../log/mongod-master.log" &

# reverse-ssh tunnel to gallery server
"$DIR_NAME/tunnel.sh" 2>&1 \
	| prepend_timestamp \
	| tee -a "$DIR_NAME/../log/ssh-tunnel.log" & 

# create the /dev/rfcomm0 device to communicate with the card
# printer via bluetooth
"$DIR_NAME/start_printer.sh" 2>&1 \
	| prepend_timestamp \
	| tee -a "$DIR_NAME/../log/start-printer.log" &

# sync thumbnail folders on installation and microsite server
# NOTE: pidfile and logfile specified in lsyncd.config.lua
lsyncd "$DIR_NAME/lsyncd.config.lua"

# launch installation
# NOTE: nw/bin/nw internaly launches nw/nwjs/nw so $! doesn't return 
# the PID of the nw process after this command. Therefore we don't 
# write an app.pid in pid/ and instead use grep to kill this process
# in stop_installation.sh
cd "$DIR_NAME/../installation/" && "./node_modules/nw/bin/nw" .