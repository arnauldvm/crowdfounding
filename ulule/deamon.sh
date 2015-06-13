#!/bin/sh

while :; do (echo -n `date +%Y%m%d-%H%M%S`; curl --silent -H "Authorization: ApiKey username: 91941c6972e7d72919a07c690a76c088eb00f55a" https://api.ulule.com/v1/users/arnauldvm/projects | jq -c '.projects[]|select(.slug=="quartermaster")|{id,slug,committed,supporters_count,amount_raised,nb_products_sold}'); sleep 600; done | tee -a ulule.log | logstash -f logstash.conf.rb

