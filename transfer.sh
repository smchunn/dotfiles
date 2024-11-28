#!/bin/bash

# Set the path to the admin's preferences
admin_dock="/Users/smchunn/Library/Preferences/com.apple.dock.plist"
admin_finder="/Users/smchunn/Library/Preferences/com.apple.finder.plist"

user="jennychunn"
user_home=$(eval echo ~${user})

# Only apply to non-system users
if [ -d "$user_home" ] && [ "$user" != "admin" ]; then
  echo "Copying preferences to $user..."

    # Copy Dock and Finder preferences
    sudo cp "$admin_dock" "$user_home/Library/Preferences/com.apple.dock.plist"
    sudo cp "$admin_finder" "$user_home/Library/Preferences/com.apple.finder.plist"

    # Set proper ownership
    sudo chown "$user:staff" "$user_home/Library/Preferences/com.apple.dock.plist"
    sudo chown "$user:staff" "$user_home/Library/Preferences/com.apple.finder.plist"

    # Restart Dock and Finder for the user
    sudo -u "$user" killall Dock
    sudo -u "$user" killall Finder
fi

echo "Preferences applied to all users."

