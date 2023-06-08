
require("hs.hotkey")
require("hs.window")
require("hs.inspect")
require("hs.application")

local obj={}
obj.__index = obj

-- Metadata
obj.name = "AppHotkey"
obj.version = "0.0"
obj.author = "smchunn"


-- AppWindowSwitcher.log
-- Variable
-- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.log = hs.logger.new("AppHotkey")

-- Matches window properties with matchtext
-- Returns true if:
-- * windows application bundleID = matchtext
function obj.match(window, matchtext)
    bundleID = window:application():bundleID()
    if matchtext == bundleID then
        obj.log.d("bundleID matches:", bundleID)
        return true
    end
    return false
end

--- AppWindowSwitcher:bindHotkeys(mapping) -> self
--- Method
--- Binds hotkeys for AppWindowSwitcher
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for each application to manage 
---
--- Notes:
--- The mapping table accepts these formats per table element:
--- * A single text to match:
---   `["<bundleID>"] = {mods, key}` 
--- Returns:
---  * The AppWindowSwitcher object
function obj:bindHotkeys(mapping)
    for bundleID, modsKey in pairs(mapping) do
        obj.log.d("Mapping " .. hs.inspect(bundleID) .. 
                  " to " .. hs.inspect(modsKey))

        mods, key = table.unpack(modsKey)
        hs.hotkey.bind(mods, key, function() 
            local focusedWindowBundleID = 
                hs.window.focusedWindow():application():bundleID() 

            newW = nil
            if obj.match(hs.window.focusedWindow(), bundleID) then
                -- app has focus, find last matching window
                for _, w in pairs(hs.window.orderedWindows()) do
                    if obj.match(w, bundleID) then
                        newW = w -- remember last match
                    end
                end
            else
                -- app does not have focus, find first matching window
                for _, w in pairs(hs.window.orderedWindows()) do
                    if obj.match(w, bundleID) then
                        newW = w
                        break -- break on first match
                    end
                end
            end
            if newW then
                newW:raise():focus()
            else
                hs.application.launchOrFocusByBundleID(bundleID)
            end
        end)
    end

    return self
end

--- AppWindowSwitcher:setLogLevel(level) -> self
--- Method
--- Set the log level of the spoon logger.
---
--- Parameters:
---  * Log level - `"debug"` to enable console debug output
---
--- Returns:
---  * The AppWindowSwitcher object
function obj:setLogLevel(level)
    obj.log.setLogLevel(level)
    return self
end

return obj
