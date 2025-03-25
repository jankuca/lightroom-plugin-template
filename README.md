# Lightroom Plugin Template

This repository provides a comprehensive template for creating Adobe Lightroom plugins. It includes common patterns, utilities, and examples that demonstrate best practices for Lightroom plugin development.

## Features

- **Plugin Metadata Structure** - Proper Info.lua configuration
- **Configuration Dialog** - Template for settings UI with various input types
- **External API Integration** - Template for connecting to external services
- **Progress Tracking** - Async operations with cancellation support
- **Logging** - Comprehensive logging setup
- **Error Handling** - Retry mechanisms and error recovery
- **Dry Run Mode** - Preview operations before execution

## Template Structure

```
lightroom-plugin-template.lrdevplugin/
├── Info.lua              # Plugin metadata and menu structure
├── ConfigDialog.lua       # Configuration UI template
├── ExternalAPI.lua        # External service integration template
├── MainAction.lua         # Primary plugin action
├── SharedLogic.lua        # Common operation patterns
└── DkJson.lua            # JSON utility library
```

## Getting Started

### 1. Clone and Rename

1. Clone this repository
2. Rename the plugin directory from `lightroom-plugin-template.lrdevplugin` to `your-plugin-name.lrdevplugin`

### 2. Customize Plugin Metadata

Edit `Info.lua`:

```lua
return {
    LrSdkVersion = 10.0,
    LrToolkitIdentifier = "com.yourname.lightroom.yourplugin", -- CHANGE THIS
    LrPluginName = "Your Plugin Name", -- CHANGE THIS

    LrExportMenuItems = {
        {
            title = "Your Main Action", -- CHANGE THIS
            file = "MainAction.lua"
        },
        -- Add more menu items as needed
    }
}
```

### 3. Configure Settings

Edit `ConfigDialog.lua` to customize your plugin's configuration options:

- Replace server/API configuration with your service's requirements
- Add/remove configuration fields as needed
- Update validation logic for your specific needs

### 4. Implement External API Integration

Edit `ExternalAPI.lua`:

- Replace example API endpoints with your service's URLs
- Update authentication methods (API key, OAuth, etc.)
- Customize data structures for your service's responses
- Implement your specific API operations

### 5. Customize Main Logic

Edit `SharedLogic.lua`:

- Replace example operations with your plugin's core functionality
- Update progress tracking messages
- Customize data processing logic
- Implement your specific business rules

### 6. Update Entry Points

Edit `MainAction.lua`:

- Update function calls to match your SharedLogic functions
- Customize logging messages
- Add any action-specific parameters

## Key Patterns Demonstrated

### Async Operations with Progress Tracking

```lua
local progressScope = LrProgressScope({
    title = "Operation Title",
    functionContext = context
})

-- Your operation code here

if progressScope:isCanceled() then
    progressScope:done()
    return
end

progressScope:done()
```

### Configuration Management

```lua
local prefs = LrPrefs.prefsForPlugin()

-- Set defaults
if not prefs.yourSetting then
    prefs.yourSetting = "default_value"
end
```

### External API Calls with Retry

```lua
local result = retryApiCall({
    apiCallFn = function()
        return LrHttp.get(url, headers)
    end,
    validateFn = function(result)
        return result and result.data
    end,
    maxRetries = 3,
    retryDelay = 1
})
```

### Dry Run Mode

```lua
local function performOperation(options)
    local isDryRun = options and options.isDryRun or false

    if isDryRun then
        console:info("[DRY RUN] Would perform operation")
    else
        -- Actual operation
        console:info("Performing operation")
    end
end
```

## Customization Checklist

- [ ] Update `LrToolkitIdentifier` in Info.lua (must be unique)
- [ ] Update `LrPluginName` in Info.lua
- [ ] Customize menu items in Info.lua
- [ ] Update configuration fields in ConfigDialog.lua
- [ ] Replace API endpoints in ExternalAPI.lua
- [ ] Update authentication method in ExternalAPI.lua
- [ ] Implement your core logic in SharedLogic.lua
- [ ] Update logging names throughout files
- [ ] Test with Lightroom Plugin Manager

## Development Tips

1. **Use Plugin Manager**: Install via Lightroom's Plugin Manager for easier development
2. **Enable Logging**: Logs are written to files - check Lightroom's plugin log directory
3. **Test Dry Run**: Always implement and test dry run mode first
4. **Progress Tracking**: Use LrProgressScope for long operations
5. **Error Handling**: Implement proper error handling and user feedback
6. **Cancellation**: Always check for user cancellation in long operations

## Common Lightroom SDK Imports

```lua
local LrApplication = import "LrApplication"    -- Access catalog and photos
local LrDialogs = import "LrDialogs"           -- Show dialogs and messages
local LrHttp = import "LrHttp"                 -- HTTP requests
local LrLogger = import "LrLogger"             -- Logging
local LrPrefs = import "LrPrefs"               -- Plugin preferences
local LrProgressScope = import "LrProgressScope" -- Progress tracking
local LrTasks = import "LrTasks"               -- Async operations
local LrView = import "LrView"                 -- UI components
```

## Resources

- [Lightroom SDK Documentation](https://www.adobe.com/devnet/photoshoplightroom.html)
- [Lightroom Plugin Development Guide](https://www.adobe.com/content/dam/acom/en/devnet/photoshoplightroom/pdfs/lr_sdk_guide.pdf)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)

## License

This template is provided as-is for educational and development purposes. Customize as needed for your specific plugin requirements.
