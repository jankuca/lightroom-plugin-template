-- MainAction.lua - Primary Plugin Action Template
-- This file demonstrates how to create a main plugin action with proper async handling
local LrTasks = import "LrTasks"
local SharedLogic = require "SharedLogic"
local LrLogger = import "LrLogger"
local LrFunctionContext = import "LrFunctionContext"

-- Set up logging
local console = LrLogger("PluginTemplate")
console:enable("print") -- Logs will be written to a file
console:infof('Main Action started')

-- Execute the main action asynchronously
-- This pattern ensures the UI remains responsive during long operations
LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("mainAction", function(context)
        -- CUSTOMIZE: Replace with your main operation
        SharedLogic.performMainOperation({
            isDryRun = false,
            functionContext = context
        }) -- Perform actual operation
    end)
end)
