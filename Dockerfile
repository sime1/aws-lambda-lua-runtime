FROM amazonlinux:2018.03 AS builder
RUN mkdir /lua
RUN yum install -y make findutils gcc unzip build-essential libreadline-dev curl openssl openssl-devel m4
COPY packages/LuaJIT-2.0.5.tar.gz /tmp/
WORKDIR /tmp
RUN tar -xvzf LuaJIT-2.0.5.tar.gz
WORKDIR /tmp/LuaJIT-2.0.5
RUN make && make install PREFIX=/lua

WORKDIR /tmp
COPY packages/luarocks-3.2.1.tar.gz /tmp
RUN tar -xvzf luarocks-3.2.1.tar.gz
RUN cd luarocks-3.2.1 && ./configure --with-lua=/lua && make bootstrap
RUN mkdir /lua-share
RUN ls /usr/local/
RUN /usr/local/bin/luarocks install --verbose dkjson --tree=/lua-share
RUN /usr/local/bin/luarocks install --verbose luasocket --tree=/lua-share
RUN cp -R /lua-share /lua/rocks
COPY bootstrap /lua/bootstrap
COPY runtime /lua/runtime

FROM amazonlinux:2018.03
RUN yum install -y openssl zip
COPY --from=builder /lua /lua
ENV LUA_PATH /lua/rocks/share/lua/5.1/?.lua;;
ENV LUA_CPATH /lua/rocks/lib/lua/5.1/?.so;;
WORKDIR /lua
CMD ["zip", "-r", "/output/lua-runtime.zip", "."]

