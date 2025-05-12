function dict_get
  set -l dict_name $argv[1]
  set -l key $argv[2]
  eval set -l json_data \$$dict_name
  echo $json_data | jq --raw-output ".$key"
end
