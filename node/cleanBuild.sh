#!/bin/bash

rm -rm node_modules
npm install
npm run build
npm run test
