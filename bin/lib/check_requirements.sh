#!/bin/bash

# Check if the Sail configuration file exists.
if [ ! -f ./config/sail.conf ]; then
	echo "Error: config/sail.conf not found. Please create it or copy from config/sail.sample.conf."
	exit 1
fi

if ! command -v mkcert &> /dev/null; then
	echo "Error: mkcert is not installed. Install it with: brew install mkcert."
fi 