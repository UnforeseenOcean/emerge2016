#!/bin/bash

SCRIPT_NAME=$(basename $0)
DIR_NAME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function prepend_timestamp() {
	awk '{ print strftime("%Y-%m-%d %H:%M:%S |"), $0; fflush(); }'
}

source "$DIR_NAME/env.sh"

# # load the correct version of npm
# . "$NVM_DIR/nvm.sh" && nvm use "$NODE_VERSION_MICROSITE"

# launch mongod
"$DIR_NAME/start_mongod_slave.sh" 2>&1 \
	| prepend_timestamp \
	| tee -a "$DIR_NAME/../log/mongod-slave.log" &

sleep 10
echo "Sleeping for 10 seconds before launching microsite..."

# launch microsite node server
node "$DIR_NAME/../microsite/server.js" 2>&1 \
	| prepend_timestamp \
	| tee -a "$DIR_NAME/../log/microsite-server.log" &