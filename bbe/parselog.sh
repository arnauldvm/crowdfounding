#!/bin/sh

#20150318-211459{"backers":948,"pledged":116520}

perl -pe 's/^.*(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})\{"backers":(\d+),"pledged":(\d+)\}$/\1-\2-\3 \4:\5:\6; \8; \7/' bbe.log | uniq -s 20

