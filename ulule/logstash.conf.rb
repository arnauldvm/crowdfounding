input {
  stdin {
    #tags => [ "test_mode" ]
    type => "ulule"
  }
}
filter {
  grok {
    # 20150217-010515{"id":23087,"slug":"quartermaster","committed":10824,"supporters_count":212,"amount_raised":10824,"nb_products_sold":212}
    match => [ "message", "(?<timestamp>%{YEAR}%{MONTHNUM2}%{MONTHDAY}-%{HOUR}%{MINUTE}%{SECOND})\{\"id\":%{NONNEGINT:id},\"slug\":\"(?<slug>[^\"]+)\",\"committed\":%{NONNEGINT:committed},\"supporters_count\":%{NONNEGINT:supporters_count},\"amount_raised\":%{NONNEGINT:amount_raised},\"nb_products_sold\":%{NONNEGINT:nb_products_sold}\}" ]
  }
  date {
    match => [ "timestamp", "yyyyMMdd-HHmmss" ]
    timezone => "Europe/Brussels"
  }
  mutate {
    convert => [ "id", "integer" ]
    convert => [ "committed", "integer" ]
    convert => [ "supporters_count", "integer" ]
    convert => [ "amount_raised", "integer" ]
    convert => [ "nb_products_sold", "integer" ]
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
    elasticsearch { host => localhost protocol => "http" port => "9200" index => "logstash-ulule-%{+YYYY.MM.dd}" flush_size => 1}
  }
}
