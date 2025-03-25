-- ExternalAPI.lua - Template for External API Integration
-- This file demonstrates essential patterns for integrating with external APIs

local LrHttp = import "LrHttp"
local LrLogger = import "LrLogger"
local LrPrefs = import "LrPrefs"
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import "LrTasks"

-- Load JSON utility
local dkjsonPath = LrPathUtils.child(_PLUGIN.path, "DkJson.lua")
local json = dofile(dkjsonPath)

-- Set up logging
local console = LrLogger("PluginTemplate")

-- Get plugin preferences
local prefs = LrPrefs.prefsForPlugin()

-- Utility function to retry an API call
-- Essential for handling unreliable network connections
local function retryApiCall(params)
    local apiCallFn = params.apiCallFn
    local validateFn = params.validateFn
    local maxRetries = params.maxRetries or 2
    local retryDelay = params.retryDelay or 1
    local logPrefix = params.logPrefix or "API call"

    for attempt = 1, maxRetries + 1 do
        local success, result = pcall(apiCallFn)

        if success and result then
            if not validateFn or validateFn(result) then
                return result
            end
        end

        if attempt <= maxRetries then
            console:infof("Retry %d/%d: %s failed, retrying in %d second(s)", attempt, maxRetries, logPrefix, retryDelay)
            LrTasks.sleep(retryDelay)
        end
    end

    console:warnf("All retries failed for %s", logPrefix)
    return nil
end

-- Basic GET request
-- CUSTOMIZE: Replace with your API endpoint
local function getData()
    local response = LrHttp.get(prefs.serverURL .. "/api/data", {{
        field = "Authorization",
        value = "Bearer " .. prefs.apiKey
    }})

    console:debugf("API GET Response: %s", response)

    if response then
        local data = json.decode(response)
        return data
    end

    return nil
end

-- Basic POST request
-- CUSTOMIZE: Replace with your API endpoint and data structure
local function postData(payload)
    local jsonPayload = json.encode(payload)
    
    local response = LrHttp.post(prefs.serverURL .. "/api/data", jsonPayload, {{
        field = "Authorization",
        value = "Bearer " .. prefs.apiKey
    }, {
        field = "Content-Type",
        value = "application/json"
    }})

    console:debugf("API POST Response: %s", response)

    if response then
        local data = json.decode(response)
        return data
    end

    return nil
end

-- PUT request (for updates)
-- CUSTOMIZE: Replace with your API endpoint
local function updateData(id, payload)
    local jsonPayload = json.encode(payload)
    
    local response = LrHttp.post(prefs.serverURL .. "/api/data/" .. id, jsonPayload, {{
        field = "Authorization",
        value = "Bearer " .. prefs.apiKey
    }, {
        field = "Content-Type",
        value = "application/json"
    }}, 'PUT')

    console:debugf("API PUT Response: %s", response)

    if response then
        local data = json.decode(response)
        return data
    end

    return nil
end

-- Test connection to external service
-- CUSTOMIZE: Replace with your health check endpoint
local function testConnection()
    console:info("Testing connection to external service...")
    
    local response = LrHttp.get(prefs.serverURL .. "/api/health", {{
        field = "Authorization",
        value = "Bearer " .. prefs.apiKey
    }})
    
    console:debugf("API Connection Test Response: %s", response)
    
    if response then
        local data = json.decode(response)
        return data and data.status == "ok"
    end
    
    return false
end

-- Example of using retry mechanism for unreliable operations
-- CUSTOMIZE: Replace with your specific operation
local function getDataWithRetry()
    return retryApiCall({
        apiCallFn = function()
            return getData()
        end,
        validateFn = function(result)
            return result and result.data
        end,
        maxRetries = 3,
        retryDelay = 1,
        logPrefix = "Get data"
    })
end

-- Export the essential API functions
-- CUSTOMIZE: Replace with your specific API functions
return {
    -- Basic HTTP operations
    getData = getData,
    postData = postData,
    updateData = updateData,
    
    -- Utility functions
    testConnection = testConnection,
    getDataWithRetry = getDataWithRetry,
    retryApiCall = retryApiCall
}
