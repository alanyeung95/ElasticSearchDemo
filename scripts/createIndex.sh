# todo: remove path coding

apk add curl
apk add jq

jq  '.mapping_body' /app/lib/mapping.json > /app/lib/mapping_body.json
# use -r for raw_output
indexVersion=$( jq -r '.mapping_version' /app/lib/mapping.json)

curl --header "Content-Type: application/json" \
  --request PUT \
  --data @/app/lib/mapping_body.json \
  elasticsearch:9200/domain_items_$indexVersion?include_type_name=true

rm /app/lib/mapping_body.json