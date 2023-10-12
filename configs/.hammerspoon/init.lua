meh = { "alt", "ctrl", "shift" }
hs.loadSpoon("AppHotkey"):bindHotkeys({
	["com.brave.Browser"] = { meh, "z" },
	-- ["com.apple.finder"] = { meh, "q" },
	["org.alacritty"] = { meh, "a" },
})
hs.loadSpoon("SpaceSwitcher"):bindHotkeys(meh, "q")
