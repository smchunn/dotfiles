require("hs.hotkey")
require("hs.spaces")
require("hs.inspect")
require("hs.application")

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SpaceSwitcher"
obj.version = "0.0"
obj.author = "smchunn"

obj.log = hs.logger.new("SpaceSwitcher", 5)

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

--- AppWindowSwitcher:bindHotkeys(mapping) -> self
--- Method
--- Binds hotkeys for AppWindowSwitcher
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for each
---  application to manage
---
--- Notes:
--- The mapping table accepts these formats per table element:
--- * A single text to match:
---   `["<bundleID>"] = {mods, key}`
--- Returns:
---  * The AppWindowSwitcher object
function obj:bindHotkeys(mods, key)
	hs.hotkey.bind(mods, key, function()
		local focusedSpaceID = hs.spaces.focusedSpace()
		local focusedDisplayID = hs.spaces.spaceDisplay(focusedSpaceID)
		obj.log.d(focusedDisplayID)
		obj.log.d(focusedSpaceID)
		obj.log.d(dump(hs.spaces.allSpaces()))
		newS = nil
		for k, v in pairs(hs.spaces.allSpaces()) do
			if k == focusedDisplayID then
				for i = 1, #v do
					if v[i] == focusedSpaceID then
						if i ~= #v then
							newS = v[i + 1]
						else
							newS = v[1]
						end
					end
				end
			end
		end
		if newS then
			hs.spaces.gotoSpace(newS)
		end
	end)
	return self
end

function obj:setLogLevel(level)
	obj.log.setLogLevel(level)
	return self
end

return obj
