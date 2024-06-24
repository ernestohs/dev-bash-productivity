#!/bin/bash

rm -rf node_modules package-lock.json
npm install
npm prune
npm outdated
npm update
npx npm-check-updates -u
npm install
npx depcheck
npm cache clean --force
