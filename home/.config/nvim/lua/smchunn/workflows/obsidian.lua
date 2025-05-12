local lfs = require("lfs")  -- LuaFileSystem for directory traversal
local yaml = require("lyaml")  -- YAML parser

local function move_files_based_on_yaml(directory)
    for file in lfs.dir(directory) do
        if file:match("%.md$") or file:match("%.yaml$") then  -- Adjust file types as needed
            local filepath = directory .. '/' .. file
            local f = io.open(filepath, "r")
            if f then
                local content = f:read("*a")
                f:close()

                -- Extract YAML front matter
                local front_matter = content:match("^%s*---(.-)---")
                if front_matter then
                    local data = yaml.load(front_matter)
                    if data and data.tags then
                        for tag in data.tags do
                            local target_dir = directory .. '/' .. data.tag
                            -- Check if the target directory exists
                            if lfs.attributes(target_dir, "mode") == "directory" then
                                os.rename(filepath, target_dir .. '/' .. file)
                                print("Moved " .. file .. " to " .. target_dir)
                            else
                                print("Target directory " .. target_dir .. " does not exist.")
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Usage
move_files_based_on_yaml("/path/to/your/directory")

