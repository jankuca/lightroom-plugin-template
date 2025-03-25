-- ConfigDialog.lua - Configuration UI Template
-- This file demonstrates common configuration dialog patterns for Lightroom plugins
local LrDialogs = import "LrDialogs"
local LrView = import "LrView"
local LrPrefs = import "LrPrefs"
local LrApplication = import "LrApplication"
local LrTasks = import "LrTasks"

local prefs = LrPrefs.prefsForPlugin()

-- Set default values for configuration options
-- CUSTOMIZE: Replace with your plugin's configuration options
if not prefs.serverURL then
    prefs.serverURL = ""
end

if not prefs.apiKey then
    prefs.apiKey = ""
end

if prefs.enableFeatureA == nil then
    prefs.enableFeatureA = true
end

if prefs.enableFeatureB == nil then
    prefs.enableFeatureB = false
end

if not prefs.numericSetting then
    prefs.numericSetting = "1.0"
end

if not prefs.textSetting then
    prefs.textSetting = ""
end

-- Example helper function - customize for your plugin's needs
local function getExampleData()
    local catalog = LrApplication.activeCatalog()
    local collections = catalog:getChildCollections()

    local names = {}
    for _, collection in ipairs(collections) do
        table.insert(names, collection:getName())
    end
    return names
end

-- Start the main task to show the config dialog
LrTasks.startAsyncTask(function()

    local f = LrView.osFactory()

    local c = f:column{
        bind_to_object = prefs,

        -- Plugin title
        f:static_text{
            title = "Plugin Configuration Template",
            font = "<system/bold>"
        },

        -- Server/API Configuration Section
        f:separator{
            fill_horizontal = 1
        },

        f:static_text{
            title = "Server Configuration",
            font = "<system/bold>"
        },

        f:row{f:static_text{
            title = "Server URL:"
        }, f:edit_field{
            value = LrView.bind("serverURL"),
            width_in_chars = 30,
            placeholder = "https://example.com"
        }},

        f:row{f:static_text{
            title = "API Key:"
        }, f:edit_field{
            value = LrView.bind("apiKey"),
            width_in_chars = 30,
            password = true,
            placeholder = "Enter your API key"
        }},

        -- Feature Configuration Section
        f:separator{
            fill_horizontal = 1
        },

        f:static_text{
            title = "Feature Settings",
            font = "<system/bold>"
        },

        f:row{f:checkbox{
            title = "Enable Feature A",
            value = LrView.bind("enableFeatureA")
        }},

        f:row{f:checkbox{
            title = "Enable Feature B",
            value = LrView.bind("enableFeatureB")
        }},

        f:row{f:edit_field{
            title = "Text Setting:",
            value = LrView.bind("textSetting"),
            width_in_chars = 40,
            placeholder = "Enter text value"
        }},

        f:row{f:static_text{
            title = "Numeric Setting (0.0-10.0):"
        }, f:edit_field{
            value = LrView.bind("numericSetting"),
            width_in_chars = 5,
            validate = function(view, value)
                local num = tonumber(value)
                if not num or num < 0 or num > 10 then
                    return false, "Please enter a number between 0.0 and 10.0"
                end
                return true
            end,
            immediate = true
        }},

        -- Action Buttons
        f:separator{
            fill_horizontal = 1
        },

        f:row{f:push_button{
            title = "Test Connection",
            action = function()
                -- CUSTOMIZE: Add your connection test logic here
                if prefs.serverURL and prefs.serverURL ~= "" then
                    LrDialogs.message("Connection Test", "Connection test would be performed here.", "info")
                else
                    LrDialogs.message("Connection Test", "Please enter a server URL first.", "warning")
                end
            end
        }, f:push_button{
            title = "Save Settings",
            action = function()
                -- CUSTOMIZE: Add any validation or save logic here
                LrDialogs.message("Settings Saved", "Configuration has been saved successfully.", "info")
            end
        }}
    }

    -- Show the dialog
    LrDialogs.presentModalDialog {
        title = "Plugin Template Settings",
        contents = c
    }

end)
