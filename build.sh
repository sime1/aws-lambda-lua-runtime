#!/bin/sh
mkdir -p ./dist
rm -rf ./packages
mkdir ./packages
cd packages
wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz
wget https://luarocks.org/releases/luarocks-3.2.1.tar.gz
cd ..
docker build . -t lua-runtime
docker run --rm -v $(pwd)/dist:/output lua-runtime