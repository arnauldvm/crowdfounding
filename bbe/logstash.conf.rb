input {
  stdin {
    #tags => [ "test_mode" ]
    type => "bbe"
  }
}
filter {
  grok {
    # 20150222-183331{"backers":518,"pledged":63233}
    match => [ "message", "(?<timestamp>%{YEAR}%{MONTHNUM2}%{MONTHDAY}-%{HOUR}%{MINUTE}%{SECOND})\{\"backers\":%{NONNEGINT:supporters_count},\"pledged\":%{NONNEGINT:amount_raised}\}" ]
  }
  date {
    match => [ "timestamp", "yyyyMMdd-HHmmss" ]
    timezone => "Europe/Brussels"
  }
  mutate {
    convert => [ "id", "integer" ]
    convert => [ "supporters_count", "integer" ]
    convert => [ "amount_raised", "integer" ]
  }
  mutate { remove_field => [ "host" ] }
  if "_grokparsefailure" not in [tags] {
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
