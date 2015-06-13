#!/bin/sh

#curl 'http://localhost:9200/logstash-ulule-*/ulule/_search?size=1000&q=message:*' | \
#  jq -r '.hits.hits[]._source' > clean.save.json
#curl -XDELETE 'http://localhost:9200/logstash-ulule-*/ulule/_query?q=message:*'
#curl 'http://localhost:9200/logstash-ulule-*/ulule/_search?size=1000&q=_missing_:slug' | \
#  jq -r '.hits.hits[]._source' > clean.save2.json
#curl -XDELETE 'http://localhost:9200/logstash-ulule-*/ulule/_query?q=_missing_:slug'
