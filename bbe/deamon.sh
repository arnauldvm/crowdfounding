#!/bin/bash

while :; do (echo -n `date +%Y%m%d-%H%M%S`; curl --silent 'http://www.black-book-editions.fr/crowdfunding.php?id=7' | ./filter.pl); sleep 600; done | tee -a bbe.log | logstash -f logstash.conf.rb

