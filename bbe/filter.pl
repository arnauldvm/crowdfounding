#!/usr/bin/perl -p

# <div id="ks_marketing">517<small> participants</small><br>63 153&euro;<br>
s/^.*\Q<div id="ks_marketing">\E(\d+)\Q<small> participants<\/small><br>\E([0-9 ]+)\Q&euro;<br>\E.*$/\{"backers":\1,"pledged":\2\}/ or $_="";
s/ //;

