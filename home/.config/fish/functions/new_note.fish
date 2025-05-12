function new_note --description 'Create a new file in $VAULT/inbox with given name'
    set --local name (string join ' ' $argv)
    set --local date (date +%Y-%m-%d)
    set --local id_name (echo $name | tr -d '[:punct:]' | tr -s '[:space:]' '-' | sed 's/-$//')
    set --local filename "$date-$id_name.md"
    set --local filepath "$VAULT/inbox/$filename"

    if test -f "$filepath"
        echo "Error: File already exists at $filepath"
        return 1
    end

    echo "---
id: $date-$id_name
aliases: $name
tags: []
---

# $name" >$filepath

    echo "Created file: $filepath"
end
