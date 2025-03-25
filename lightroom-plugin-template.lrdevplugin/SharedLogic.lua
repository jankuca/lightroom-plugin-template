-- SharedLogic.lua - Template for Shared Plugin Logic
-- This file demonstrates common patterns for complex plugin operations with progress tracking
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local ExternalAPI = require "ExternalAPI"
local LrLogger = import "LrLogger"
local LrPrefs = import "LrPrefs"
local LrPathUtils = import "LrPathUtils"
local LrProgressScope = import "LrProgressScope"

-- Set up logging
local console = LrLogger("PluginTemplate")
console:enable("print") -- Logs will be written to a file

-- Get plugin preferences
local prefs = LrPrefs.prefsForPlugin()

-- Helper function to get the dry run prefix for log messages
-- This is useful for operations that can run in "preview" mode
local function getDryRunPrefix(isDryRun)
    return isDryRun and "[DRY RUN] " or ""
end

-- Utility function to calculate string similarity using Levenshtein distance
-- This is useful for fuzzy matching of names or identifiers
local function levenshteinDistance(str1, str2)
    local len1, len2 = #str1, #str2
    local matrix = {}

    -- Initialize the matrix
    for i = 0, len1 do
        matrix[i] = {
            [0] = i
        }
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end

    -- Fill the matrix
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(matrix[i - 1][j] + 1, -- deletion
            matrix[i][j - 1] + 1, -- insertion
            matrix[i - 1][j - 1] + cost -- substitution
            )
        end
    end

    return matrix[len1][len2]
end

-- Example: Function to normalize names for comparison
-- CUSTOMIZE: Replace with your specific normalization logic
local function normalizeName(name)
    return string.lower(name):gsub("[%s%-_]+", "")
end

-- Example: Calculate similarity between two names
-- CUSTOMIZE: Adjust threshold and logic for your needs
local function calculateSimilarity(name1, name2)
    local normalized1 = normalizeName(name1)
    local normalized2 = normalizeName(name2)

    if normalized1 == normalized2 then
        return 1.0
    end

    local distance = levenshteinDistance(normalized1, normalized2)
    local maxLen = math.max(#normalized1, #normalized2)

    return maxLen > 0 and (1.0 - distance / maxLen) or 0.0
end

-- Example: Get Lightroom collections
-- CUSTOMIZE: Replace with your specific Lightroom data retrieval
local function getLightroomCollections()
    local catalog = LrApplication.activeCatalog()
    local collections = catalog:getChildCollections()

    local collectionMap = {}
    for _, collection in ipairs(collections) do
        collectionMap[collection:getName()] = collection
    end

    return collectionMap
end

-- Example: Check if an item should be processed based on selection criteria
-- CUSTOMIZE: Replace with your specific selection logic
local function isItemSelected(itemName, selectedItems)
    if not prefs.enableFeatureA then
        return true -- Process all items if feature is disabled
    end

    if not selectedItems or selectedItems == "" then
        return true -- Process all if no specific selection
    end

    -- Split selected items by semicolon and check for matches
    for selectedItem in selectedItems:gmatch("[^;]+") do
        selectedItem = selectedItem:match("^%s*(.-)%s*$") -- trim whitespace
        if itemName:find(selectedItem, 1, true) then
            return true
        end
    end

    return false
end

-- Example: Main operation function with progress tracking and cancellation support
-- CUSTOMIZE: Replace with your specific operation logic
local function performMainOperation(options)
    local isDryRun = options and options.isDryRun or false
    local isQuickMode = options and options.isQuickMode or false
    local modePrefix = isQuickMode and "Quick " or ""

    console:infof('%sStarting %soperation%s', getDryRunPrefix(isDryRun), modePrefix,
        isDryRun and " (no changes will be made)" or "")

    -- Phase 1: Getting data from Lightroom
    local progressScope = LrProgressScope({
        title = "Getting Lightroom data",
        functionContext = options and options.functionContext
    })

    local lightroomCollections = getLightroomCollections()
    console:infof("%sFound %d Lightroom collections", getDryRunPrefix(isDryRun), table.getn(lightroomCollections))

    -- Check for cancellation
    if progressScope:isCanceled() then
        console:info("Operation canceled during Lightroom data retrieval")
        progressScope:done()
        return
    end

    progressScope:done()

    -- Phase 2: Getting data from external service
    progressScope = LrProgressScope({
        title = "Getting external service data",
        functionContext = options and options.functionContext
    })

    local externalData = ExternalAPI.getData()
    console:infof("%sRetrieved external data", getDryRunPrefix(isDryRun))

    -- Check for cancellation
    if progressScope:isCanceled() then
        console:info("Operation canceled during external data retrieval")
        progressScope:done()
        return
    end

    progressScope:done()

    -- Phase 3: Processing items
    progressScope = LrProgressScope({
        title = "Processing items",
        functionContext = options and options.functionContext
    })

    local itemsToProcess = {}
    -- CUSTOMIZE: Replace this logic with your specific data processing
    if externalData and externalData.items then
        for _, item in ipairs(externalData.items) do
            local lightroomCollection = lightroomCollections[item.name]
            if isItemSelected(item.name, prefs.textSetting) and lightroomCollection then
                table.insert(itemsToProcess, {
                    name = item.name,
                    data = item,
                    lrCollection = lightroomCollection
                })
            end
        end
    end

    console:infof("%sProcessing %d items", getDryRunPrefix(isDryRun), #itemsToProcess)

    -- Process each item
    for i, item in ipairs(itemsToProcess) do
        progressScope:setCaption("Processing item " .. i .. "/" .. #itemsToProcess .. " (" .. item.name .. ")")
        progressScope:setPortionComplete(i - 1, #itemsToProcess)

        console:infof("%sProcessing item: %s", getDryRunPrefix(isDryRun), item.name)

        -- Check for cancellation
        if progressScope:isCanceled() then
            console:infof("Operation canceled while processing item: %s", item.name)
            progressScope:done()
            return
        end

        -- CUSTOMIZE: Add your specific item processing logic here
        if not isDryRun then
            -- Perform actual operations
            console:infof("Would perform actual operation on: %s", item.name)
        else
            console:infof("Dry run - would process: %s", item.name)
        end
    end

    progressScope:done()

    local modePrefix = isQuickMode and "Quick " or ""
    console:infof("%s%sOperation completed successfully", getDryRunPrefix(isDryRun), modePrefix)

    if isDryRun then
        LrDialogs.message(modePrefix .. "Dry Run Complete", modePrefix ..
            "Dry run completed. Check the log for details on what would happen during a real operation.", "info")
    else
        LrDialogs.message(modePrefix .. "Operation Complete", modePrefix .. "Operation completed successfully.", "info")
    end
end

-- Export the main function for use by entry point files
-- CUSTOMIZE: Add other functions you want to expose
return {
    performMainOperation = performMainOperation,
    calculateSimilarity = calculateSimilarity,
    getDryRunPrefix = getDryRunPrefix
}
