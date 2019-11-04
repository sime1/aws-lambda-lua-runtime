--- Lambda runtime module
--
-- This module provides helper functions used to interact
-- with the aws lambda runtime interface
-- @module lambda_runtime

local http = require "socket.http"

local lambda_runtime = {}

local runtime_api = "http://" .. os.getenv("AWS_LAMBDA_RUNTIME_API") .. "/2018-06-01/runtime"

--- get the next invocation to process
-- @return the event received by the lambda function
-- @return @{context} 
function lambda_runtime.next_invocation()
    local event, _, headers = http.request(runtime_api .. "/invocation/next")
    local context = {
        request_id=headers["lambda-runtime-aws-request-id"],
        deadline=headers["lambda-runtime-deadline-ms"],
        invoked_function_arn=headers["lambda-runtime-invoked-function-arn"],
        client_context=headers["lambda-runtime-client-context"],
        cognito_identity=headers["lambda-runtime-cognito-identity"]
    }
    return event, context
end

-----
-- request context
-- @field request_id the id of the request
-- @field deadline deadline in ms
-- @field invoked_function_arn the arn of the invoked lambda function
-- @field client_context for invocations from the AWS Mobile SDK, data about the client application and device 
-- @field congnito_identity for invocations from the AWS Mobile SDK, data about the Amazon Cognito identity provider
-- @table context

--- send success response to the runtime
-- @param req_id id of the request. You can retrieve it from the @{context}
-- @param res string containing the response to send to the runtime
function lambda_runtime.send_response(req_id, res)
    http.request(runtime_api .. "/invocation/" .. req_id .. "/response", res)
end

--- send an invocation error to the runtime
-- @param req_id id of the request. You can retrieve it from the @{context}
-- @param err string containing the error message
function lambda_runtime.invocation_error(req_id, err)
    http.request(runtime_api .. "/invocation/" .. req_id .. "/error", err)
end

--- send an initialization error to the runtime
-- @param err string containing the error message
function lambda_runtime.init_error(err)
    http.request(runtime_api .. "/init/error", err)
end

return lambda_runtime