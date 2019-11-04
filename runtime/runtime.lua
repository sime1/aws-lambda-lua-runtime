--- custom aws lambda runtime implementation
-- for LUA.

local json = require "dkjson"
local lambda_runtime = require "lambda"

--- initialize the runtime and start the event loop
function main()
    -- INITIALIZATION
    -- this is needed to save `print` output to cloudwatch
    io.stdout:setvbuf("no")
    local handler_name = os.getenv("_HANDLER")
    local i = string.gmatch(handler_name, "[^.]+")
    local file_name = i()
    local func_name = i()
    local loaded, module = pcall(require, file_name)
    if not loaded or module[func_name] == nil then
        local err = {
            errorMessage=module,
            errorType=InvalidFunctionException
        } 
        lambda.init_error(err)
        return
    end
    local handler = module[func_name]
    while true do
        handle_event(handler)
    end
end

-- handle the communication with the lambda runtime interface
function handle_event(handler)
    local event, context = lambda_runtime.next_invocation()
    local success, res = pcall(handler, event, context)
    if success then
        lambda_runtime.send_response(context.request_id, res)
    else
        lambda_runtime.invocation_error(context.request_id, res)
    end
end

main()