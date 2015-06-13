input {
  stdin {
    #tags => [ "test_mode" ]
    type => "kickstarter"
  }
}
filter {
  grok {
    # 20150217-010515{"id":23087,"slug":"quartermaster","committed":10824,"supporters_count":212,"amount_raised":10824,"nb_products_sold":212}
    # 20150522-224744{"id":1600100209,"slug":"mare-nostrum-empires","usd_pledged":"46060.0","backers_count":735,"pledged":46060}
    match => [ "message", "(?<timestamp>%{YEAR}%{MONTHNUM2}%{MONTHDAY}-%{HOUR}%{MINUTE}%{SECOND})\{\"id\":%{NONNEGINT:id},\"slug\":\"(?<slug>[^\"]+)\",\"usd_pledged\":\"%{NUMBER:usd_pledged}\",\"backers_count\":%{NONNEGINT:backers_count},\"pledged\":%{NONNEGINT:pledged}\}" ]
  }
  date {
    match => [ "timestamp", "yyyyMMdd-HHmmss" ]
    timezone => "Europe/Brussels"
  }
  mutate {
    convert => [ "id", "integer" ]
    convert => [ "usd_pledged", "float" ]
    convert => [ "backers_count", "integer" ]
    convert => [ "pledged", "integer" ]
  }
  mutate { remove_field => [ "host" ] }
  if "_grok_parse_failure" not in [tags] {
    mutate { remove_field => [ "message" ] }
  }
}
output {
  if "test_mode" in [tags] {
    stdout {
    #file { path => "results.rb"
      #codec => "plain"
      #codec => "json"
      codec => "json_lines"
      #codec => "rubydebug"
    }
  } else {
    elasticsearch { host => localhost protocol => "http" port => "9200" index => "logstash-kickstarter-%{+YYYY.MM.dd}" flush_size => 1}
  }
}
