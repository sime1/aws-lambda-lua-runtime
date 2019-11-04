# AWS Lambda Lua Runtime

In this repo you can find the code to build an AWS Lambda layer that provides a
custom runtime for Lua. You can use it to write Lambda functions in Lua.

# What's included in the layer

* LuaJIT intepreter
* `dkjson` and `luasocket` libraries (can be `require`d)

# Building

You need to have `docker` and `wget` installed. You can then run

```shell
./build.sh
```

If everything works, you should find the zip of the lambda layer inside the 
`dist` directory