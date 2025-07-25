#!/bin/bash

echo "Starting Prometheus Obfuscator API..."
echo

echo "Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies"
    exit 1
fi

echo
echo "Building project..."
npm run build
if [ $? -ne 0 ]; then
    echo "Failed to build project"
    exit 1
fi

echo
echo "Starting API server on port 3000..."
echo "You can test it at: http://localhost:3000/health"
echo
npm run start:api
