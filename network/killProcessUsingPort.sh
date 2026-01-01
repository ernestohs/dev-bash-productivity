#!/bin/bash

# Check if the port number is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <port_number>"
  exit 1
fi

PORT=$1

# Find the process using the specified port
PIDS=$(lsof -t -i :$PORT)

if [ -z "$PIDS" ]; then
  echo "No process is using port $PORT."
else
  kill -9 $PIDS
  echo "Killed process(es) using port $PORT: $PIDS"
fi
