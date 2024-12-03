function dict_set
  set -l dict_name $argv[1]
  set -l key $argv[2]
  set -l new_value $argv[3]

  # Get the contents of the variable whose name is stored in dict_name
  eval set -l json_data \$$dict_name

  # Debug: Print the current value of the dictionary
  # echo "dict_name=: $dict_name" >&2
  # echo "dict_value=: $json_data" >&2

  # Ensure dict_value is not empty; initialize if necessary
  if test -z "$json_data"
      set json_data '{}'
  end

  # Update the JSON object and store it back in the original variable
  set -l json_data (echo $json_data | jq -c --arg key "$key" --arg value "$new_value" '.[$key] = $value')
  eval set -g $dict_name "'$json_data'"
end
