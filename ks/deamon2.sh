#!/bin/bash

url='https://www.kickstarter.com/projects/search.json?search=&term=hope'
slug='hope-the-board-game'
fields='id,slug,usd_pledged,backers_count,pledged'
period_sec=600

while :; do (echo -n $(date +%Y%m%d-%H%M%S); curl --silent "$url" | jq -c ".projects[]|select(.slug==\"$slug\")|{$fields}"); sleep "$period_sec"; done | tee -a kickstarter2.log | logstash -f logstash.conf.rb

