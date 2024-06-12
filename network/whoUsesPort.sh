#!/bin/bash

# Check if the port number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <port_number>"
  exit 1
fi

PORT=$1

# Find the process using the specified port
PROCESS=$(lsof -i :$PORT | awk 'NR==2 {print $2, $1}')

if [ -z "$PROCESS" ]; then
  echo "No process is using port $PORT."
else
  echo "Process using port $PORT: $PROCESS"
fi
