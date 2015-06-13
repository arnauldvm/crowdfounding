#!/bin/sh

curl 'http://localhost:9200/logstash-ulule-*/ulule/_search?size=1000&q=*' | \
  jq -r '.hits.hits[]._source.message' | \
  logstash -f logstash.conf.rb
