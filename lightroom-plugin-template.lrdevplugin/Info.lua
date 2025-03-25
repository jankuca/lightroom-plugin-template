-- Info.lua - Plugin Metadata Template
-- This file defines the plugin's basic information and menu structure
-- Replace placeholder values with your plugin's specific information
return {
    -- Lightroom SDK version (10.0 is compatible with most recent versions)
    LrSdkVersion = 10.0,

    -- Unique identifier for your plugin (use reverse domain notation)
    -- REPLACE: com.yourname.lightroom.yourplugin
    LrToolkitIdentifier = "com.yourname.lightroom.templateplugin",

    -- Display name for your plugin
    -- REPLACE: Your Plugin Name
    LrPluginName = "Lightroom Plugin Template",

    -- Plugin version (optional)
    VERSION = {
        major = 1,
        minor = 0,
        revision = 0
    },

    -- Menu items that appear in Lightroom's File > Plug-in Extras menu
    LrExportMenuItems = {{
        title = "Main Action",
        file = "MainAction.lua"
    }, {
        title = "Settings",
        file = "ConfigDialog.lua"
    }}
}
