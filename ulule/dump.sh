#!/bin/sh

curl 'http://localhost:9200/logstash-ulule-*/ulule/_search?size=10000&q=*' | \
  jq -c '
    .hits.hits[]._source |
    {(."timestamp"): {"id","slug","committed","supporters_count","amount_raised","nb_products_sold"}}
    ' | \
  perl -pe 's/^\{"([0-9\-]+)"\:(.*)\}$/\1\2/' | \
  sort
