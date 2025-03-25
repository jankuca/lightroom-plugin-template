# Lightroom Plugin Development Guide

This guide provides detailed information about developing Lightroom plugins using this template.

## Plugin Architecture

### File Structure Overview

- **Info.lua**: Plugin manifest - defines metadata, menu items, and capabilities
- **ConfigDialog.lua**: Settings UI - handles user configuration
- **ExternalAPI.lua**: External service integration - API calls and data handling
- **SharedLogic.lua**: Core business logic - main operations and utilities
- **MainAction.lua**: Primary entry point - main plugin functionality
- **DkJson.lua**: JSON utility - third-party library for JSON parsing

### Data Flow

1. User selects menu item → Entry point file (MainAction.lua)
2. Entry point calls SharedLogic with parameters
3. SharedLogic retrieves data from Lightroom and external service
4. SharedLogic processes data and performs operations
5. Results are displayed to user

## Configuration Patterns

### Basic Configuration Fields

```lua
-- Text input
f:edit_field{
    value = LrView.bind("settingName"),
    width_in_chars = 30,
    placeholder = "Enter value"
}

-- Password field
f:edit_field{
    value = LrView.bind("apiKey"),
    password = true,
    width_in_chars = 30
}

-- Checkbox
f:checkbox{
    title = "Enable Feature",
    value = LrView.bind("enableFeature")
}

-- Validated numeric input
f:edit_field{
    value = LrView.bind("numericValue"),
    validate = function(view, value)
        local num = tonumber(value)
        if not num or num < 0 or num > 100 then
            return false, "Enter a number between 0 and 100"
        end
        return true
    end
}
```

### Setting Default Values

```lua
local prefs = LrPrefs.prefsForPlugin()

-- String setting
if not prefs.serverURL then
    prefs.serverURL = ""
end

-- Boolean setting (use nil check)
if prefs.enableFeature == nil then
    prefs.enableFeature = true
end

-- Numeric setting
if not prefs.threshold then
    prefs.threshold = "0.5"
end
```

## External API Integration

### HTTP Request Patterns

```lua
-- GET request
local response = LrHttp.get(url, {
    {field = "Authorization", value = "Bearer " .. apiKey},
    {field = "Accept", value = "application/json"}
})

-- POST request with JSON body
local payload = json.encode({key = "value"})
local response = LrHttp.post(url, payload, {
    {field = "Authorization", value = "Bearer " .. apiKey},
    {field = "Content-Type", value = "application/json"}
})

-- PUT request
local response = LrHttp.post(url, payload, headers, 'PUT')

-- PATCH request
local response = LrHttp.post(url, payload, headers, 'PATCH')
```

### Error Handling and Retries

```lua
local function retryApiCall(options)
    for attempt = 1, options.maxRetries + 1 do
        local success, result = pcall(options.apiCallFn)

        if success and options.validateFn(result) then
            return result
        end

        if attempt <= options.maxRetries then
            LrTasks.sleep(options.retryDelay)
        end
    end

    return nil
end
```

## Progress Tracking and Cancellation

### Basic Progress Scope

```lua
local progressScope = LrProgressScope({
    title = "Processing Items",
    functionContext = context
})

-- Update progress
progressScope:setCaption("Processing item 1 of 10")
progressScope:setPortionComplete(0, 10)

-- Check for cancellation
if progressScope:isCanceled() then
    progressScope:done()
    return
end

-- Always clean up
progressScope:done()
```

### Multi-Phase Operations

```lua
-- Phase 1
local progressScope = LrProgressScope({
    title = "Phase 1: Getting data",
    functionContext = context
})
-- ... phase 1 work ...
progressScope:done()

-- Phase 2
progressScope = LrProgressScope({
    title = "Phase 2: Processing",
    functionContext = context
})
-- ... phase 2 work ...
progressScope:done()
```

## Lightroom Catalog Operations

### Working with Collections

```lua
local catalog = LrApplication.activeCatalog()

-- Get all collections
local collections = catalog:getChildCollections()

-- Create new collection
catalog:withWriteAccessDo("Create Collection", function(context)
    local newCollection = catalog:createCollection("Collection Name")
end)

-- Add photos to collection
catalog:withWriteAccessDo("Add Photos", function(context)
    collection:addPhotos(photoArray)
end)
```

### Working with Photos

```lua
-- Get selected photos
local selectedPhotos = catalog:getTargetPhotos()

-- Get photo metadata
local path = photo:getRawMetadata("path")
local filename = photo:getRawMetadata("fileName")
local isVideo = photo:getRawMetadata("isVideo")

-- Get formatted metadata
local title = photo:getFormattedMetadata("title")
local keywords = photo:getFormattedMetadata("keywordTags")
```

## Logging Best Practices

### Logger Setup

```lua
local console = LrLogger("YourPluginName")
console:enable("print") -- Enable file logging
```

### Log Levels

```lua
console:trace("Detailed debugging info")
console:debug("Debug information")
console:info("General information")
console:warn("Warning message")
console:error("Error message")

-- Formatted logging
console:infof("Processing %d items", count)
console:debugf("API response: %s", response)
```

## Common Patterns

### Dry Run Implementation

```lua
local function performOperation(options)
    local isDryRun = options and options.isDryRun or false
    local prefix = isDryRun and "[DRY RUN] " or ""

    console:infof("%sStarting operation", prefix)

    if isDryRun then
        console:infof("%sWould create item: %s", prefix, itemName)
    else
        -- Actual operation
        local result = createItem(itemName)
        console:infof("%sCreated item: %s", prefix, result.id)
    end
end
```

### String Similarity Matching

```lua
local function calculateSimilarity(str1, str2)
    -- Normalize strings
    local norm1 = string.lower(str1):gsub("[%s%-_]+", "")
    local norm2 = string.lower(str2):gsub("[%s%-_]+", "")

    if norm1 == norm2 then
        return 1.0
    end

    -- Use Levenshtein distance
    local distance = levenshteinDistance(norm1, norm2)
    local maxLen = math.max(#norm1, #norm2)

    return maxLen > 0 and (1.0 - distance / maxLen) or 0.0
end
```

### Selection Filtering

```lua
local function isItemSelected(itemName, selectionString)
    if not selectionString or selectionString == "" then
        return true -- Select all if no filter
    end

    -- Split by semicolon and check each pattern
    for pattern in selectionString:gmatch("[^;]+") do
        pattern = pattern:match("^%s*(.-)%s*$") -- trim whitespace
        if itemName:find(pattern, 1, true) then -- plain text search
            return true
        end
    end

    return false
end
```

## Testing and Debugging

### Plugin Installation

1. Copy plugin folder to Lightroom's plugin directory
2. Or use Plugin Manager: File → Plugin Manager → Add
3. Enable the plugin if it's disabled

### Debugging Tips

1. **Use console logging extensively** - logs are written to files
2. **Test dry run mode first** - safer for development
3. **Handle cancellation** - test with long operations
4. **Validate configuration** - test with invalid settings
5. **Test error conditions** - network failures, API errors

### Common Issues

- **Plugin not appearing**: Check LrToolkitIdentifier is unique
- **Menu items missing**: Verify Info.lua syntax
- **API calls failing**: Check authentication and endpoints
- **UI not updating**: Ensure proper data binding
- **Crashes**: Add error handling around risky operations

## Performance Considerations

1. **Minimize API calls** - batch operations when possible
2. **Use progress tracking** - for operations > 1 second
3. **Implement cancellation** - for all long operations
4. **Cache data** - avoid repeated expensive operations
5. **Lazy loading** - load data only when needed

## Security Best Practices

1. **Store API keys securely** - use password fields in config
2. **Validate all inputs** - especially from external APIs
3. **Handle errors gracefully** - don't expose sensitive info
4. **Use HTTPS** - for all external API calls
5. **Sanitize file paths** - when working with local files
